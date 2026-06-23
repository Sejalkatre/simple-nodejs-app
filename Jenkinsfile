pipeline {
agent any


environment {
    APP_NAME     = "simple-nodejs-app"
    APP_VERSION  = "1.0"
    IMAGE_TAG    = "${BUILD_NUMBER}"
    DOCKER_IMAGE = "sejalkatre/simple-nodejs-app:${IMAGE_TAG}"
}

stages {

    stage('Checkout Code') {
        steps {
            git branch: 'main',
                credentialsId: 'github-creds',
                url: 'https://github.com/Sejalkatre/simple-nodejs-app.git'
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
                sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
            }
        }
    }

    stage('Push Image') {
        steps {
            sh 'docker push ${DOCKER_IMAGE}'
        }
    }

    stage('Checkout Manifest Repo') {
        steps {
            dir('manifest-repo') {
                git branch: 'main',
                    credentialsId: 'github-creds',
                    url: 'https://github.com/Sejalkatre/simple-nodejs-manifests.git'
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
                        sed -i 's|image:.*|image: ${DOCKER_IMAGE}|g' k8s/deployment.yaml

                        git config user.name "jenkins"
                        git config user.email "jenkins@local"

                        
                        git init
                        git add .
                        git commit -m "Updated image to build ${IMAGE_TAG}" 

                        git push https://\$GIT_USER:\$GIT_PASS@github.com/Sejalkatre/simple-nodejs-manifests.git main
                    """
                }
            }
        }
    }
}

post {

    success {
        emailext(
            to: 'sejalkatre021@gmail.com',
            subject: "SUCCESS: ${JOB_NAME} #${BUILD_NUMBER}",
            body: """
```

Build Successful

Application : ${APP_NAME}
Version     : ${APP_VERSION}
Image       : ${DOCKER_IMAGE}

Build URL:
${BUILD_URL}
"""
)
}


    failure {
        emailext(
            to: 'sejalkatre021@gmail.com',
            subject: "FAILED: ${JOB_NAME} #${BUILD_NUMBER}",
            body: """
```

Build Failed

Job Name     : ${JOB_NAME}
Build Number : ${BUILD_NUMBER}

Build URL:
${BUILD_URL}
"""
)
}

    always {
        cleanWs()
    }
}


}
