#!/bin/bash

#recibe como único parámetro los puntos
los_puntos=$1
shp=puntos.shp
csv=puntos.csv
tmp=puntos.tmp
vrt=puntos.vrt
new_shp_name=$2

dir_base=/home/santiago/datos/radar-rasterizado/
dir_hechos=/home/santiago/datos/hechos/

#Prepara el encabezado para el csv
echo lon,lat,dbz > ${csv}
#cat ${csv}
#dumpea encabezado y datos reemplazando espacios por comas
cat ${csv} ${los_puntos} | sed 's/\s/,/g' > ${tmp}
cat ${tmp} > ${csv}
echo Preparando datos...
#head ${csv}

echo Convirtiendo a shp...
ogr2ogr -f "ESRI Shapefile" ${new_shp_name} ${vrt} -overwrite

echo Crear imagen en blanco...
cp ${dir_base}template-grilla-TM-LIMPIA.tif ${los_puntos}.tif

#Rasterizar los puntos del barrido
echo Rasterizar los puntos del barrido
gdal_rasterize -ts 487 505 -a_nodata -99 -a dbz -l puntos ./${new_shp_name}/${shp}  ${los_puntos}.tif

#Suavizar la imagen
python completa-blancos.py ${los_puntos}.tif 2 max

#cambia de disco los hechos
mv ${los_puntos} ${dir_hechos}
