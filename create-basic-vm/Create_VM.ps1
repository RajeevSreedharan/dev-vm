$env:Path += ";C:\Program Files\Oracle\VirtualBox"
VBoxManage createvm --name OEL8_Base --ostype Oracle_64 --register --basefolder "E:\VM\VirtualBox VMs"
VBoxManage modifyvm OEL8_Base --cpus 2 --memory 4096 --vram 32 --graphicscontroller vmsvga
VBoxManage createhd --filename "E:\VM\disks\OEL8_Base_disk0.vdi" --size 81920 --variant Standard 
VBoxManage modifyvm OEL8_Base --nic1 bridged --bridgeadapter1 eth0
VBoxManage storagectl OEL8_Base --name "IDE" --add ide --portcount 2
VBoxManage storageattach OEL8_Base --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "E:\VM\Shared\V983280-01.iso"
VBoxManage storagectl OEL8_Base --name "SATA" --add sata --bootable on --portcount 2
VBoxManage storageattach OEL8_Base --storagectl "SATA" --port 0 --device 0 --type hdd --nonrotational on --medium "E:\VM\disks\OEL8_Base_disk0.vdi"
VBoxManage modifyvm  OEL8_Base --iconfile E:\VM\VirtualBox VMs\Icons\oel8.png

VBoxManage startvm OEL8_Base
