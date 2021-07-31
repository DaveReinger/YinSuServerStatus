#!/bin/bash
# ENV
BASE_PATH=/root/
quick_install_path=$BASE_PATH/quick_install_shell

# 生成环境变量
read -p "id==(s01)" serverstatusUser

echo "export serverstatusUser=$serverstatusUser"  >> /etc/profile

read -p "master_ip=:" master_ip

echo "export master_ip=$master_ip"  >> /etc/profile

# 安装基本组件
yum install wget lrzsz vim wget bash-com* net-tools -y && systemctl stop firewalld && systemctl disable firewalld && sed -i 's/SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config && setenforce 0 

# 探针
wget --no-check-certificate -qO $quick_install_path/client-linux.py 'https://raw.githubusercontent.com/cppla/ServerStatus/master/clients/client-linux.py' 
sed -i "s/SERVER =.*$/SERVER = \"$master_ip\"/g" $quick_install_path/client-linux.py
sed -i "s/USER =.*$/USER =\"$serverstatusUser\"/g" $quick_install_path/client-linux.py


cat > yinsustatus.service <<EOF
[Unit]
Description=YinSuStatus https://niubi.ilaosiji.xyz davereinger@outlook.com
After=rc-local.service

[Service]
Type=simple
ExecStart=/usr/bin/python $quick_install_path/client-linux.py
ExecReload=/bin/kill -SIGHUP \$MAINPID
ExecStop=/bin/kill -SIGINT \$MAINPID
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target

EOF



# 以754的权限保存在目录： /usr/lib/systemd/system 
cp yinsustatus.service /usr/lib/systemd/system
chmod 754 /usr/lib/systemd/system/yinsustatus.service
systemctl stop yinsustatus && systemctl start yinsustatus && systemctl status yinsustatus
systemctl enable yinsustatus
