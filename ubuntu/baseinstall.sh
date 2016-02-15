#!/bin/bash
test="testing"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

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
    apt-get install htop ntp
}

tune_system()
configure_datadisks()
datastax_repo()
initial_install()

exit 0