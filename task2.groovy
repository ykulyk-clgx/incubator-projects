#!/usr/bin/env groovy

/*
Given tasks:
  1) setup system message;
  2) setup global admin email address;
  3) setup smtp server;
  4) setup slack;
  5) setup github;
  6) create three folders: `/folder1`, `/folder1/folder2` and `/folder3`;
  7) for `folder1` configure a shared library;
  8) create simple `USERNAME` and `PASSWORD` credentials;
  9) create role and group `poweruser` and assing it to `/folder1`;
  10) inside folder3 create test-job with build permissions for `poweruser`;
*/

import jenkins.model.*
import hudson.model.*
import hudson.security.*
import groovy.json.*
import java.util.*
import hudson.plugins.git.*;
import com.cloudbees.hudson.plugins.folder.*
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey
import com.cloudbees.plugins.credentials.CredentialsScope

//Manual define
def system_message    = "Hello from groovy script" // 1
def jenkins_email     = "Jenkins Admin <admin@notrealmail888.com>" // 2
def plugin_parameter  = "github matrix-project matrix-auth email-ext cloudbees-folder" // 3, 4, 5, latest version from Jenkins Update Center

def plugin_from_url   = "https://ci.jenkins.io/job/Plugins/job/slack-plugin/job/master/lastSuccessfulBuild/artifact/org/jenkins-ci/plugins/slack/2.49-rc598.955756034a9a/slack-2.49-rc598.955756034a9a.hpi"// 4, needed slack version from url - file
def plugin_url_name   = "slack" // 4, better plugin name, needed slack version from url - file

def SMTP_user         = "username" // 3
def SMTP_password     = "password" // 3
def SMTP_port         = "465" // 3
def SMTP_host         = "somenotrealdomain.sample.1234.com" //3
def SMTP_use_ssl      = true // 3

def slack_server_url  = "http://somerandomdomain.notreal.2345.com:80/" // 4
def slack_token       = "some123randomtockentext" // 4
def slack_team_domain = "jenkins-slack" // 4
def slack_room        = "#jenkins-builds" // 4

def folder_one        = "folder1" // 6
def folder_two        = "folder2" // 6
def folder_three      = "folder3" // 6

def library_name      = "compile_push_jar_docker" // 7
def library_git_path  = "https://github.com:GuardNexusGN/petclinic_temp.git" // 7

def library_version   = "master" // 7
def library_cred_name = "jenkins-lib-cred-petclinic" // 7
def library_cred_user = "jenkins-lib" // 7
def library_cred_key  = "ABCEF0123456789/0123456789ABCEF/111111111111111111222222222222222222" // 7

def secretname_cred   = "temp_user_pass" // 8
def secretdesc_cred   = "some temporary name nad pass" // 8
def username_cred     = "user_temp" // 8
def password_cred     = "password_temp" // 8

def create_power_user = true
def poweruser_login   = "poweruser"
def poweruser_pass    = "sd<Kf95k2;ddf0"

def access = [ // 9, 10
  admins: ["marko"],
  poweruser: ["poweruser"]
]

//Auto define
//def jenkins = Jenkins.getInstance()
Jenkins jenkins = Jenkins.getInstance()
def domain = Domain.global()
def mailServer = jenkins.getDescriptor("hudson.tasks.Mailer")
def store = jenkins.getExtensionList("com.cloudbees.plugins.credentials.SystemCredentialsProvider")[0].getStore()
def extmailServer = jenkins.getDescriptor("hudson.plugins.emailext.ExtendedEmailPublisher")
def slack = jenkins.getDescriptorByType(jenkins.plugins.slack.SlackNotifier.DescriptorImpl)
def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()
def pm = jenkins.getPluginManager()
def uc = jenkins.getUpdateCenter()
def installed = false
def initialized = false

//EMAIL + System Message
jenkinsLocationConfiguration.setAdminAddress(jenkins_email)
jenkins.setSystemMessage(system_message)

jenkins.save()
jenkinsLocationConfiguration.save()

//Plugins
def plugins = plugin_parameter.split()
println("Checking plugins")

plugins.each {
  println("  " + it)
  if (!pm.getPlugin(it)) {
    println("Looking UpdateCenter for " + it)
    if (!initialized) {
      uc.updateAllSites()
      initialized = true
    }
    
    def plugin = uc.getPlugin(it)
    
    if (plugin) {
      println("Installing " + it)
      def installFuture = plugin.deploy()
      while(!installFuture.isDone()) {
        println("Waiting for plugin install: " + it)
        sleep(3000)
      }
      installed = true
    }
  }
}

println("Additionally checking plugin " + plugin_url_name + " from url - file")

if (!pm.getPlugin(plugin_url_name)) {
  println("  Installing plugin " + plugin_url_name)
  print new ProcessBuilder( 'sh', '-c', 'wget -q -O ~/plugins/' + plugin_url_name + '.hpi ' + plugin_from_url).redirectErrorStream(true).start().text
  installed = true
}

jenkins.save()

//SMTP
println("Configuring SMTP")

mailServer.setSmtpAuth(SMTP_user, SMTP_password)
mailServer.setSmtpHost(SMTP_host)
mailServer.setSmtpPort(SMTP_port)
mailServer.setCharset("UTF-8")

extmailServer.setSmtpAuth(SMTP_user, SMTP_password)
extmailServer.setDefaultRecipients(jenkins_email)
extmailServer.setSmtpServer(SMTP_host)
extmailServer.setSmtpPort(SMTP_port)
extmailServer.setUseSsl(SMTP_use_ssl)
extmailServer.setCharset("utf-8")

extmailServer.defaultSubject="\$PROJECT_NAME - Build \$BUILD_NUMBER - \$BUILD_STATUS!"
extmailServer.defaultBody="\$PROJECT_NAME - Build \$BUILD_NUMBER - \$BUILD_STATUS:\n\nConsole output: \$BUILD_URL"

jenkins.save()

//Slack
println("Configuring Slack")

slack.baseUrl = slack_server_url
slack.teamDomain = slack_team_domain ?: ''
slack.tokenCredentialId = slack_token
slack.room = slack_room

slack.save()
jenkins.save()

//Credentials
println("Creating Username and Password credential")

usernameAndPassword = new UsernamePasswordCredentialsImpl(
  CredentialsScope.GLOBAL,
  secretname_cred,
  secretdesc_cred,
  username_cred,
  password_cred
)

store.addCredentials(domain, usernameAndPassword)

println("Creating SSH credential (for shared library)")

privateKey = new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(library_cred_key)

sshKey = new BasicSSHUserPrivateKey(
  CredentialsScope.GLOBAL,
  library_cred_name,
  library_cred_user,
  privateKey,
  "",
  ""
)

store.addCredentials(domain, sshKey)

jenkins.save()

//Folders
println("Creating folders and task")

def scm = new GitSCM("git@github.com:guardnexusgn/jenkins-temp.git") // Not in tasks, additional 
scm.branches = [new BranchSpec("*/master")]
scm.userRemoteConfigs[0].credentialsId = library_cred_name

def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, "Jenkinsfile")

if (jenkins.getItem(folder_one) == null && jenkins.getItem(folder_three) == null) {
  def folder = jenkins.createProject(Folder.class, folder_one)
  folder.createProject(Folder.class, folder_two)
  def folder_thr = jenkins.createProject(Folder.class, folder_three)
  
  def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(folder_thr, "test-job")
  job.definition = flowDefinition
  
  println("  Folders: " + folder_one + ", " + folder_two + ", " + folder_three + " created")
} else {
  println("  Folder(s) already existed - pass")
}

jenkins.reload()
jenkins.save()

//Shared library
import jenkins.plugins.git.GitSCMSource
import jenkins.plugins.git.traits.BranchDiscoveryTrait
import org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever
import org.jenkinsci.plugins.workflow.libs.LibraryConfiguration
import org.jenkinsci.plugins.workflow.libs.FolderLibraries

println("Adding library")

def scms = new GitSCMSource(library_git_path)
scms.credentialsId = library_cred_name
scms.traits = [new BranchDiscoveryTrait()]
def retriever = new SCMSourceRetriever(scms)
def library = new LibraryConfiguration(library_name, retriever)
library.defaultVersion = library_version
library.implicit = false
library.allowVersionOverride = true
library.includeInChangesets = false

List libraries = [library]

Folder fold_libs = jenkins.getItemByFullName(folder_one)
fold_libs.getProperties().add(new FolderLibraries(libraries))
fold_libs.save()

//Roles - RBAS
import com.michelin.cio.hudson.plugins.rolestrategy.*
import com.synopsys.arc.jenkins.plugins.rolestrategy.*
import org.jenkinsci.plugins.rolestrategy.permissions.PermissionHelper

if (create_power_user) {
  def hudsonRealm = new HudsonPrivateSecurityRealm(false)
  hudsonRealm.createAccount(poweruser_login, poweruser_pass)
  jenkins.setSecurityRealm(hudsonRealm)
  jenkins.save()
}

def globalRoleAdmin = "admin" // role names for global
def globalRoleRead = "read"

def folderRoleAccess = "poweruser-folder1" // role names for items
def folderItemRoleAccess = "poweruser-folder3"
def folderItemRoleAccesstwo = "poweruser-folder3-item"

def adminPermissions = [
"hudson.model.Hudson.Administer",
"hudson.model.Hudson.Read"
]

def globalReadPermissions = [
"hudson.model.Hudson.Read"
]

def buildPermissions = [
"hudson.model.Item.Read",
"hudson.model.Item.Build",
"hudson.model.Run.Replay"
]

def folderPermissions = [
"hudson.model.Item.Create",
"hudson.model.Item.Delete",
"hudson.model.Item.Configure",
"hudson.model.Item.Workspace",
"hudson.model.Item.Discover",
"hudson.model.Item.Build",
"hudson.model.Item.Cancel",
"hudson.model.Item.Read",
"hudson.model.Item.Move",
"hudson.model.Run.Update",
"hudson.model.Run.Delete",
"hudson.model.Run.Replay"
]

def roleBasedAuthenticationStrategy = new RoleBasedAuthorizationStrategy()
jenkins.setAuthorizationStrategy(roleBasedAuthenticationStrategy)

Set<Permission> adminPermissionSet = new HashSet<Permission>()
adminPermissions.each { p ->
  def permission = Permission.fromId(p)
  if (permission != null) {
    adminPermissionSet.add(permission)
  } else {
    println("${p} is not a valid permission ID (ignoring)")
  }
}

Set<Permission> globalPermissionSet = new HashSet<Permission>()
globalReadPermissions.each { p ->
  def permission = Permission.fromId(p)
  if (permission != null) {
    globalPermissionSet.add(permission)
  } else {
    println("${p} is not a valid permission ID (ignoring)")
  }
}

Set<Permission> buildPermissionsSet = new HashSet<Permission>()
buildPermissions.each { p ->
  def permission = Permission.fromId(p)
  if (permission != null) {
    buildPermissionsSet.add(permission)
  } else {
    println("${p} is not a valid permission ID (ignoring)")
  }
}

Set<Permission> folderRoleAccessSet = new HashSet<Permission>()
folderPermissions.each { p ->
  def permission = Permission.fromId(p)
  if (permission != null) {
    folderRoleAccessSet.add(permission)
  } else {
    println("${p} is not a valid permission ID (ignoring)")
  }
}

Role adminRole = new Role(globalRoleAdmin, adminPermissionSet)
roleBasedAuthenticationStrategy.addRole(RoleType.Global, adminRole)

Role globalReadRole = new Role(globalRoleRead, globalPermissionSet)
roleBasedAuthenticationStrategy.addRole(RoleType.Global, globalReadRole)

def folderRolePattern = "^" + folder_one + "\$" // folder1
def folderJobRolePattern = "^" + folder_three + "\$" // folder3
def folderJobRolePatternTwo = "^" + folder_three + "/test-job" + "\$" // folder3/test-item

Role folderRole = new Role(folderRoleAccess, folderRolePattern, folderRoleAccessSet)
roleBasedAuthenticationStrategy.addRole(RoleType.Project, folderRole)

Role folderThreeRole = new Role(folderItemRoleAccess, folderJobRolePattern, buildPermissionsSet)
roleBasedAuthenticationStrategy.addRole(RoleType.Project, folderThreeRole)

Role folderThreeJobRole = new Role(folderItemRoleAccesstwo, folderJobRolePatternTwo, buildPermissionsSet)
roleBasedAuthenticationStrategy.addRole(RoleType.Project, folderThreeJobRole)

access.poweruser.each { l ->
  println("Granting poweruser folder role to ${l}")
  roleBasedAuthenticationStrategy.assignRole(RoleType.Global, globalReadRole, l)
  roleBasedAuthenticationStrategy.assignRole(RoleType.Project, folderRole, l)
  roleBasedAuthenticationStrategy.assignRole(RoleType.Project, folderThreeRole, l)
  roleBasedAuthenticationStrategy.assignRole(RoleType.Project, folderThreeJobRole, l)
}

access.admins.each { l ->
  println("Granting admin role to ${l}")
  roleBasedAuthenticationStrategy.assignRole(RoleType.Global, adminRole, l)
}

jenkins.save()
jenkinsLocationConfiguration.save()

if (installed) {
  println("Plugins installed, initializing a restart!")
  jenkins.restart()
}
