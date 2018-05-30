#! /bin/bash
# Chenglong Zou, Cristian Soriano
# 23/02/2013	v1.1.5
# 
echo 'Ús:
	./deleteGroups.sh input_userlist
	'
	# llistar grups únics a tractar
for grup in $( tail input_bots.data -n+2 | cut -d ':' -f6,5 | sed 's/[\t ]//g' | sed 's/[:,]/\n/g' | sort -u )
do	
	grep "^$grup:" /etc/group	# mirar si existeix grup
	if [ $? -eq 0 ]
	then 
	sudo groupdel $grup
	[ $? -eq 0 ] && echo "User has been deleted from system!" || echo "Failed to delete a user!"
	else
	echo "$grup dont Exists!"	
	fi
done

