#! /bin/bash
# Chenglong Zou, Cristian Soriano
# 23/02/2013	v1.9.9

# donar d'alta treballadors...
# input file format:
# 1 dni 		-> login 
# 2 cognoms
# 3 nom
# 4 tel
# 5 dept
# 6 proj,...,...	-> num var de projects : asinar grups 



# dono per suposat que 'users' 		es un grup de users
# dono per suposat que 'projects' 	es un seudousuari - grup

 
TEMP=`getopt -o h -l help, -- "$@"`
eval set -- $TEMP
while true; 
do
  case "$1" in
    -h|--help) 	echo 'HELP:
	./atr.sh arg [-h]
		arg 	--> must be file [input_bots.data]
		-h 	--> help
	exemple:
		[sudo] ./atr.sh input_bots.data 
						'; exit 0;;
    --)        shift ; break ;;
    *)         
    echo "unknown option: $1" ; exit 1 ;;
  esac  
  shift
done
if [ $# -eq 0 ]
then 
	echo 'Ús:
	./atr.sh arg [-h]
	
		arg 	--> must be file [input_bots.data]
		-h 	--> help
	
		exemple:
			[sudo] ./atr.sh input_bots.data 
 	errors:
 		1 no permision
 		2 no argument
 		3 skel not found					'
	exit 2
fi
if [ `id -u` -eq 0 ]
then
        echo 'u are a superuser!'
else
        echo 'u ve no right, please run as root'
        exit 1
fi

echo ' '
####################################################################################
# ADD NEW PATH
####################################################################################
echo 'PATH="$PATH:."' >> /etc/skel/.profile 
[ $? -ne 0 ] && exit 3 	# surt en cas que hi hagi erro en la ultima comanda
####################################################################################
# CREATE FOLDERS
####################################################################################
# volem que dir treb... (no permetre que els users vegi fora d'aquests... carpet)	
if [ ! -d /users ]; then mkdir /users; fi
if [ ! -d /projects ]; then mkdir /projects; fi	 	
if [ ! -d /projects/instudy ]; then mkdir /projects/instudy; fi	 
if [ ! -d /projects/onresearch ]; then mkdir /projects/onresearch; fi
if [ ! -d /projects/finalized ]; then mkdir /projects/finalized; fi	  
####################################################################################
# CREATE GROUPS
####################################################################################
# 1r filtrar tots els grups -> son grups
for group in $(tail $1 -n +2 | sed 's/[\t ]//g' | cut -d ':' -f5 | sort -k1,1 -u)
do	
	# cal verificar si el dept existeix previament
	grep "^$group" /etc/group >/dev/null
	if [ $? -eq 0 ]
	then
		echo "$group existe!"
	 else
		groupadd -f $group	# -f exit successfully fi the group already exists
		[ $? -eq 0 ] && echo "S'ha afegit Grup '$group'!" || echo "ErrorAfegintDept!"
		mkdir /users/$group	2>> atr.err
	fi
	
done
# crear tots els departaments
# implementar un skel per grups
echo ' '
####################################################################################
# CREATE PROJECTS
####################################################################################
# 2n filtrar tots els caps de projecte -> son usuaris
for project in $(tail $1 -n +2 | sed 's/[\t ]//g' | cut -d ':' -f6 | sed 's/,/\n/g' | sort -k1,1 -u)
do
	# cal verificar si el project existeix previament
	grep "^$project" /etc/group >/dev/null
	if [ $? -eq 0 ]
	then
		echo "$project existe!"
	else
		groupadd -f $project
		[ $? -eq 0 ] && echo "S'ha afegit Grup '$project'!" || echo "ErrorAfegintProject!"
		mkdir /projects/instudy/$project	2>> atr.err
	fi
done
# crear tots els caps d'usuari
# implementar un skel per caps
echo ' '
####################################################################################
# CREATE USERS
####################################################################################
IFS=$'\n'
for line in $(tail $1 -n +2)
do

Usuari=$(echo $line | sed 's/[\t ]//g' | tr -s ':')
# afegir un usuari amb aquest nom
# fer un useradd amb tots aquests variables
dni=$(echo $Usuari | cut -d ':' -f1)
cognom=$(echo $Usuari | cut -d ':' -f2)
nom=$(echo $Usuari | cut -d ':' -f3)
tel=$(echo $Usuari | cut -d ':' -f4)
dept=$(echo $Usuari | cut -d ':' -f5)	# grup
proj=$(echo $Usuari | cut -d ':' -f6) # usuari -> projecte?

# cal verificar si el usuari existeix previament
grep "^$dni" /etc/passwd >/dev/null
if [ $? -eq 0 ]
then
	echo "$dni existe!"
	# implica que cal una moficiació
	echo 'menu de modificació'
	final=0
	while [ $final -ne -1 ]
	do
		echo 'please select option
			1 update name
			2 update phone
			3 update dept
			4 update proj
		
			-1 exit
	....:'
		read final
		  case $final in
		  	1)
		  		echo '	update name'
		  		echo 'please input full_name'
		  			read name
		  			chfn -f $name $dni	  
		  			;;
		  	2)
		  		echo '	update phone number'
		  		echo 'please input number'
		  			read number
		  			chfn -h $number $dni
		  			;;
		  	3)
		  		echo '	update department'
		  		echo 'please input dptment'
		  			read department
		  			usermod -g $department $dni
		  			;;
		  	4)
		  		echo '	update project'
		  		echo 'plase input projects: proj1[,proj2,proj3...]'
		  			read projs
		  			usermod -G $projs $dni
		  			;;
  
		  esac 
	 	shift
	done
	echo 'finalmodificacio'
else
	# en el cas de carregar skeletons predefinits per l'admin
	# sudo useradd -m -d /users/$dept/$dni -c "$nom $cognom" -k /users/skel -g $dept -G $proj -s /bin/bash $dni
	useradd -m -d /users/$dept/$dni -c "$nom,$cognom,,$tel" -g $dept -G $proj -s /bin/bash $dni
	[ $? -eq 0 ] && echo "S'ha afegit Usuari '$dni'!" || echo "ErrorAfegintUser!"
	passwd -d $dni > silent # deshabilitar contraseña
	passwd -e $dni > silent # expirar contraseña
fi
done
# restaurar skel
#IFS=$IFS_old
more /etc/skel/.profile | head -n-1 > /etc/skel/.profile






	

