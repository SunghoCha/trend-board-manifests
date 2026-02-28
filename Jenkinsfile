pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'sunghochacha/trend-board'
        APP_REPO_URL = 'https://github.com/SunghoCha/trend-board.git'
        APP_REPO_BRANCH = 'main'
    }

    stages {
        stage('소스 체크아웃') {
            steps {
                dir('app') {
                    git branch: "${APP_REPO_BRANCH}", url: "${APP_REPO_URL}"
                }
            }
        }

        stage('소스 빌드') {
            steps {
                dir('app') {
                    sh 'chmod +x ./gradlew'
                    sh './gradlew clean bootJar -x test'
                }
            }
        }

        stage('컨테이너 빌드 및 푸시') {
            steps {
                dir('app') {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-id',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker build -t ${DOCKERHUB_REPO}:${BUILD_NUMBER} ."
                        sh "docker push ${DOCKERHUB_REPO}:${BUILD_NUMBER}"
                    }
                }
            }
            post {
                always {
                    sh "docker rmi ${DOCKERHUB_REPO}:${BUILD_NUMBER} || true"
                    sh 'docker logout'
                }
            }
        }

        stage('매니페스트 이미지 태그 교체') {
            steps {
                sh "sed -i 's|image: ${DOCKERHUB_REPO}:.*|image: ${DOCKERHUB_REPO}:${BUILD_NUMBER}|' k8s/app-deployment.yaml"
            }
        }

        stage('K8s 배포') {
            steps {
                sh 'kubectl apply -f k8s/namespace.yaml'
                sh 'kubectl apply -f k8s/'
            }
        }

        stage('배포 검증') {
            steps {
                sh 'kubectl rollout status deployment/trend-board -n dealspot-dev --timeout=180s'
                sh 'echo "========== 배포 완료 =========="'
                sh 'kubectl get pods -n dealspot-dev'
                sh 'kubectl get svc -n dealspot-dev'
            }
        }
    }

    post {
        failure {
            echo '빌드 또는 배포에 실패했습니다.'
        }
        success {
            echo "배포 성공: ${DOCKERHUB_REPO}:${BUILD_NUMBER}"
        }
    }
}
