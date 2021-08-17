#! /bin/bash
#to backfill WY domain for OR 2021...this and backfill2.sh will allow you to convert
#grads to .nc to .tif and all the rest...

#reset time axis to start 1 Oct of present water year
#get today's date info and figure out year of current water year
day=$(date '+%d')
month=$(date '+%b')
monthnum=$(date '+%m')
year=$(date '+%Y')
if [ $((monthnum)) -lt 10 ]
then
	year=$(($year - 1))
fi
#use cdo to reset time axis
/scratch/cdo/bin/cdo settaxis,$year-10-01,00:00:00,1days /nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/swed_or2021.nc /nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/swed_or2021_2.nc 

#next, we are going to mess with the .nc metadata. CDO treats files as lon / lat, whereas
#we have projected coords out of SnowModel.
#First, change variable and dimension names
infile="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/swed_or2021_2.nc"
outfile="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/swed_or2021_3.nc"
ncrename -O -v .lat,projection_y_coordinate -d .lat,projection_y_coordinate -v .lon,projection_x_coordinate -d .lon,projection_x_coordinate "${infile}" "${outfile}"

#Next, change attributes
ncatted -O -a long_name,projection_y_coordinate,o,c,y "${outfile}"
ncatted -O -a standard_name,projection_y_coordinate,o,c,y "${outfile}"
ncatted -O -a long_name,projection_x_coordinate,o,c,x "${outfile}"
ncatted -O -a standard_name,projection_x_coordinate,o,c,x "${outfile}"

#finally, to change units requires that we know something from the .par file. See
#my writeup on code changes regarding the grid options for the ctl files. Currently,
#line 151 of the par file has the flag that controls the grid (index, m, km, etc.)
parfile="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/snowmodel.par"
unitchoice=$(sed -n '151p' "${parfile}")
unitchoice="${unitchoice:0:1}"

#check on unitchoice and change .nc file appropriately
if [ $unitchoice -eq 1 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,index "${outfile}"
ncatted -O -a units,projection_x_coordinate,o,c,index "${outfile}"
elif [ $unitchoice -eq 2 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,meters "${outfile}"
ncatted -O -a units,projection_x_coordinate,o,c,meters "${outfile}"
elif [ $unitchoice -eq 3 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,kilometers "${outfile}"
ncatted -O -a units,projection_x_coordinate,o,c,kilometers "${outfile}"
elif [ $unitchoice -eq 4 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,meters "${outfile}"
ncatted -O -a units,projection_x_coordinate,o,c,meters "${outfile}"
elif [ $unitchoice -eq 5 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,kilometers "${outfile}"
ncatted -O -a units,projection_x_coordinate,o,c,kilometers "${outfile}"
fi

#cool, so our entire water year of SWED is now converted over properly to .nc. 
#Let us now extract just the final day and rename it appropriately. First, figure out
#number of time steps in the file.
outfile="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/swed_or2021_3.nc"
numsteps=$(/scratch/cdo/bin/cdo -ntime "${outfile}")
#add 3 due to latency of cfs2 data.
num=$(($numsteps+3))
echo "$num"
#get date string from three days ago
STAMP=$(date --date="${num} days ago" +"%Y%b%d")
echo "$STAMP"

d=$(date --date="${num} days ago" '+%d')
echo "$d"
m=$(date --date="${num} days ago" '+%m')
echo "$m"
y=$(date --date="${num} days ago" '+%Y')
echo "$y"

for ((i=1; i<= $numsteps; i++));
do
  counter=$(($numsteps+3+1-$i))
  echo "$counter"
  d=$(date --date="${counter} days ago" '+%d')
  m=$(date --date="${counter} days ago" '+%m')
  y=$(date --date="${counter} days ago" '+%Y')
  stamp="${y}_${m}_${d}"
  echo "$stamp"
  singleday="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/$stamp.nc"
  /scratch/cdo/bin/cdo -seltimestep,$i $outfile $singleday
  
  #next, we want to convert this .nc to a geotiff. We can do this with gdal. The synatx:
#>>gdal_translate -of GTiff -a_srs EPSG:xxxx file.nc file.tif
#the -of GTiff requests tiff as output format. The -a_srs EPSG:xxxx sets the projection
fin="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/$stamp.nc"
fout="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/$stamp.tif"
gdal_translate -of GTiff -a_srs EPSG:32610 -a_ullr 570350 4955850 652450 4832750 $fin $fout
rm -f $fin
  
#next, let's set values of zero swe to be 'nodata' values. In this way, when we plot the
#tif, those cells will be transparent. I tested this in QGIS and they do show up 
#transparent. Need to deactivate conda and then reactivate it, in order to access
#gdal_calc
source /nfs/attic/dfh/miniconda/bin/activate cso
fin="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/$stamp.tif"
fout="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/${stamp}_mask.tif"
python /nfs/attic/dfh/miniconda/envs/cso/bin/gdal_calc.py -A $fin --outfile=$fout --calc="A*(A>0)" --NoDataValue=0
conda deactivate  
rm -f $fin

#cloud optimized geotiff...
fin="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/${stamp}_mask.tif"
fout="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/${stamp}_mask_cog.tif"
gdal_translate $fin $fout -co TILED=YES -co COPY_SRC_OVERVIEWS=YES -co COMPRESS=DEFLATE
rm -f $fin
fin="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/ctl_files/wo_assim/WY2021/$stamp.tif"
mv $fout $fin
rm -f $fout

#upload
gsutil cp $fin gs://cso_test_upload/or_domain/

done  

