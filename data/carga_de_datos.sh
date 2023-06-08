#!/bin/bash
echo 'Iniciando la carga de 'kindle_review.csv' a Redis ...'
redis-cli -h localhost -p 6379 --csv -x SET kindle_review < kindle_review.csv
echo 'Carga de datos finalizada'
