# Ansible Terraform GCP lab
<h3>OpenSSH on Windows</h3>

To make OpenSSH feature available (ssh works normally, but ansible refuses to make a connection) needed to write code and put it in metadata (compute_template resource or module):
```
(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/GuardNexusGN/Ansible-on-Windows-OpenSHH/main/ssh_ansible.ps1','ssh_ansible.ps1'); ./ssh_ansible.ps1; echo 'YOUR PUB KEY' > C:/Users/ansible/.ssh/authorized_keys
```

Script upper does 3 things:	
- Downloads and enables openssh server
- Creates ansible user, generates random pass and adds public key	
- Creates firewall rule for ssh access

If needed password auth can be disabled (only private key login):
```
(gc C:\ProgramData\ssh\sshd_config) -replace "PasswordAuthentication yes", "PasswordAuthentication no" | sc C:\ProgramData\ssh\sshd_config
(gc C:\ProgramData\ssh\sshd_config) -replace "#PasswordAuthentication no", "PasswordAuthentication no" | sc C:\ProgramData\ssh\sshd_config
Restart-Service sshd
```

Code from ps1 script, for understanding:
```
#OpenSSH feature on windows
Add-WindowsCapability –Online –Name OpenSSH.Server~~~~0.0.1.0
Set-Service sshd –StartupType Automatic
Start-Service sshd
#New-ItemProperty –Path "HKLM:\SOFTWARE\OpenSSH" –Name DefaultShell –Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" –PropertyType String –Force
#Restart-Service sshd

#ansible user and key
$length = 10
$nonAlphaChars = 5
Add-Type –AssemblyName 'System.Web'
$user = "ansible"
$pass = ([System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars))
$secureString = ConvertTo-SecureString $pass –AsPlainText –Force
New-LocalUser –Name $user –Password $secureString
$credential = New-Object System.Management.Automation.PsCredential($user,$secureString)
$process = Start-Process cmd /c –Credential $credential –ErrorAction SilentlyContinue –LoadUserProfile
$newPass = ([System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars))
$newSecureString = ConvertTo-SecureString $newPass –AsPlainText –Force
Set-LocalUser –Name $user –Password $newSecureString
New-Item –Path "C:\Users\$user" –Name ".ssh" –ItemType Directory
$content = "PASTE YOUR PUBLIC SSH KEY HERE"
$content | Set-Content –Path "c:\users\$user\.ssh\authorized_keys"

#Firewall rule
New-NetFirewallRule -DisplayName 'OpenSSH' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22
```
