pipeline {
    agent any

    parameters {
        string(name: 'ENV', defaultValue: 'dev', description: 'Target Environment (dev/stage/prod)')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS Jenkins']]) {
                    dir('terraform-infra') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS Jenkins']]) {
                    dir('terraform-infra') {
                        sh "terraform plan -var='env=${params.ENV}'"
                    }
                }
            }
        }

        stage('Approval Stage') {
            when {
                expression { params.ENV in ['stage', 'prod'] && env.BRANCH_NAME == 'main' }
            }
            steps {
                input message: "Proceed to apply Terraform changes to ${params.ENV}?", ok: 'Deploy'
            }
        }

        stage('Terraform Apply') {
            when {
                allOf {
                    expression { env.BRANCH_NAME == 'main' }
                    anyOf { expression { params.ENV == 'dev' }; expression { currentBuild.inputApproved } }
                }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS Jenkins']]) {
                    dir('terraform-infra') {
                        sh "terraform apply -auto-approve -var='env=${params.ENV}'"
                    }
                }
            }
        }

        stage('Docker Build') {
            when {
                allOf {
                    expression { env.BRANCH_NAME == 'main' }
                    expression { params.ENV == 'dev' }
                }
            }
            steps {
                sh 'docker build -t myapp:latest ./app'
            }
        }

        stage('Docker Push to DockerHub') {
            when {
                allOf {
                    expression { env.BRANCH_NAME == 'main' }
                    expression { params.ENV == 'dev' }
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    sh 'docker tag myapp:latest fareedahamed/myapp:latest'
                    sh 'docker push fareedahamed/myapp:latest'
                }
            }
        }
    }

    post {
        success { echo "Pipeline successful for environment ${params.ENV}" }
        failure { echo "Pipeline failed!" }
    }
}