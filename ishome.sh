#!/bin/bash
#
#ishome.sh
#Juan M. Duran
#
#Detecta si la combinación de usuario y directório home es correcta
#Uso del programa: ishome.sh [login usuario] [directorio home]"

PROG=$(basename "$0")
ERR_ARGS=1
ERR_NOEXIST=2
ERR_NOMATCH=3

if [[ $# -ne 2 ]]; then

	echo "Numero de parametros incorrecto"
	echo "Uso del programa: $PROG login dirhome"
	exit $ERR_ARGS
fi


if   id "$1"  > /dev/null 2>&1 ; then
	userdir=$(grep "^$1:" /etc/passwd|cut -d: -f6)
	if [[ "$userdir" = "$2" ]] ;then
		echo "SI: El usuario $1 tiene el home en $2"
	else
		echo "NO: El usuario $1  no tiene el home en $2, lo tiene en $userdir"
		exit $ERR_NOMATCH
	fi
else
    echo "Error: El usuario $1 no existe"
    exit $ERR_NOEXIST
fi
exit 0
