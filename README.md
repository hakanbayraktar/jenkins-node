# Gereksinimler
1-Jenkins için ubuntu server
2-Nodejs için ubuntu server
3-Jenkins sunucusuna ait ssh key public private key 
4-docker hub user password

# Jenkins Server Configuration
Docker ve Jenkins programları kurulmalı
SSH key oluşturmalı

# ssh key oluştur nodejs servere bağlanabilmesi için
ssh-keygen -t rsa -b 4096 
root kullanıcısının private key Jenkins kurulduktan sonra credentials kısmına eklenecek

# Jenkins install
```bash
curl -s https://raw.githubusercontent.com/hakanbayraktar/ibb-tech/refs/heads/main/devops/jenkins/install/jenkins-install.sh | sudo bash
```

Jenkins Web kurulumunu bitir.
## kurulacak pluginler
github integration
pipeline
## jenkins credentials gir
docker token için credential id---> dockerhub

jenkins private key credential id---> jenkins-ssh

nodejs server IP credential id ---> SERVER_IP


# docker install

```bash
curl -s https://raw.githubusercontent.com/hakanbayraktar/ibb-tech/refs/heads/main/docker/ubuntu-24-docker-install.sh | sudo bash
```
# Jenkins kullanıcısına docker çalıştırma yetkisi ver
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
sudo chmod 666 /var/run/docker.sock
```



# Nodejs Sunucu Configuration

# docker install

```bash
curl -s https://raw.githubusercontent.com/hakanbayraktar/ibb-tech/refs/heads/main/docker/ubuntu-24-docker-install.sh | sudo bash
```
Jenkins suncu root kullanıcıya ait public key nodejs sunucunun /root/.ssh/authorized_keys dosyasına eklenmeli

# Configure Web-hook:
*** Github repositoryde yapılacaklar ***

reposotory-->Settings-->Webhooks---> Add webhook

Payload URL :  http://167.71.45.214:8080/github-webhook/

content type: application/json

Add Webhook

 *** Jenkins de yapılacaklar ***

 jenkins pipeline job seç
 configure-->Build triggers altında--->GitHub hook trigger for GITScm polling-->save