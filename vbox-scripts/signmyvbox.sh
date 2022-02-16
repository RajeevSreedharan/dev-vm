#!/bin/sh

# Intent : VirtualBox on OL8 host and secure boot enabled fails with a 'Kernel driver not found' error. 
#          Actual error is due to unsigned kernel modules (vboxdrv) rejected from loading in UEK
#          This script to sign vbox modules on OL8 UEK with secure boot enabled
#
# Sign reference : https://docs.oracle.com/en/operating-systems/oracle-linux/tutorial-uefi-secureboot-module/index.html


# Validate user inputs (Organization, Common name (FQDN) and email)
checkInput() {
    return 0
}

# Pre-requisites, if not already installed 
preinstall() {
    return 0
}

# Create local certificates and sign the module
createLocalCert() {
    return 0
}

# Enroll the certificate into the UEFI Secure Boot key database
enrollCert() {
    return 0
}

signDetailsUI()
{

}

signDetailsUI