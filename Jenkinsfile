pipeline {
    agent { label 'django-slave' }
    options { disableConcurrentBuilds() }
    stages {
        stage('Build') {
            steps {
                sh 'chmod 777 ${WORKSPACE}/build_scripts/build_script.sh'
				sh "bash -c \". ${WORKSPACE}/build_scripts/build_script.sh \""
            }
        }
        stage('Copy Artifacts') {
            steps {
                sh 'chmod 777 ${WORKSPACE}/build_scripts/copy_artifacts.sh'
			    sh "bash -c \". ${WORKSPACE}/build_scripts/copy_artifacts.sh \""
            }
        }
        stage('Deploy') {
            steps {
                sh 'chmod 777 ${WORKSPACE}/build_scripts/deployment_scripts.sh'
			    sh "bash -c \". ${WORKSPACE}/build_scripts/deployment_scripts.sh \""
            }
        }
    }
    post {
        always {
            sh 'chmod 777 ${WORKSPACE}/build_scripts/send_mail.sh'
		    sh "bash -c \". ${WORKSPACE}/build_scripts/send_mail.sh ${currentBuild.currentResult} \""
		    cleanWs notFailBuild: true
            
        }
    }
}