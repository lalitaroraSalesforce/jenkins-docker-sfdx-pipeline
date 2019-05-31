#!groovy
import groovy.json.JsonSlurperClassic

def BUILD_NUMBER = env.BUILD_NUMBER
def SFDC_HOST = 'https://login.salesforce.com'
def SFDC_ORG_ALIAS = 'DemoSandbox'
def SFDC_HUB_USERNAME = 'testUsenameJenkinsCredId' 
def JWT_KEY = 'testJwtJenkinsCredId'
def CONSUMER_KEY = 'testConsumerKeyJenkinsCredId'
def RUN_ARTIFACT_DIR = "tests/${BUILD_NUMBER}"
def SFDC_USERNAME



pipeline {
    agent {
        dockerfile {
            dir '.'
            filename 'Dockerfile'
            additionalBuildArgs '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
            label 'jenkins-slave'
        }
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Org Authorization') {  
            steps {
                script {
                    withCredentials([
                        file(credentialsId: JWT_KEY, variable: 'jwt_key_file'), 
                        string(credentialsId: SFDC_HUB_USERNAME, variable: 'username'),
                        string(credentialsId: CONSUMER_KEY, variable: 'consumer_key')
                    ]) {
                        rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${consumer_key} --username ${username} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST}  --setalias ${SFDC_ORG_ALIAS}"
                        if (rc != 0){
                            error 'ORG authorization failed'
                        }
                        dmsg = sh returnStdout: true, script: "sfdx force:config:set defaultusername=${SFDC_ORG_ALIAS} --global"
                        print dmsg
                        lmsg = sh returnStdout: true, script: "sfdx force:org:list --all"
                        print lmsg
                    }
                }
            } 
        }
        
        stage('Create Scratch Org') {
            steps {
                script {
                    rmsg = sh returnStdout: true, script: "sfdx force:org:create --definitionfile config/project-scratch-def.json --json --setdefaultusername"
                    printf rmsg
                    def jsonSlurper = new JsonSlurperClassic()
                    def robj = jsonSlurper.parseText(rmsg)
                    if (robj.status != 0) { error 'org creation failed: ' + robj.message }
                    SFDC_USERNAME=robj.result.username
                    robj = null
                }
            }
        }

        stage('Push To Test Org') {
            steps {
                script {
                    rc = sh returnStatus: true, script: "sfdx force:source:push --targetusername ${SFDC_USERNAME}"
                    if (rc != 0) {
                        error 'push failed'
                    }
                    // assign permset
                    rc = sh returnStatus: true, script: "sfdx force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname DreamHouse"
                    if (rc != 0) {
                        error 'permset:assign failed'
                    }
                }
            }
        }
        
        stage('Run Apex Test') {
            steps {
                script {
                    sh "mkdir -p ${runArtifactDir}"
                    timeout(time: 120, unit: 'SECONDS') {
                        rc = sh returnStatus: true, script: "sfdx force:apex:test:run --testlevel RunLocalTests --outputdir ${RUN_ARTIFACT_DIR} --resultformat tap --targetusername ${SFDC_USERNAME}"
                        if (rc != 0) {
                            error 'apex test run failed'
                        }
                    }
                }
            }
        }

        stage('Collect results ') {
            steps {
                script {
                    junit keepLongStdio: true, testResults: 'tests/**/*-junit.xml'
                }
            }
        }
    }
    
    post {
        always {
            deleteDir()
            
        }
    }   
}