yum update
yum update kernel
yum update && yum upgrade
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install bash-completion bash-completion-extras
locate bash-completion.sh
source /etc/profile.d/bash_completion.sh  
yum install wget
yum install p7zip
yum install nano
yum -y install docker
systemctl start docker
systemctl enable docker
yum install -y hyperv-daemons
echo noop > /sys/block/sda/queue/scheduler
hostnamectl set-hostname "CentOS-Docker"
shutdown -r now
