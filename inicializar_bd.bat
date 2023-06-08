@echo off
title MEISI-IN Cargar datos iniciales
echo Inicializando base de datos...
docker exec redis_meisi bash carga_de_datos.sh
pause