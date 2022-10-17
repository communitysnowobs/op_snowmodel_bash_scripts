#! /bin/bash
#this will download snotel data and upload them to google cloud storage

outpath="/scratch/ms_shapefiles/"

#run the query for snotel data
cd /nfs/depot/cce_u1/hill/dfh/op_snowmodel/op_snowmodel_python_scripts
source /nfs/attic/dfh/miniconda/bin/activate snowmodelcal
ipython nrcssnotel.py
conda deactivate

echo
echo "nrcs data retrieved"
echo

#copy to google cloud storage
fin="${outpath}nrcsdata.cpg"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}nrcsdata.dbf"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}nrcsdata.prj"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}nrcsdata.shp"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}nrcsdata.shx"
gsutil cp $fin gs://cso_test/shapefiles/

echo
echo "shapefile moved to GCS"
echo

#copy from bucket to asset
source /nfs/attic/dfh/miniconda/bin/activate ee
earthengine upload table --asset_id=users/dfh/ms_shapefiles/nrcsdata gs://cso_test/shapefiles/nrcsdata.shp
conda deactivate

echo
echo "asset created from shapefile in bucket"
echo