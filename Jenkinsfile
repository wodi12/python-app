pipeline{
    agent any
    stages {
        stage('Check out code') {
            steps {
                git branch: 'main', url: 'https://github.com/wodi12/helloworld.git'
            }
        }
        stage('Build the code') {
            steps {
                script {
                    app = docker.build("hello-world")
                }
            }
        }
        stage('Push image to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${env.ACCOUNT_ID}.dkr.ecr.us-east-2.amazonaws.com",'ecr:us-east-2:aws-login') {
                    app.push("${env.BUILD_NUMBER}")
                    app.push("latest")
                    }
                }
            }
        }
    }
}
