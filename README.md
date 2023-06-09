# MEISI-INDWDM-Trabajo_final
Trabajo final para el curso "Inteligencia de negocios: Data Warehouse y Data Mining"

## Instalación
1. Instalar Docker Engine ([link](https://docs.docker.com/engine/install/)) y Docker Compose ([link](https://docs.docker.com/compose/install/))
2. Abrir la línea de comandos o terminal del sistema en la carpeta de este repositorio
3. Ejecutar el siguiente comando para **iniciar el contenedor con Redis**:
```console
docker-compose up -d
```
4. Ejecutar el siguiente comando para **cargar el archivo CSV a Redis**:

En Windows:
```pwsh
./inicializar_bd.bat
```

En Linux:
```sh
./inicializar_bd.sh
```

## Ejecución
1. El comando del paso 3 de la instalación (`docker-compose up -d`) mantiene el servidor en ejecución.
Para sesiones posteriores a la instalación, solo basta con ejecutar ese mismo comando para que inicie el servidor Redis.
```shell
docker-compose up-d
```
2. En el cliente de R (como RStudio) instalar la librería `redux`:
```R
install.packages("redux")
```
3. Iniciar la conexión con el servidor Redis:
```R
r = redux::hiredis()
```
4. Los datos del archivo CSV están cargado en la llave `kindle_review`. Para acceder a ellos se usa el método `GET` y se los puede guardar en una variable (por ejemplo `csv`):
```R
csv = r$GET("kindle_review")
```
5. Con el paso anterior, la variable `csv` tendrá almacenado todo el contenido del archivo CSV como una enorme cadena de texto. Este texto debe ser transformado en tabla para su utilización. Esta transformación se realiza con el siguiente comando:
```R
datos = read.csv(text=csv,sep=',')
```
Tras ejecutar este comando, la variable `datos` tendrá la tabla con las columnas y filas definidas.

## Enlaces
- Documentación de redux: [link](https://cran.r-project.org/web/packages/redux/redux.pdf)
- Información del paquete redux: [link](https://cran.r-project.org/web/packages/redux/index.html)
