#!/usr/bin/env bash

#if [ $# -ne 3 ]; then
#    echo 'usage: retry <num retries> <wait retry secs> "<command>"'
#    exit 1
#fi

#retries=$1
#wait_retry=$2
#command=$3
retries=3
wait_retry=5
command="mysqladmin -u root status"

echo "Starting mysql container.. "

# Create a basic mysql install
if [ ! -d /var/lib/mysql/mysql ]; then
  echo "**** No MySQL data found. Creating data on /var/lib/mysql/ ****"
  mkdir -p /var/lib/mysql
  rm -rf /var/lib/mysql/*
  export GRPID=$(stat -c "%g" /var/lib/mysql/)
  /usr/sbin/mysqld --initialize-insecure
else
  echo "**** MySQL data found on /var/lib/mysql/ ****"
fi

chown -R mysql:mysql /var/lib/mysql
su mysql -c "/usr/bin/mysqld_safe --default-authentication-plugin=mysql_native_password &"

for i in `seq 1 $retries`; do
    echo "$command"
    $command
    ret_value=$?
    [ $ret_value -eq 0 ] && break
    echo "> failed with $ret_value, waiting to retry..."
    sleep $wait_retry
done
echo "Finished checking that mysql is running with $ret_value .. "
ret_value2=0
if [ $ret_value -eq 0 ]; then
	mysql -u root -e "DROP DATABASE IF EXISTS welk_sprint1;"
	mysql -u root -e "CREATE DATABASE welk_sprint1";
	if [ -f /root/drupal/install.sql ]; then
		echo "Found db install script, importing.. "
		mysql -u root welk_sprint1 < /root/drupal/install.sql
		#mysql -u root -e "ALTER USER 'root' IDENTIFIED WITH mysql_native_password BY '';"
		mv /root/drupal/install.sql /root/install.sql
	fi
	mysql -u root -e "CREATE USER 'root'@'%' IDENTIFIED BY ''";
	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* to 'root'@'%' WITH GRANT OPTION";
fi

if [ $ret_value -ne 0  ]; then
	echo "There was an error starting mysql or importing "
	exit $ret_value
else
	mysqladmin -u root shutdown
	echo "Done, mysql should be running and imported. Attaching to foreground.. "
	cd /var/lib/mysql
	su mysql -c "/usr/bin/mysqld_safe --default-authentication-plugin=mysql_native_password "
fi