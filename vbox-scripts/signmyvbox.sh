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

    for prereq in "kernel-uek" "kernel-uek-devel" "keyutils" "mokutil" "pesign"; do
        sudo dnf -q list installed $prereq >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            sudo dnf -y install $prereq
            [ $? -ne 0 ] && echo "ERROR installing $prereq" && return -1
        fi
    done

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

    CERTFOLDER=$(eval echo ~$USER)/certs
    mkdir -p $CERTFOLDER
    cd $CERTFOLDER
    openssl req -x509 -new -nodes -utf8 -sha512 -days 3650 -batch -config /tmp/x509.conf -outform DER -out pubkey.der -keyout priv.key

    openssl x509 -inform DER -in pubkey.der -out pubkey.pem
    openssl pkcs12 -export -inkey priv.key -in pubkey.pem -name cert -out cert.p12

    cd $CERTFOLDER
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

# Short UI to capture only required details
signDetailsUI() {
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
                            --text="Your certificates have been saved to : $CERTFOLDER\n\nNext steps:\n1. Reboot. MOK management will automatically pop.\n2. Select Enroll MOK\n3. Select Continue" 2>/dev/null

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

# This script is to be run as a Virtual Box user, not as root
checkUserGroup() {
    if [[ $(getent group wheel | grep -w -c "$USER") -eq 1 ]]; then
        return 0
    else
        zenity --error --width=300 \
            --text="You are running this using [$USER] user. You should run this as a normal user using Virtual Box." 2>/dev/null
        return -1
    fi

    return 0
}

# Script starts here
checkUserGroup
rc=$?
if [ "$rc" == "0" ]; then
    signDetailsUI
fi
