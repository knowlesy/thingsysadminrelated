sudo su
df -h
mkdir logs
mkdir scripts
apt-get update
apt-get upgrade
apt-get dist-upgrade
rpi-update
apt-get install sshpass
apt-get install wget
apt-get install dnsutils
apt-get install p7zip
apt-get install iftop
apt-get install fail2ban
service fail2ban start
cp /etc/fail2ban/jail.conf
service fail2ban restart
fail2ban-client status
sudo passwd -dl root
raspi-config
shutdown -r now
sudo su
curl -sSL https://install.pi-hole.net | bash
shutdown -r now
sudo su
curl -L https://install.pivpn.io | bash
sudo su
apt-get update
apt-get upgrade
