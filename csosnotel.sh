#! /bin/bash
#this will download snotel and cso data and upload them to google cloud storage

outpath="/scratch/ms_shapefiles/"

#run the query for cso data
cd /nfs/depot/cce_u1/hill/dfh/op_snowmodel/op_snowmodel_python_scripts
source /nfs/attic/dfh/miniconda/bin/activate snowmodelcal
ipython csosnotel2.py
conda deactivate

echo
echo "cso data retrieved"
echo

#copy to gcs

styear=2022
stmonth=01
stday=01

edyear=2022
edmonth=10
edday=02

d=$(date -d "${styear}-${stmonth}-${stday}" '+%d')
m=$(date -d "${styear}-${stmonth}-${stday}" '+%m')
y=$(date -d "${styear}-${stmonth}-${stday}" '+%Y')
ststamp="${y}-${m}-${d}"

echo
echo $ststamp

d=$(date -d "${edyear}-${edmonth}-${edday} +${i}" '+%d')
m=$(date -d "${edyear}-${edmonth}-${edday} +${i}" '+%m')
y=$(date -d "${edyear}-${edmonth}-${edday} +${i}" '+%Y')
edstamp="${y}-${m}-${d}"

echo
echo $edstamp

#copy to google cloud storage
fin="${outpath}${ststamp}_${edstamp}_cso.cpg"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}${ststamp}_${edstamp}_cso.dbf"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}${ststamp}_${edstamp}_cso.prj"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}${ststamp}_${edstamp}_cso.shp"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}${ststamp}_${edstamp}_cso.shx"
gsutil cp $fin gs://cso_test/shapefiles/

#copy from bucket to asset
source /nfs/attic/dfh/miniconda/bin/activate ee
earthengine upload table --asset_id=users/dfh/ms_shapefiles/"${ststamp}_${edstamp}_cso" gs://cso_test/shapefiles/"${ststamp}_${edstamp}_cso.shp"
conda deactivate