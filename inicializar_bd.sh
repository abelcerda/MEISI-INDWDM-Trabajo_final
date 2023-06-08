#!/bin/bash
echo 'Inicializando base de datos...'
docker exec redis_meisi bash 'carga_de_datos.sh'
