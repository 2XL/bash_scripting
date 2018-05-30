#! /bin/bash
# Chenglong Zou, Cristian Soriano
# 23/02/2013	v1.9.9
#
# feu un script que puguin executar tots els treballadors
# , que se li passi per parametre l'id project
#
# input nomprojecte
# buscar directori desde la carpeta projects mostrar amb el pwd

if [ $1 == -h ]
then
	echo 'Ús:
	cal executarho com un proces (opcional)
	exemple: [.] tp.sh arg
		arg -> un grup secundari del usuari
'
	exit 0
fi

if [ $# -eq 0 ]
then 
	echo 'falta arg'
	exit 1 
else
	grep "^$1" /etc/group >/dev/null	# existeix grup?
	if [ $? -eq 0 ]
	then
		dirFutur=$(find /projects/ `pwd` -type d -name $1)	#directori futur
		if [ $? -ne 0 ] 
		then
		echo 'proj_dir no trobat' 
		exit 4
		else
		echo 'dir trobat!'
		fi
		dirActual=$PWD # conservar el directori actual		#directori actual
	
		cd $dirFutur
		initTime=$(date +%s)

		echo "$1 existe!"
		# grpActual=$(id | cut -d '(' -f4 | cut -d ')' -f1)
		
		newgrp $1	# <- porque se para aqui?
	else
		echo "projecte $1 no exiteix"
		exit 3
	fi
fi
 
finitTime=$(date +%s)	
let divTime=$finitTime-$initTime
cd $dirActual # tornar al directori origen
echo "the elapsed time: $divTime seconds"
# tornar a asinar al grup origen
newgrp

