#!groovy
import groovy.json.JsonSlurperClassic

def BUILD_NUMBER = env.BUILD_NUMBER
def SFDC_HOST = 'https://login.salesforce.com'
def SFDC_ORG_ALIAS = 'DemoSandbox'
def SFDC_HUB_USERNAME = 'lalitarora.sf@gmail.com' 
def JWT_KEY = '409a6643-2205-4031-a09f-1f9478fd7503'
def CONSUMER_KEY = '3MVG9ZL0ppGP5UrDARg58VXx7n5Z8skJa5gBQSgIPWSXgP9m9WAuFSHVEKvVyAhcDgdfP5e8ojkVuJqQe25Ww'
def RUN_ARTIFACT_DIR = "tests/${BUILD_NUMBER}"
def SFDC_USERNAME

 
    println JWT_KEY
    println SFDC_HUB_USERNAME
    println SFDC_HOST
    println CONSUMER_KEY

pipeline {
    agent any
		environment {
			ADX_IMAGE = 'appirio/dx:latest'
			SF_DEPLOY__ENABLED = true
		}

		
stage('deploy_to_devOrg') {
                    agent {
                        docker {
                            image '$ADX_IMAGE'
                            alwaysPull true
                        }
                    }
					
		steps{
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
			} 
		}
	}
}
