#!/usr/bin/env groovy
@Library('compile_push_jar_docker') l1
//@Library('notify_slack') l2

env.PING_ONE   = "google.com"
env.PING_TWO   = "bing.com"
env.PING_THREE = "yahoo.com"

env.PING_TRIES = "3"

env.SKIP_BUILD_COMMIT = "SKIP_CI"

compile_push_jar_docker 'Task from compile_push_jar_docker are done'

//Other code from my old project
/*pipeline {
        stage('Test env version') {
                steps {
                        script {
                                try {
                                        timeout(time: 180, unit: 'SECONDS') {
                                                def user_input = input(
                                                id: 'userInput', message: 'Run QA ENV (enter none or version):', 
                                                parameters: [
                                                [$class: 'TextParameterDefinition', defaultValue: 'none', description: 'Docker image version', name: 'versiond'],
                                                ])

                                                if ("${user_input}" == "none") {
                                                        try {
                                                                sh ('docker stop qa_app')
                                                        } catch (Exception e) {
                                                                echo ('No qa docker container on background') 
                                                        }

                                                        echo ('No qa env selected, continuing...')        
                                                } else if ("${user_input}" == "latest") { 
                                                        sh ('docker login --username ${USERNAME_FORDOCKER} --password ${PASSWORD_FORDOCKER} docker.io')

                                                        try {
                                                                sh ('docker run --name qa_app -d -p ${QA_PORT}:${APP_PORT}/tcp ${REGISTRY_DOCKER}:${VERSION}')
                                                        } catch (Exception e) {
                                                                sh ('docker stop qa_app')
                                                                sh ('docker rm qa_app')
                                                                sh ('docker run -d --name qa_app -p ${QA_PORT}:${APP_PORT}/tcp ${REGISTRY_DOCKER}:${VERSION}')
                                                        }
                                                } else {
                                                        echo ("Selected version: ${user_input}")

                                                        sh ("docker login --username ${USERNAME_FORDOCKER} --password ${PASSWORD_FORDOCKER} docker.io")

                                                        try {
                                                                sh ("docker run -d --name qa_app -p ${QA_PORT}:${APP_PORT}/tcp ${REGISTRY_DOCKER}:${user_input}")
                                                        } catch (Exception e) {
                                                                sh ("docker stop qa_app")
                                                                sh ("docker rm qa_app")
                                                                sh ("docker run -d --name qa_app -p ${QA_PORT}:${APP_PORT}/tcp ${REGISTRY_DOCKER}:${user_input}")
                                                        }
                                                }
                                        }
                                } catch(err) {
                                       echo 'Input timeout'
                                }
                        }
                }
        }/*
        
        // Do not use lower
        /*agent {
                docker {
                    image 'maven:3.8.1-adoptopenjdk-11'
                    args '-v $HOME/.m2:/root/.m2'
                }
        }
            
        stages {
                stage('Build') {
                    steps {
                        sh 'mvn -B'
                    }
                }
        }
               
            
        stage('Build image') {
                steps {
                        script {
                                dockerImage = docker.build $REGISTRY_DOCKER:$BUILD_NUMBER --build-arg app_port=$APP_PORT
                        }
                }
        }
            
        stage('Deploy image') {
                steps {
                        script {
                                docker.withRegistry( '', $CREDENTIALS_DOCKER ) {
                                        dockerImage.push()
                               }
                        }
                }
        }
            
        stage('Remove local docker image') {
                steps {
                        sh "docker rmi $REGISTRY_DOCKER:$BUILD_NUMBER"
                }
        }
}*/
