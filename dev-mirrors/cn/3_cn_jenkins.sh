#/var/jenkins_home/hudson.model.UpdateCenter.xml Change https://updates.jenkins.io/update-center.json to https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json
sudo docker container exec -it jenkins-blueocean bash
sed -i 's/https://updates.jenkins.io/update-center.json/https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json/g' /var/jenkins_home/hudson.model.UpdateCenter.xml
