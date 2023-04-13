#!/bin/bash
#isactive.sh
#Juan M. Duran
#genera lista de servicios activos pasados como parametros
#Uso del programa: isactive.sh [nombres de servicio...]

PROG=$(basename $0)
ERR_ARGS=1
ERR_NOACTIU=2

if [ $# -lt 1 ]; then


	echo "ERROR :Parametros incorrectos. Ha de haber al menos un parametro"
	echo "Uso del programa: $PROG nombres de servicio"
	exit $ERR_ARGS
fi


active=0
inactive=0

for service in $*; do
	if systemctl is-active $service > /dev/null 2>&1 ; then
		echo "El servicio $service está activo"
		((active++))
	else
		((inactive++))
	fi
done

echo "Total: $((active+inactive)), activos: $active, inactivos: $inactive"

if [ "$inactive" -gt 0 ]; then
	exit $ERR_NOACTIU
else
	exit 0
fi