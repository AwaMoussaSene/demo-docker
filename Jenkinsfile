pipeline {
    agent any

    options {
        timestamps()
    }

    environment {
        // Pour Windows avec Docker Desktop exposé sur TCP
        // 
        DOCKER_HOST = "tcp://localhost:2375"

        // Credentials Jenkins
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
                bat 'docker info || (echo Docker daemon non disponible & exit 1)'
            }
        }

        stage("Build & Push Docker Image") {
            steps {
                script {
                    // Récupère le nom de branche fourni par Jenkins
                    def src = (env.BRANCH_NAME ?: env.GIT_BRANCH ?: 'mester')
                    def safeTag = src.replaceAll('[^A-Za-z0-9._-]', '-')
                    def imageTag = "${IMAGE_NAME}:${safeTag}-${env.BUILD_NUMBER}"
                    def latestImageTag = "${IMAGE_NAME}:latest"

                    echo "🐳 Construction de l'image Docker: ${imageTag}"

                    // Login et build Docker
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                        def app = docker.build(imageTag, '.')
                        echo "📤 Publication de l'image Docker: ${imageTag}"
                        app.push()
                        app.push("latest")
                    }

                    echo "✅ Image Docker construite et publiée avec succès."
                }
            }
        }

        stage("Deploy to Render (Test Environment)") {
            steps {
                echo "🚀 Déclenchement du déploiement sur Render..."
                withCredentials([string(credentialsId: 'render-webhook', variable: 'HOOK_URL')]) {
                    // Utilisation de bat pour Windows
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
