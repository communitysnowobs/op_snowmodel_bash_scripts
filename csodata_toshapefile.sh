#! /bin/bash
#this will download snotel and cso data and upload them to google cloud storage

outpath="/scratch/ms_shapefiles/"

#run the query for cso data
cd /nfs/depot/cce_u1/hill/dfh/op_snowmodel/op_snowmodel_python_scripts
source /nfs/attic/dfh/miniconda/bin/activate snowmodelcal
ipython csosnotel.py
conda deactivate

echo
echo "cso data retrieved"
echo

#copy to google cloud storage
fin="${outpath}csodata.cpg"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}csodata.dbf"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}csodata.prj"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}csodata.shp"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}csodata.shx"
gsutil cp $fin gs://cso_test/shapefiles/

echo
echo "shapefile moved to GCS"
echo

#copy from bucket to asset
source /nfs/attic/dfh/miniconda/bin/activate ee
#Feb 2023 --> added force overwrite to the command below. Oops.
earthengine upload table --asset_id=projects/ee-dfh2/assets/csodata gs://cso_test/shapefiles/csodata.shp --force -f
#Feb 2023 --> each time you upload, file is private. So, have to set to public each day...
earthengine acl set public projects/ee-dfh2/assets/csodata
conda deactivate

echo
echo "asset created from shapefile in bucket"
echo