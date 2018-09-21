#!/bin/bash

## see: https://youtu.be/aqXSbDZggK4

## Default variables to use
export DOMAIN=${DOMAIN:="$(curl -s ipinfo.io/ip).nip.io"}

# install updates
yum update -y

# install the following base packages
yum install -y  wget git zile nano htop net-tools docker-1.13.1 bind-utils iptables-services  bridge-utils bash-completion  kexec-tools sos psacct openssl-devel  httpd-tools NetworkManager  python-cryptograpy python2-pip python-devel  python-passlib  java-1.8.0-openjdk-headless

#install epel
yum -y install epel-release

# Disable the EPEL repository globally so that is not accidentally used during later steps of the installation
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo

systemctl status NetworkManager

# install the packages for Ansible
yum -y --enablerepo=epel install ansible pyOpenSSL

 git clone https://github.com/openshift/openshift-ansible.git

/et

cat <<EOD > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
${IP}		$(hostname) console console.${DOMAIN}  
EOD

if [ ! -f ~/.ssh/id_rsa ]; then
	ssh-keygen -q -f ~/.ssh/id_rsa -N ""
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
	ssh -o StrictHostKeyChecking=no root@$IP "pwd" < /dev/null
fi


##NFS

yum install -y nfs* 

mkdir -p /exports
chmod 777 /exports


curl -o inventory.download $SCRIPT_REPO/inventory.ini
envsubst < inventory.download > inventory.ini

ansible-playbook -i inventory.ini openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i inventory.ini openshift-ansible/playbooks/deploy_cluster.yml

htpasswd -b /etc/origin/master/htpasswd ${USERNAME} ${PASSWORD}
oc adm policy add-cluster-role-to-user cluster-admin ${USERNAME}

echo "******"
echo "* Your console is https://console.$DOMAIN:$API_PORT"
echo "* Your username is $USERNAME "
echo "* Your password is $PASSWORD "
echo "*"
echo "* Login using:"
echo "*"
echo "$ oc login -u ${USERNAME} -p ${PASSWORD} https://console.$DOMAIN:$API_PORT/"
echo "******"
