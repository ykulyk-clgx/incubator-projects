#Jenkins lab

<h1>Little jenkins lab documentaion</h1>

<h3>What is it</h3>

A sample of Jenkins repo, used to test and show pipeline knowledge and usage. 

Simple application, based on spring boot "petclinic" project. With Jenkins file (pipeline) inside. 

Consists of: Jenkinsfile, Dockerfile, mvnw proj, ansible role.

<h3>How it works:</h3>

  * On every git push - Jenkins automatically triggers on master + asks worker to: run maven build, ping in parallel, exec ansible-playbook role.
  * Ansible role: takes jar build, reads Dockerfile (opendjk container, copy jar file, port, run), runs Dockerfile, push created container to docker hub.

<h3>How to run:</h3>

  1) Start Jenkins Server, add Jenkins worker (label: 'Jenkins-node-1')
  2) Install 'pipeline scripts', 'maven integration' and 'slack notification' plugins (+github)
  3) Open repo, edit Jenkinsfile, change values
  4) Add pull webhook in current repo to `http://[ip]:[port]/ghprbhook` (push + pull)
  5) Create a folder in Jenkins, put it inside the new multibranch pipeline project (use matrix if needed)
  6) Add git + docker credentials and slack token to credentials (slack plugin - security: `https://plugins.jenkins.io/slack`) 
  7) Add Github as a source, allow scan and pull checks
  8) Wait for repository scan and build

<h3>Structure:</h3>

  <h4>Files and folders:</h4>

  * .mvn - [folder] hidden mvn folder, needed for build, compilcations and tests
  * devotools - [folder] ansible roles folder
  * src - [folder] source files with htmls form compilation
  * target - [folder] target folder, where compiled.jar file and run settings are stored
  * vars - [folder] Jenkins shared library folder
  * .editorconfig - [file] needed for maven, parameters for filetypes
  * Dockerfile - [file] file for Docker, used for docker build
  * Jenkinsfile - [file] file for Jenkins, instructions for pipeline run
  * mvnw - [file] maven, a build automation tool
  * pow.xml - [file] xlm file, instructions for maven build

<h3>Given tasks:</h3>

  * connect static slave node
  * create declarative job
  * add parameter environment
  * trigger on push and pr
  * skip building if the commit message is "SKIP_CI"
  * create a zip file with suffix $BRANCH_NAME and store it like artifact and build_number
  * create a shared library to send slack notification with build status
  * in parallel, ping three different servers, and if ping fails - stop the job
  * move all logic to shared library

<h3>Additionally, given part two:</h3>

It should be placed in task2.groovy file, be runable with Jenkins Script Console and do such tasks as:

  * setup system message
  * setup global admin email address
  * setup smtp server
  * setup slack
  * setup github
  * create three folders `/folder1`, `/folder1/folder2` and `folder3`
  * for `folder1` configure your shared library
  * create credentials `USERNAME` and `PASSWORD`
  * create group and role `poweruser` and assing it to `folder1`
  * inside folder3 create test-job with build permissions for `poweruser`

