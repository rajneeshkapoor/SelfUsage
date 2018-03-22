publicIP="192.168.15.2"
echo "Public IP : ${publicIP}"
sed -i '/nameserver/a nameserver 8.8.8.8' /etc/resolv.conf
apt-get update
apt-get -y install ansible
wget https://${publicIP}/tvault-ansible-scripts.tar.gz --no-check-certificate
