$env:Path += ";C:\Program Files\Oracle\VirtualBox"
VBoxManage createvm --name OEL7_Docker --ostype Oracle_64 --register --basefolder "D:\Docker\VM"
VBoxManage modifyvm OEL7_Docker --cpus 2 --memory 4096 --vram 32 --graphicscontroller vmsvga
VBoxManage createhd --filename "D:\Docker\VM\OEL7_Docker\OEL7_Docker_disk0.vdi" --size 40960 --variant Standard 
VBoxManage createhd --filename "D:\Docker\VM\OEL7_Docker\OEL7_Docker_disk1.vdi" --size 81920 --variant Standard 
VBoxManage modifyvm OEL7_Docker --nic1 bridged --bridgeadapter1 eth0
VBoxManage storagectl OEL7_Docker --name "IDE" --add ide --portcount 2
VBoxManage storageattach OEL7_Docker --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "F:\Setup\Virtual Machine\Oracle Linux 7.7.0.0.0 for x86 64 bit\V983339-01.iso"
VBoxManage storagectl OEL7_Docker --name "SATA" --add sata --bootable on --portcount 2
VBoxManage storageattach OEL7_Docker --storagectl "SATA" --port 0 --device 0 --type hdd --nonrotational on --medium "D:\Docker\VM\OEL7_Docker\OEL7_Docker_disk0.vdi"
VBoxManage storageattach OEL7_Docker --storagectl "SATA" --port 1 --device 0 --type hdd --nonrotational on --medium "D:\Docker\VM\OEL7_Docker\OEL7_Docker_disk1.vdi"

# Using kickstart
# VBoxManage modifyvm OEL7_Docker --boot1 disk --boot2 net --boot3 none --boot4 none
# VBoxManage modifyvm OEL7_Docker --nictype1 Am79C973
# VBoxManage modifyvm OEL7_Docker --nattftpserver1 192.168.56.1
# VBoxManage modifyvm OEL7_Docker --nattftpfile1 pxelinux.0

VBoxManage startvm OEL7_Docker

# Post OS install attach DVD again with Optical Disk un-chekced as bootable
# VBoxManage storageattach OEL7_Docker --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "F:\Setup\Virtual Machine\Oracle Linux 7.7.0.0.0 for x86 64 bit\V983339-01.iso"
# VBoxManage modifyvm OEL7_Docker --boot1 disk --boot2 none --boot3 none --boot4 none
