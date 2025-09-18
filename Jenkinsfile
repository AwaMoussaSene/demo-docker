pipeline {
    agent any

    options {
        timestamps()
    }

    environment {
        // Tes credentials Jenkins
        DOCKERHUB_CREDS = credentials("dockerhub-creds") 
        RENDER_DEPLOY_HOOK = credentials("render-webhook") 
        IMAGE_NAME = "${DOCKERHUB_CREDS_USR}/demo-jenkins"
    }

    triggers {
        githubPush() // Déclenchement automatique sur push GitHub
    }

    stages {
        stage("Checkout") {
            steps {
                echo "📥 Récupération du code source..."
                checkout scm
            }
        }

        stage("Verify Docker") {
            steps {
                echo "🔍 Vérification du daemon Docker..."
                bat """
                    docker info || (
                        echo Docker daemon non disponible
                        exit 1
                    )
                """
            }
        }

        stage("Build & Push Docker Image") {
            steps {
                script {
                    // Récupère le nom de branche fourni par Jenkins (multibranch ou fallback)
                    def src = (env.BRANCH_NAME ?: env.GIT_BRANCH ?: 'mester')
                    def safeTag = src.replaceAll('[^A-Za-z0-9._-]', '-')
                    def imageTag = "${IMAGE_NAME}:${safeTag}-${env.BUILD_NUMBER}"
                    def latestImageTag = "${IMAGE_NAME}:latest"

                    echo "🐳 Construction de l'image Docker: ${imageTag}"

                    // Build l'image
                    bat "docker build -t ${imageTag} ."

                    // Login Docker Hub
                    bat """
                        docker login -u ${DOCKERHUB_CREDS_USR} -p ${DOCKERHUB_CREDS_PSW}
                    """

                    // Push des tags
                    bat "docker push ${imageTag}"
                    bat "docker tag ${imageTag} ${latestImageTag}"
                    bat "docker push ${latestImageTag}"

                    echo "✅ Image Docker construite et publiée avec succès."
                }
            }
        }

        stage("Deploy to Render (Test Environment)") {
            steps {
                echo "🚀 Déclenchement du déploiement sur Render..."
                withCredentials([string(credentialsId: 'render-webhook', variable: 'HOOK_URL')]) {
                    bat "curl -i -X POST \"${HOOK_URL}\""
                }
                echo "✅ Déploiement déclenché."
            }
        }
    }

    post {
        always {
            cleanWs()
            echo "✨ Pipeline terminé."
        }
        success {
            echo "🎉 Succès: Le pipeline s'est terminé avec succès!"
        }
        failure {
            echo "❌ Échec: Le pipeline a échoué."
        }
    }
}
