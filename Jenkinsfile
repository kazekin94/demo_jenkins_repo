def common;
pipeline {
    agent { label 'django-slave' }
    options {
        disableConcurrentBuilds()
    }
    stages {
        stage('Build') { 
            steps {
			sh 'chmod 777 ${WORKSPACE}/deployment_script/build_script.sh'
			sh "bash -c \". ${WORKSPACE}/deployment_script/build_script.sh \""
            }
        }
        stage('Copy Artifacts') { 
            steps {
			sh 'chmod 777 ${WORKSPACE}/deployment_script/copy_artifacts.sh'
			sh "bash -c \". ${WORKSPACE}/deployment_script/copy_artifacts.sh \""
            }
        }
		stage('Deploy') { 
			steps {
			    sh 'chmod 777 ${WORKSPACE}/deployment_script/deploy_script.sh'
			    sh "bash -c \". ${WORKSPACE}/deployment_script/deploy_script.sh \""
			}
		}
    }
	post {
        always {
		    sh 'chmod 777 ${WORKSPACE}/deployment_script/send_mail.sh'
		    sh "bash -c \". ${WORKSPACE}/deployment_script/send_mail.sh ${currentBuild.currentResult} \""
		    cleanWs notFailBuild: true
        }
    }
}
