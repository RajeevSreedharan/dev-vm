#!/bin/sh

# Intent : VirtualBox on OL8 host and secure boot enabled fails with a 'Kernel driver not found' error. 
#          Actual error is due to unsigned kernel modules (vboxdrv) rejected from loading in UEK
#          This script to sign vbox modules on OL8 UEK with secure boot enabled
#
# Sign reference : https://docs.oracle.com/en/operating-systems/oracle-linux/tutorial-uefi-secureboot-module/index.html


# Validate user inputs (Organization, Common name (FQDN) and email)
checkInput() {

    myorg=$(awk -F, '{print $1}' <<<$OUTPUT)
    if [ -z "$myorg" ]; then
        zenity --error --text="Organization cannot be blank" 2>/dev/null
        return -1
    fi
    myorgkey=$(awk -F, '{print $2}' <<<$OUTPUT)
    if [ -z "$myorgkey" ]; then
        zenity --error --text="Common name cannot be blank" 2>/dev/null
        return -1
    fi
    myemail=$(awk -F, '{print $3}' <<<$OUTPUT)
    if [ -z "$myemail" ]; then
        zenity --error --text="Email cannot be blank" 2>/dev/null
        return -1
    fi

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
OUTPUT=$(zenity --forms --title="Sign my VirtualBox" \
    --text="Enter details here" \
    --separator="," \
    --add-entry="Organization" \
    --add-entry="Common Name (e.g. abc.com)" \
    --add-entry="Email" 2>/dev/null)

rc=$?
case $rc in
0)
    echo "Processing.."
    checkInput
    rc2=$?
    if [ "$rc2" == "0" ]; then
        preinstall
        rc2=$?
        if [ "$rc2" == "0" ]; then
            createLocalCert
            rc2=$?
            if [ "$rc2" == "0" ]; then
                enrollCert
                rc2=$?
                if [ "$rc2" == "0" ]; then
                    zenity --info --width=400 \
                    --text="Next steps:\n1. Reboot. MOK management will automatically pop.\n2. Select Enroll MOK\n3. Select Continue" 2>/dev/null
    
                    echo "Done."
                fi
            fi
        fi
    fi
    ;;

1)
    echo "User cancelled"
    ;;
-1)
    echo "An unexpected error has occurred."
    ;;
esac

if [ $rc -ne 0 ]; then
    echo $rc
fi
}

signDetailsUI