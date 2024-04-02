pipeline{
    agent any
    environment {
        APP_NAME = "python-app"
        RELEASE = "1.0.0"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
        JENKINS_API_TOKEN = credentials("JENKINS_API_TOKEN")
    }
    stages {
        stage('Check out code') {
            steps {
                git branch: 'main', url: 'https://github.com/wodi12/python-app.git'
            }
        }
        stage('Build the code') {
            steps {
                script {
                    app = docker.build("${APP_NAME}")
                }
            }
        }
        stage('Push image to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${ACCOUNT_ID}.dkr.ecr.us-east-2.amazonaws.com",'ecr:us-east-2:aws-cred') {
                    app.push("${IMAGE_TAG}")
                    app.push("latest")
                    }
                }
            }
        }
    }
}
