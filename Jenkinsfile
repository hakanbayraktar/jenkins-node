pipeline {
    agent any
    environment {
        SERVER_IP = credentials('SERVER_IP') // IP adresini secret'tan alıyoruz
    }
    stages {
        stage('Code') {
            steps {
                git url: 'https://github.com/hakanbayraktar/jenkins-node', branch: 'main'
            }
        }
        stage('Build and Test') {
            steps {
                sh 'docker build . -t hbayraktar/node-jenkins:latest'
            }
        }
        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
                    sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
                    sh 'docker push hbayraktar/node-jenkins:latest'
                }
            }
        }
        stage('Deploy') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-ssh', keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY root@$SERVER_IP << EOF
                            docker rm -f cicd || true
                            docker run -d --name cicd -p 8000:8000 hbayraktar/node-jenkins:latest
                        EOF
                    '''
                }
            }
        }
    }
}
