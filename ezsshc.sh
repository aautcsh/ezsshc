#!/bin/sh

# /* GLOBAL */
EZSSHC_VERSIONNR=0.8.5-p2
EZSSHC_MODDATE=2012-03-16
VERSIONNR=0.8.5-p2
MODDATE=2012-03-16

# /* CONFIGURATION FILES */
EZSSHC_CONF=~/.ezsshcrc
EZSSHC_LOG=~/.ezsshc.log

# /* MESSAGES */
EZSSHC_SPLASH=\
"-----------------------------------\n"\
"ezsshc: crude little ssh/scp helper\n"\
"-----------------------------------\n"\
"Version: $EZSSHC_VERSIONNR ($MODDATE)\n\n"

EZSSHC_ERR_NOCONF="[!] No config seems to exist at '$EZSSHC_CONF'"
EZSSHC_ERR_NOCON="[!] Can't find connection, try 'list'"
EZSSHC_ERR_NOCONNAME="[!] Can't find connection '$2', try 'list'"
EZSSHC_ERR_WRARGC="[!] Error: wrong number of arguments"
EZSSHC_ERR_WRARG="[!] No argument: '$1'"
EZSSHC_ERR_USAGE="[i] usage: $0 <option> <command>"
EZSSHC_ERR_ADDUSAGE="[i] usage: $0 add <name> <ip> <port> <user> <id>"
EZSSHC_APPEND_OK="[+] Config entry appended"


### FUNCTION DEFINITIONS ###
############################
help() {
	echo -e $EZSSHC_ERR_USAGE
	echo -e "Options:"
  echo -e "\t <l>   (list)\t- list all '<connections>' in ~/.ezsshcrc."
	echo -e "\t <i>   (info)\t- <connection>: verbose info."
  echo -e "\t <a>   (add)\t- <name> <ip> <port> <usr> <id>: append connection."
	echo -e "\t <rm>  (del)\t- <connection>: delete config entry."
	echo -e "\t <b>   (backup)\t- archive configuration (t_stamp=day)."
	echo -e "\t <go>  (ssh)\t- <connection>: connect to desired node."
	echo -e "\t <cp>  (copy)\t- <connection> <input> <path>: copy via scp."
	echo -e "\t <h>   (help)\t- print this screen."
	exit
}

list() {
	echo "CONNECTIONS:"
  echo "------------"
	i=0;
    for x in `grep -i "_name=" $EZSSHC_CONF | cut -d'=' -f 2`; # fixit: linux/*BSD
		do 
			if [ $i != 0 ]; then
				echo "[$i] $x"
			fi
			let i=i+1;
		done
		echo ""
	exit
}

info () {
	if [ $2 ]; then
		TMP_NAME=con_$2_name
		TMP_IP=con_$2_ip
		TMP_PORT=con_$2_port
		TMP_USER=con_$2_user
		TMP_ID=con_$2_id

		case "$2" in 
			${!TMP_NAME})
				echo "Name: ${!TMP_NAME}"
				echo "----------------"
				echo "Host:\t ${!TMP_IP}"
				echo "Port:\t ${!TMP_PORT}"
				echo "User:\t ${!TMP_USER}"
				echo "Key:\t ${!TMP_ID}"
				echo ""
				exit
				;;
			*)
				echo $EZSSHC_ERR_NOCONNAME
				exit
			;;
		esac
	else
		echo $EZSSHC_ERR_NOCON
		exit
	fi
}

add() {
  if [ $# != 6 ]; then
    echo $EZSSHC_ERR_WRARGC
		echo $EZSSHC_ERR_ADDUSAGE
		exit
  fi
  CNT=$(grep -i "_name=" $EZSSHC_CONF | wc -l)
  CNT="${CNT#"${CNT%%[![:space:]]*}"}" # the white rabbit

  echo "" >> $EZSSHC_CONF
	echo "# $2" >> $EZSSHC_CONF
	echo "con_$2_name=$2" >> $EZSSHC_CONF
  echo "con_$2_ip=$3" >> $EZSSHC_CONF
  echo "con_$2_port=$4" >> $EZSSHC_CONF
  echo "con_$2_user=$5" >> $EZSSHC_CONF
  echo "con_$2_id=$6" >> $EZSSHC_CONF
	echo $EZSSHC_APPEND_OK
	echo "[i] Current number of entries: $CNT"

	TIMEST=$(date -j +"%Y-%m-%d %H:%M:%S")
	echo "[$HOSTNAME@$TIMEST] $USER: $1 PARAM: $2" >> $EZSSHC_LOG
	echo "[$HOSTNAME@$TIMEST] Appended con_$2_*" >> $EZSSHC_LOG
	exit
}

del() {
	if [ $2 ]; then
		TMP_NAME=con_$2_name
		case $2 in
			${!TMP_NAME})
				TIMEST=$(date -j +"%Y-%m-%d %H:%M:%S")
				grep -iv "$2" $EZSSHC_CONF > ~/.ezsshcrc-$TIMEST.tmp
				mv ~/.ezsshcrc-$TIMEST.tmp $EZSSHC_CONF
				echo "[+] Config entry '$2' deleted"
				echo "[$HOSTNAME@$TIMEST] $USER: $1 PARAM: $2" >> $EZSSHC_LOG
				echo "[$HOSTNAME@$TIMEST] Deleted con_$2_* " >> $EZSSHC_LOG
				exit
				;;
			*)
				echo $EZSSHC_ERR_NOCONNAME
				exit
				;;
		esac
	else
		echo $EZSSHC_ERR_NOCON
		exit
	fi
	exit
}

bup() {
	TIMESTAMP=$(date -j +"%Y%m%d")
	cp -ap $EZSSHC_CONF $EZSSHC_CONF'_'$TIMESTAMP
   	echo "[+] Backup at: $EZSSHC_CONF'_'$TIMESTAMP"
	exit
}

go() {
	if [ $2 ]; then
		TMP_NAME=con_$2_name
		TMP_IP=con_$2_ip
		TMP_PORT=con_$2_port
		TMP_USER=con_$2_user
		TMP_ID=con_$2_id

		case "$2" in 
			${!TMP_NAME})
				IN_IP=${!TMP_IP}
				IN_PORT=${!TMP_PORT}
				IN_USER=${!TMP_USER}
				IN_ID=${!TMP_ID}
				;;
			*)
				echo $EZSSHC_ERR_NOCONNAME
				exit
				;;
		esac
	else
		echo $EZSSHC_ERR_NOCON
		exit
	fi

	echo "[+] Try to connect to: $2 ($IN_USER@$IN_IP:$IN_PORT)"

	TIMEST=$(date -j +"%Y-%m-%d %H:%M:%S")
	echo "[$HOSTNAME@$TIMEST] $USER: $1 PARAM: $2" >> $EZSSHC_LOG
	echo "[$HOSTNAME@$TIMEST] $IN_USER@$IN_IP:$IN_PORT (ID: $IN_ID)" >> $EZSSHC_LOG
	if [ $IN_ID == NULL ]; then
		cd && ssh $IN_USER\@$IN_IP -p $IN_PORT
	else
		cd && ssh -i $IN_ID $IN_USER\@$IN_IP -p $IN_PORT
	fi
	exit
}

cp() {
	if [ $# != 4 ]; then
    echo $EZSSHC_ERR_WRARGC
		help
		exit
  fi
	if [ $2 ]; then
		TMP_NAME=con_$2_name
		TMP_IP=con_$2_ip
		TMP_PORT=con_$2_port
		TMP_USER=con_$2_user
		TMP_ID=con_$2_id

		case "$2" in 
			${!TMP_NAME})
				IN_IP=${!TMP_IP}
				IN_PORT=${!TMP_PORT}
				IN_USER=${!TMP_USER}
				IN_ID=${!TMP_ID}
				;;
			*)
				echo $EZSSHC_ERR_NOCONNAME
				exit
				;;
		esac
	else
		echo $EZSSHC_ERR_NOCON
		exit
	fi

	echo "[+] Try to scp $3 to: $2:$4 ($IN_USER@$IN_IP:$IN_PORT)"

	TIMEST=$(date -j +"%Y-%m-%d %H:%M:%S")
	echo "[$HOSTNAME@$TIMEST] $USER: $1 PARAM: $2" >> $EZSSHC_LOG
	echo "[$HOSTNAME@$TIMEST] $IN_USER@$IN_IP:$IN_PORT (ID: $IN_ID)" >> $EZSSHC_LOG
	if [ $IN_ID == NULL ]; then
		cd && scp -P $IN_PORT $3 $IN_USER\@$IN_IP:$4
	else
		cd && scp -P $IN_PORT -i $IN_ID $3 $IN_USER\@$IN_IP:$4
	fi
	exit
}
### MAIN LOOP ###
#################
clear
echo $EZSSHC_SPLASH

ls $EZSSHC_CONF &>/dev/null
if [ $? -eq 1  ]; then
	echo $EZSSHC_ERR_NOCONF
	exit -1;
fi
source $EZSSHC_CONF &>/dev/null

case "$1" in
	l) 	list;;
	i) 	info;;
	a) 	add ;;
	rm) del ;;
	b) 	bup	;;
	go) go 	;;
	cp) cp 	;;
	h) 	help;;
	*)
		if [ $1 ]; then
			echo $EZSSHC_ERR_WRARG
		fi
		echo $EZSSHC_ERR_USAGE
		exit
		;;
esac
exit

