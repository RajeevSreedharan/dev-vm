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
    sudo dnf -q list installed kernel-uek >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        sudo dnf -y install kernel-uek
        [ $? -ne 0 ] && echo "ERROR" && return -1
    fi
    sudo dnf -q list installed kernel-uek-devel >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        sudo dnf -y install kernel-uek-devel
        [ $? -ne 0 ] && echo "ERROR" && return -1
    fi
    sudo dnf -q list installed keyutils >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        sudo dnf -y install keyutils
        [ $? -ne 0 ] && echo "ERROR" && return -1
    fi
    sudo dnf -q list installed mokutil >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        sudo dnf -y install mokutil
        [ $? -ne 0 ] && echo "ERROR" && return -1
    fi
    sudo dnf -q list installed pesign >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        sudo dnf -y install pesign
        [ $? -ne 0 ] && echo "ERROR" && return -1
    fi

    echo "[Step 2 of 4] Prequisite installation complete"

    return 0
}

# Create local certificates and sign the module
createLocalCert() {

    cat >>/tmp/x509.conf <<EOF
[ req ]
default_bits = 4096
distinguished_name = req_distinguished_name
prompt = no
string_mask = utf8only
x509_extensions = extensions

[ req_distinguished_name ]
O = $myorg
CN = $myorgkey
emailAddress = $myemail

[ extensions ]
basicConstraints=critical,CA:FALSE
keyUsage=digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
EOF

    mkdir ~/certs
    cd ~/certs
    openssl req -x509 -new -nodes -utf8 -sha512 -days 3650 -batch -config /tmp/x509.conf -outform DER -out pubkey.der -keyout priv.key

    openssl x509 -inform DER -in pubkey.der -out pubkey.pem
    openssl pkcs12 -export -inkey priv.key -in pubkey.pem -name cert -out cert.p12

    cd ~/certs
    for module in $(dirname $(modinfo -n vboxdrv))/*.ko; do
        sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha512 priv.key pubkey.der "${module}"
    done

    modinfo vboxdrv
    echo "[Step 3 of 4] Certificate creation complete"

    return 0
}

# Enroll the certificate into the UEFI Secure Boot key database
enrollCert() {
    sudo mokutil --import pubkey.der
    echo "[Step 4 of 4] Certificate enrollment complete"

    return 0
}

signDetailsUI()
{
OUTPUT=$(zenity --forms --title="Sign my VirtualBox" \
    --text="Enter details here" \
    --separator="," \
    --add-entry="Organization" \
    --add-entry="Common Name (e.g. oracle.com)" \
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