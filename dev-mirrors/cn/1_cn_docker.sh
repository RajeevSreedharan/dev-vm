#!/bin/bash

# docker hub network issue, choosing closest mirror near my current location
# https://registry.docker-cn.com        Docker (CN)
# http://hub-mirror.c.163.com           NetEase
# https://docker.mirrors.ustc.edu.cn    University of Science and Technology of China
# https://pee6w651.mirror.aliyuncs.com  Ali Cloud
# https://mirror.ccs.tencentyun.com     Tencent Cloud

cat << EOF >> /etc/docker/daemon.json
{

"registry-mirrors": ["https://registry.docker-cn.com"]

}
EOF

systemctl restart docker.service 