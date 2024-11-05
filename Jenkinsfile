pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id')
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
        stage('Start Port Forwarding') {
            steps {
                sh "kubectl port-forward svc/argocd-server -n argocd 8090:443 &"
                // 포트 포워딩이 시작된 후 잠시 대기 (연결 안정화용)
                sleep 5
            }
        }
        stage('Deploy to ArgoCD') {
            steps {
                withCredentials([string(credentialsId: 'argocd-auth-token', variable: 'ARGOCD_AUTH_TOKEN')]) {
                    sh '''
                    export ARGOCD_AUTH_TOKEN=$ARGOCD_AUTH_TOKEN
                    argocd login localhost:8090 --insecure --grpc-web --username admin --password $ARGOCD_AUTH_TOKEN
                    argocd app sync pipelinetest --auth-token=$ARGOCD_AUTH_TOKEN --server=localhost:8090
                    '''
                }
            }
        }
    }
    post {
        always {
            // 포트 포워딩 프로세스 종료
            sh "pkill -f 'kubectl port-forward svc/argocd-server -n argocd 8090:443'"
            sh 'docker logout'
        }
    }
}
