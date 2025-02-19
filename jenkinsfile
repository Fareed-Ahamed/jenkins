pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS Jenkins').USR
        AWS_SECRET_ACCESS_KEY = credentials('AWS Jenkins').PSW
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
    }

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
                dir('terraform-infra') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform-infra') {
                    sh "terraform plan -var='env=${params.ENV}'"
                }
            }
        }

        stage('Approval Stage') {
            when {
                expression { params.ENV in ['stage', 'prod'] && env.BRANCH_NAME == 'master' }
            }
            steps {
                input message: "Deploy to ${params.ENV}?", ok: 'Proceed'
            }
        }

        stage('Terraform Apply') {
            when {
                allOf {
                    expression { env.BRANCH_NAME == 'master' }
                    anyOf { expression { params.ENV == 'dev' }; expression { currentBuild.inputApproved } }
                }
            }
            steps {
                dir('terraform-infra') {
                    sh "terraform apply -auto-approve -var='env=${params.ENV}'"
                }
            }
        }

        stage('Docker Build') {
            when {
                allOf {
                    expression { env.BRANCH_NAME == 'master' }
                    expression { params.ENV == 'dev' }
                }
            }
            steps {
                sh 'docker build -t myapp:latest ./app'
            }
        }

        stage('Docker Push') {
            when {
                allOf {
                    expression { env.BRANCH_NAME == 'master' }
                    expression { params.ENV == 'dev' }
                }
            }
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker tag myapp:latest yourdockerhubusername/myapp:latest'
                sh 'docker push yourdockerhubusername/myapp:latest'
            }
        }
    }

    post {
        success { echo "Pipeline successful for environment ${params.ENV}" }
        failure { echo "Pipeline failed!" }
    }
}