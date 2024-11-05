pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id')
        ARGOCD_SERVER = 'https://localhost:8090'  // 포트 8090으로 수정
        ARGOCD_AUTH_TOKEN = credentials('argocd-auth-token')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    def imageName = "castlehoo/pipelinetest_image:${env.BUILD_NUMBER}"
                    sh "docker build -t ${imageName} ."
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    def imageName = "castlehoo/pipelinetest_image:${env.BUILD_NUMBER}"
                    sh "echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin"
                    sh "docker push ${imageName}"
                }
            }
        }
        stage('Deploy to ArgoCD') {
            steps {
                script {
                    sh """
                    argocd login ${ARGOCD_SERVER} --insecure --grpc-web --username admin --password ${ARGOCD_AUTH_TOKEN}
                    argocd app sync pipelinetest --auth-token=${ARGOCD_AUTH_TOKEN} --server=${ARGOCD_SERVER}
                    """
                }
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}
