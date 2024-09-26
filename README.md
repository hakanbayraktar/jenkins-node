# Jenkins Pipeline EC2 Sunucuda Çalıştırma
Bu doküman, Jenkins Pipeline'ınızı bir EC2 sunucusu üzerinde çalıştırmak için gerekli adımları ve yapılandırmaları açıklar. Pipeline, node-jenkins adında bir Docker imajı oluşturur, Docker Hub'a yükler ve ardından EC2 sunucusunda çalışan docker konteynere dağıtır.
# Gereksinimler
**EC2 Sunucusu:** Jenkins Pipeline'ınızın bağlanabileceği, Docker yüklü ve SSH erişimi olan bir EC2 sunucusuna sahip olun.
*Jenkins Kurulumu:* Jenkins'in EC2 sunucusuna SSH ile erişimi olması ve Docker'ı çalıştırabilecek şekilde yapılandırılmış olması gerekir.
*Docker Hub Hesabı:* Pipeline, Docker imajını Docker Hub'a itmek için bir Docker Hub hesabı gerektirir.
**SSH Anahtarları:** Jenkins'in EC2 sunucusuna SSH ile bağlanabilmesi için, SSH kimlik doğrulaması yapılandırılmalıdır.

# 1. EC2 Sunucusunda Jenkins ve Docker Kurulumu
EC2 sunucusunda Jenkins ve Docker kurulumunu yapmak için kullanmanız gereken UserData script'i şu şekildedir:
```bash
#!/bin/bash
# Güncellemeleri yap
sudo apt-get update -y

# net-tools paketini kur
sudo apt-get install -y net-tools

# Jenkins'i kur 
curl -s https://raw.githubusercontent.com/hakanbayraktar/ibb-tech/refs/heads/main/devops/jenkins/install/jenkins-install.sh | sudo bash
#Docker kur
curl -s https://raw.githubusercontent.com/hakanbayraktar/ibb-tech/refs/heads/main/docker/ubuntu-24-docker-install.sh | sudo bash
```

# 2. Jenkins Pipeline İçin Gerekli Eklentiler
Jenkins'te aşağıdaki eklentilerin kurulu olduğundan emin olun:

**Docker Pipeline:** Docker container'lar ile çalışmak için gerekli.
**SSH Agent Plugin:** SSH anahtarlarıyla uzak sunuculara bağlanmak için gerekli.
**Credentials Binding Plugin:** Kimlik bilgilerini güvenli bir şekilde pipeline'a eklemek için kullanılır.
**Git Plugin:** Pipeline'da Git repository'lerini çekebilmek için gereklidir.
**github integration plugin**: webhook için gerekli

**Jenkins'e bu eklentileri yüklemek için:**

Manage Jenkins > Manage Plugins yolunu izleyin.
Available sekmesinde yukarıdaki eklentileri aratıp yükleyin.

# 3. Jenkins Pipeline İçin Kimlik Bilgilerini Ayarlayın
Jenkins Pipeline'da kullanılacak kimlik bilgileri Jenkins'te tanımlanmalıdır:

**Docker Hub Kimlik Bilgileri:**

Manage Jenkins > Manage Credentials yolunu izleyin.
Global scope'ta Add Credentials seçeneğini seçin.
**Kind:** Username with password
**ID:** dockerhub
Docker Hub kullanıcı adı ve şifrenizi girin.
EC2 SSH Kimlik Bilgileri:

Manage Jenkins > Manage Credentials yolunu izleyin.
**Kind:** SSH Username with private key
**ID:** jenkins-ssh
EC2 sunucusuna erişim sağlayan SSH private key'i girin.

# 4. Jenkinsfile Pipeline Script
Pipeline, aşağıdaki adımları takip eder:

Kodun İndirilmesi: Belirtilen GitHub reposundan (https://github.com/hakanbayraktar/jenkins-node) main branch'inden kod indirilir.
Build ve Test: Dockerfile kullanılarak Docker imajı oluşturulur.
Push: Docker imajı Docker Hub'a yüklenir.
Deploy: EC2 sunucusuna SSH ile bağlanılarak, Docker imajı çalıştırılır.
Jenkinsfile:
```bash 
pipeline {
    agent any
    stages {
        stage('Code') {
            steps {
                // Kodun GitHub'dan çekilmesi
                git url: 'https://github.com/hakanbayraktar/jenkins-node', branch: 'main'
            }
        }
        stage('Build and Test') {
            steps {
                // Docker imajı oluşturuluyor
                sh 'docker build . -t hbayraktar/node-jenkins:latest'
            }
        }
        stage('Push') {
            steps {
                // Docker Hub'a push yapılıyor
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
                    sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
                    sh 'docker push hbayraktar/node-jenkins:latest'
                }
            }
        }
        stage('Deploy') {
            steps {
                // EC2 sunucusuna SSH ile bağlanıp Docker konteynerini başlatma
                withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-ssh', keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY jenkins@54.172.139.238 '
                            docker rm -f cicd || true &&
                            docker run -d --name cicd -p 8000:8000 hbayraktar/node-jenkins:latest
                        '
                    '''
                }
            }
        }
    }
}
```
# 5. EC2 Sunucusunda Docker ve SSH Permission Ayarları
**Docker Kurulumu:** EC2 sunucusuna Docker kurulumunu yaptıktan sonra, Jenkins kullanıcısının Docker'ı root izni olmadan çalıştırabilmesi için kullanıcıyı docker grubuna ekleyin:

```bash
sudo usermod -aG docker jenkins
```
# ssh key oluştur docker servere bağlanabilmesi için
```bash
ssh-keygen -t rsa -b 4096 
```

**SSH Erişimi:** EC2 docker sunucusunda, Jenkins pipeline'da kullanılacak olan public key'i ~/.ssh/authorized_keys dosyasına ekleyin. Bu dosya şuna benzer olmalıdır:
```bash
echo "your-public-key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```
private key jenkinse eklenecek
Firewall Ayarları: EC2 güvenlik grubu üzerinden, Jenkins ve Docker'a erişimi sağlayacak gerekli portların (Jenkins için 8080,Docker için 8000) açık olduğundan emin olun.

# 6. Pipeline'ı Çalıştırın
Jenkins'te yeni bir pipeline oluşturun ve yukarıdaki Jenkinsfile'ı pipeline script olarak ekleyin. Pipeline çalıştırıldığında, adım adım:

Kodunuz https://github.com/hakanbayraktar/jenkins-node adresinden indirilir.
Docker imajı oluşturulur.
Docker Hub'a yüklenir.
EC2 sunucusuna dağıtılır ve konteyner başlatılır.
root kullanıcısının private key Jenkins kurulduktan sonra credentials kısmına eklenecek

pipeline
## jenkins credentials gir
docker token için credential id---> dockerhub

jenkins private key credential id---> jenkins-ssh

nodejs server IP credential id ---> SERVER_IP


# docker install

```bash
curl -s https://raw.githubusercontent.com/hakanbayraktar/ibb-tech/refs/heads/main/docker/ubuntu-24-docker-install.sh | sudo bash
```
# ubuntu kullanıcısına docker çalıştırma yetkisi ver
```bash
sudo usermod -aG docker ubuntu
sudo systemctl restart docker
sudo chmod 666 /var/run/docker.sock
```
Jenkins sunucu ubuntu kullanıcıya ait public key nodejs sunucunun /root/.ssh/authorized_keys dosyasına eklenmeli

# Configure Web-hook:
*** Github repositoryde yapılacaklar ***

reposotory-->Settings-->Webhooks---> Add webhook

Payload URL :  http://167.71.45.214:8080/github-webhook/

content type: application/json

Add Webhook

 *** Jenkins de yapılacaklar ***

 jenkins pipeline job seç
 configure-->Build triggers altında--->GitHub hook trigger for GITScm polling-->save