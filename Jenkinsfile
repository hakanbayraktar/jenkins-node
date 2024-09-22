pipeline {
    agent any
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
                withCredentials([usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
                    sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
                    sh 'docker push hbayraktar/node-jenkins:latest'
                }
            }
        }
        stage('Deploy') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-server', keyFileVariable: 'SSH_KEY')]) {
                     sh '''
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY root@68.183.103.190 "
                            CONTAINER_ID=\$(docker ps -q --filter ancestor=hbayraktar/node-jenkins:latest);
                            if [ ! -z "\$CONTAINER_ID" ]; then 
                                docker rm -f \$CONTAINER_ID; 
                            fi;
                            docker run -d -p 8000:8000 hbayraktar/node-jenkins:latest
                        "
                    '''
                }
            }
        }
    }
}
