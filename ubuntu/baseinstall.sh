#!/bin/bash
JDKDL=""

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

while getopts ":d" opt; do
  case $opt in
    a)
      $JDKDL=$OPTARG    
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done 

tune_system()
{
	# Add local machine name to the hosts file to facilitate IP address resolution
	if grep -q "${HOSTNAME}" /etc/hosts
	then
	  echo "${HOSTNAME} was found in /etc/hosts"
	else
	  echo "${HOSTNAME} was not found in and will be added to /etc/hosts"
	  # Append it to the hsots file if not there
	  echo "127.0.0.1 $(hostname)" >> /etc/hosts
	  log "Hostname ${HOSTNAME} added to /etc/hosts"
	fi	
}

configure_datadisks()
{
	log "Formatting and configuring the data disks"
	bash vm-disk-utils-0.1.sh
}

datastax_repo()
{
    echo "deb http://debian.datastax.com/community stable main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
    curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
}

initial_install()
{
    apt-get update
    apt-get dist-upgrade -y
    apt-get install htop ntp -y
}

installjdk()
{
    mkdir /tmp/dl
    wget -O /tmp/dl/jdk8.gz $JDKDL
    tar -xf /tmp/dl/jdk8.gz -C /tmp/dl
    mkdir -p /usr/lib/jvm/
    JDKDIR=`ls /tmp/dl | grep jdk1.8`
    mv /temp/dl/$JDKDIR /usr/lib/jvm/jdk1.8.0
    chown root:root /usr/lib/jvm/jdk1.8.0 -R
    update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0/bin/java" 1
    update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0/bin/javac" 1
    update-alternatives --install "/usr/bin/keytool" "keytool" "/usr/lib/jvm/jdk1.8.0/bin/keytool" 1
    update-alternatives --install "/usr/bin/pack200" "pack200" "/usr/lib/jvm/jdk1.8.0/bin/pack200" 1
    update-alternatives --install "/usr/bin/rmid" "rmid" "/usr/lib/jvm/jdk1.8.0/bin/rmid" 1
    update-alternatives --install "/usr/bin/rmiregistry" "rmiregistry" "/usr/lib/jvm/jdk1.8.0/bin/rmiregistry" 1
    update-alternatives --install "/usr/bin/unpack200" "unpack200" "/usr/lib/jvm/jdk1.8.0/bin/unpack200" 1
    update-alternatives --install "/usr/bin/orbd" "orbd" "/usr/lib/jvm/jdk1.8.0/bin/orbd" 1
    update-alternatives --install "/usr/bin/servertool" "servertool" "/usr/lib/jvm/jdk1.8.0/bin/servertool" 1

    # cleanup
    rm /opt/dl -R  
}

tune_system
configure_datadisks
datastax_repo
initial_install
exit 0