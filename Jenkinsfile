pipeline{
    agent any
    environment {
        APP_NAME = "python-app"
        RELEASE = "1.0"
        IMAGE_TAG = "${RELEASE}.${BUILD_NUMBER}"
        JENKINS_API_TOKEN = credentials('JENKINS_API_TOKEN')
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
                    docker.withRegistry("https://${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com","ecr:${AWS_DEFAULT_REGION}:aws-cred") {
                    app.push("${IMAGE_TAG}")
                    app.push("latest")
                    }
                }
            }
        }
        stage('Trigger CD pipeline') {
            steps {
                script {
                    sh 'curl --user admin:${JENKINS_API_TOKEN} -X POST ${JENKINS_URL}/job/python-app-deploy/buildWithParameters?token=deploy-token -F IMAGE_TAG=${IMAGE_TAG}'
                }
            }
        }
    }
    post {
        failure {
            slackSend(channel: '#alerts', color: "danger", message: "${BUILD_TAG} failed!")
        }
    }
}
