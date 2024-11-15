pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id')
        DOCKER_IMAGE = "castlehoo/pipelinetest_image"
        DOCKER_TAG = "${BUILD_NUMBER}"
        ARGOCD_CREDENTIALS = credentials('argocd-auth')
        KUBE_CONFIG = credentials('eks-kubeconfig')
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
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    sh "echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    sh """
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins"
                        
                        # Git pull 전략 설정
                        git config pull.rebase false
                        
                        # main 브랜치로 전환하고 최신 상태로 업데이트
                        git checkout main
                        git pull origin main
                        
                        # deployment.yaml 업데이트
                        sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${DOCKER_TAG}|' k8s/deployment.yaml
                        
                        # 변경사항 커밋 및 푸시
                        git add k8s/deployment.yaml
                        git commit -m "Update deployment to version ${DOCKER_TAG}"
                        git push origin main
                    """
                }
            }
        }
        stage('Sync ArgoCD Application') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=${KUBE_CONFIG}
                        argocd login --username ${ARGOCD_CREDENTIALS_USR} --password ${ARGOCD_CREDENTIALS_PSW} --insecure
                        argocd app sync pipelinetest-app
                        argocd logout
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
