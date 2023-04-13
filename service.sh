#! /bin/bash
#
#service.sh
#Juan M. Duran
#rep com a argument el nom d’un servei de xarxa i mostra les línies del fitxer /etc/services que contenen aquest nom.
#
#Uso del programa: ./service [nombre del servicio]"

PROG=$(basename $0)
ERR_ARGS=1
ERR_NOEXIST=2

if [[ $# -ne 1 ]]; then

	if [[ $# -gt 1 ]]; then

		echo "Demasiados parametros"
		echo "Uso del programa: $PROG [nombre del servicio]"
	fi

	if [[ $# -lt 1 ]]; then

		echo "Insuficientes parametros"
		echo "Uso del programa: $PROG [nombre del servicio]"
	fi

	exit $ERR_ARGS

fi

grep -w "^$1" /etc/services

if [[ $? -ne 0 ]]; then
	echo "Error: El servicio $1 no existe en /etc/services"
	exit $ERR_NOEXIST
	
fi

exit 0