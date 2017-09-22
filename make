#!/bin/sh

EZSSHC_CONF=ezsshcrc
EZSSHC_CONF_EXAMPLE=ezsshcrc.example
EZSSHC_PERMS=665
EZSSHC_BIN=ezsshc

VERSIONNR=0.8.5-p2
MODDATE=2012-03-16

### FUNCTION DEFINITIONS ###
############################

splash() {
	echo "---------------------------"
	echo "ezsshc: crude little helper"
	echo "---------------------------"
	echo "Version: $VERSIONNR"
	echo ""
}

install() {
	touch /usr/sbin/xxxxxxx.x &>/dev/null
	if [ $? -eq 1 ]; then
		echo "[!] Error: Insufficient rights on /usr/sbin"
		exit -1
	elif [ $? -eq 0 ]; then
		rm /usr/sbin/xxxxxxx.x
	fi
					
	echo "[+] Installing essentials ..."
	cp $EZSSHC_CONF_EXAMPLE ~/$EZSSHC_CONF_EXAMPLE

	ls ~/.$EZSSHC_CONF &>/dev/null
	if [ $? -eq 1 ]; then
		grep -iv "You have to create" $EZSSHC_CONF_EXAMPLE > ~/.$EZSSHC_CONF
	fi
	cp $EZSSHC_BIN.sh /usr/sbin/$EZSSHC_BIN
	chmod $EZSSHC_PERMS /usr/sbin/$EZSSHC_BIN
	chmod +x /usr/sbin/$EZSSHC_BIN
		
	echo "[+] Installation complete"
	echo "[i] See example configuration at: ~/ezsshcrc.example"
	exit
}

cleanconf() {
	cp $EZSSHC_CONF_EXAMPLE ~/.$EZSSHC_CONF
	echo "[+] Flushed ~/.$EZSSHC_CONF"
	exit
}

backup() {
	TIMESTAMP=$(date -j +"%Y%m%d")
	if [ $# != 3 ]; then
		echo "[+] Backing up ~/.$EZSSHC_CONF"
		cp ~/.$EZSSHC_CONF ~/.$EZSSHC_CONF'_'$TIMESTAMP
		exit 
	fi
	echo "[+] Backing up ~$2/.$EZSSHC_CONF"
	cp ~$2/.$EZSSHC_CONF ~$2/.$EZSSHC_CONF'_'$TIMESTAMP
	exit
}

### MAIN LOOP ###

clear && splash
case "$1" in
	i) install 	;;
	c) cleanconf;;
	b) backup		;;
	*)
		echo "usage: ./make <install|backup|cleanconf 'user'>"
    ;;
esac
exit
