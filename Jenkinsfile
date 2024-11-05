pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id') // Docker Hub 자격증명
        ARGOCD_AUTH_TOKEN = credentials('argocd-auth-token') // ArgoCD 토큰을 여기에 호출
        ARGOCD_SERVER = 'https://localhost:8089'   // ArgoCD 서버 주소
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
                    // ArgoCD 애플리케이션 동기화
                    sh """
                    argocd login ${ARGOCD_SERVER} --insecure --grpc-web --username admin --password ${ARGOCD_AUTH_TOKEN}
                    argocd app sync <YOUR_APP_NAME> --auth-token=${ARGOCD_AUTH_TOKEN} --server=${ARGOCD_SERVER}
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
