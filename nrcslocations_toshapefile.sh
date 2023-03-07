#! /bin/bash
#this will simply download NCRS snotel locations, create a shapefile, and send that
#to google cloud storage. This should only have to be run once.

outpath="/scratch/ms_shapefiles/"

#run the query for snotel data
cd /nfs/depot/cce_u1/hill/dfh/op_snowmodel/op_snowmodel_python_scripts
source /nfs/attic/dfh/miniconda/bin/activate snowmodelcal
#ipython nrcs_locations.py
conda deactivate

echo
echo "snotel locations retrieved"
echo

#copy to google cloud storage
fin="${outpath}snotel_locations.cpg"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}snotel_locations.dbf"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}snotel_locations.prj"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}snotel_locations.shp"
gsutil cp $fin gs://cso_test/shapefiles/
fin="${outpath}snotel_locations.shx"
gsutil cp $fin gs://cso_test/shapefiles/

echo
echo "shapefile moved to GCS"
echo

#copy from bucket to asset
source /nfs/attic/dfh/miniconda/bin/activate ee
earthengine upload table --asset_id=users/dfh/ms_shapefiles/snotel_locations gs://cso_test/shapefiles/snotel_locations.shp
conda deactivate

echo
echo "asset created from shapefile in bucket"
echo