pipeline {


agent any

environment {
    APP_NAME = "simple-nodejs-app"
    APP_VERSION = "1.0"
    IMAGE_TAG = "${BUILD_NUMBER}"
    DOCKER_IMAGE = "sejalkatre/simple-nodejs-app:${IMAGE_TAG}"
}

stages {

    stage('Checkout Code') {
        steps {
            git(
                branch: 'main',
                credentialsId: 'github-creds',
                url: 'https://github.com/Sejalkatre/simple-nodejs-app.git'
            )
        }
    }

    stage('Build Image') {
        steps {
            sh """
                docker build \
                --build-arg APP_NAME=${APP_NAME} \
                --build-arg APP_VERSION=${APP_VERSION} \
                -t ${DOCKER_IMAGE} .
            """
        }
    }

    stage('Login DockerHub') {
        steps {
            withCredentials([
                usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )
            ]) {
                sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                '''
            }
        }
    }

    stage('Push Image') {
        steps {
            retry(3) {
                sh '''
                    docker push $DOCKER_IMAGE
                '''
            }
        }
    }

    stage('Checkout Manifest Repo') {
        steps {
            dir('manifest-repo') {
                git(
                    branch: 'main',
                    credentialsId: 'github-creds',
                    url: 'https://github.com/Sejalkatre/simple-nodejs-manifests.git'
                )
            }
        }
    }

    stage('Update Manifest') {
        steps {
            dir('manifest-repo') {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'github-creds',
                        usernameVariable: 'GIT_USER',
                        passwordVariable: 'GIT_PASS'
                    )
                ]) {
                    sh """
                        sed -i 's|image:.*|image: sejalkatre/simple-nodejs-app:${IMAGE_TAG}|g' k8s/deployment.yaml

                        git config user.name "jenkins"
                        git config user.email "jenkins@local"

                        git add k8s/

                        git commit -m "Updated image to build ${IMAGE_TAG}" || echo "No changes"

                        git push https://\$GIT_USER:\$GIT_PASS@github.com/Sejalkatre/simple-nodejs-manifests.git main
                    """
                }
            }
        }
    }
}

 post {

    success {
        echo "✅ Pipeline Successful"
        echo "Docker Image: ${IMAGE_NAME}:${env.NEW_TAG}"

        mail(
            to: 'sejalkatre021@gmail.com',
            subject: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: """
Pipeline Status : SUCCESS

Job Name     : ${env.JOB_NAME}
Build Number : ${env.BUILD_NUMBER}
Docker Image : ${IMAGE_NAME}:${env.NEW_TAG}

GitOps repository updated successfully.

Build URL:
${env.BUILD_URL}
"""
        )
    }

    failure {
        echo "❌ Pipeline Failed"

        mail(
            to: 'sejalkatre021@gmail.com',
            subject: "FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: """
Pipeline Status : FAILURE

Job Name     : ${env.JOB_NAME}
Build Number : ${env.BUILD_NUMBER}

Please check the Jenkins console logs.

Build URL:
${env.BUILD_URL}
"""
        )
    }

    always {
        cleanWs()
    }
}
}
