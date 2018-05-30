#! /bin/bash
# Chenglong Zou, Cristian Soriano
# 23/02/2013	v1.0.1
# 
echo 'Ús:
	./deleteUsers.sh input_userlist
	'	
	# llistar usuaris
for dni in $(tail $1 -n+2 | sed 's/[\t ]//g' | cut -d ':' -f1)
do	
	grep "^$dni:" /etc/passwd 	# comprovar si existeix
	if [ $? -eq 0 ]
	then 
	sudo userdel $dni -r
	[ $? -eq 0 ] && echo "User has been deleted from system!" || echo "Failed to delete a user!"
	else
	echo "$dni dont Exists!"	
	fi
done


