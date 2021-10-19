#! /bin/bash

#Note, we need to do a number of things that are related to the date of the model run.
#this includes a reset the time axis to start 1 Oct of present water year. Get today's
#date info and figure out year of current water year. Let's do that up front in
#this script. We do this since the model run takes a long time (12+ hours) and may
#conclude TOMORROW and not today. We want today's date.
day=$(date '+%d')
month=$(date '+%b')
monthnum=$(date '+%m')
year=$(date '+%Y')
if [ $((10#$monthnum)) -lt 10 ]
then
	year=$(($year - 1))
elif [ $((10#$monthnum)) -eq 10 ]	
then
if [ $day -lt 4 ]
then
    year=$(($year - 1))
fi
fi

#also, we are ultimately going to extract just the 'last' time slice, so let's figure
#out the time stamp for that. Get date string from three days ago
d=$(date --date="3 days ago" '+%d')
m=$(date --date="3 days ago" '+%m')
y=$(date --date="3 days ago" '+%Y')
STAMP="${y}_${m}_${d}"

################################
#run the query for met
cd /nfs/depot/cce_u1/hill/dfh/op_snowmodel/get_met_data
source /nfs/attic/dfh/miniconda/bin/activate ee
ipython met_data_or.py
conda deactivate

################################
#adjust the par file
cd /nfs/depot/cce_u1/hill/dfh/op_snowmodel/update_par_file
./makeparfile_or.exe

################################
#kick of snow model run for or domain
cd /nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/
./snowmodel

################################
# tons of file management coming your way...
smpath="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/or_snowmodel/"
outpath="/scratch/op_snowmodel_outputs/OR/"
#convert swe and Hs grads output to .nc
/scratch/cdo/bin/cdo -f nc import_binary "${smpath}ctl_files/wo_assim/swed.ctl" "${smpath}ctl_files/wo_assim/swed.nc"
/scratch/cdo/bin/cdo -f nc import_binary "${smpath}ctl_files/wo_assim/snod.ctl" "${smpath}ctl_files/wo_assim/snod.nc"

#use cdo to reset time axis
/scratch/cdo/bin/cdo settaxis,$year-10-01,00:00:00,1days "${smpath}ctl_files/wo_assim/swed.nc" "${smpath}ctl_files/wo_assim/swed2.nc"
/scratch/cdo/bin/cdo settaxis,$year-10-01,00:00:00,1days "${smpath}ctl_files/wo_assim/snod.nc" "${smpath}ctl_files/wo_assim/snod2.nc"

#next, we are going to mess with the .nc metadata. CDO treats files as lon / lat, whereas
#we have projected coords out of SnowModel.
#DO SWED FIRST
infile1="${smpath}ctl_files/wo_assim/swed2.nc"
outfile1="${smpath}ctl_files/wo_assim/swed3.nc"
ncrename -O -v .lat,projection_y_coordinate -d .lat,projection_y_coordinate -v .lon,projection_x_coordinate -d .lon,projection_x_coordinate "${infile1}" "${outfile1}"

#Next, change attributes
ncatted -O -a long_name,projection_y_coordinate,o,c,y "${outfile1}"
ncatted -O -a standard_name,projection_y_coordinate,o,c,y "${outfile1}"
ncatted -O -a long_name,projection_x_coordinate,o,c,x "${outfile1}"
ncatted -O -a standard_name,projection_x_coordinate,o,c,x "${outfile1}"

#finally, to change units requires that we know something from the .par file. See
#my writeup on code changes regarding the grid options for the ctl files. Currently,
#line 151 of the par file has the flag that controls the grid (index, m, km, etc.)
parfile="${smpath}snowmodel.par"
unitchoice=$(sed -n '151p' "${parfile}")
unitchoice="${unitchoice:0:1}"

#check on unitchoice and change .nc file appropriately
if [ $unitchoice -eq 1 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,index "${outfile1}"
ncatted -O -a units,projection_x_coordinate,o,c,index "${outfile1}"
elif [ $unitchoice -eq 2 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,meters "${outfile1}"
ncatted -O -a units,projection_x_coordinate,o,c,meters "${outfile1}"
elif [ $unitchoice -eq 3 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,kilometers "${outfile1}"
ncatted -O -a units,projection_x_coordinate,o,c,kilometers "${outfile1}"
elif [ $unitchoice -eq 4 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,meters "${outfile1}"
ncatted -O -a units,projection_x_coordinate,o,c,meters "${outfile1}"
elif [ $unitchoice -eq 5 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,kilometers "${outfile1}"
ncatted -O -a units,projection_x_coordinate,o,c,kilometers "${outfile1}"
fi

#DO SNOD NEXT
#First, change variable and dimension names
infile2="${smpath}ctl_files/wo_assim/snod2.nc"
outfile2="${smpath}ctl_files/wo_assim/snod3.nc"
ncrename -O -v .lat,projection_y_coordinate -d .lat,projection_y_coordinate -v .lon,projection_x_coordinate -d .lon,projection_x_coordinate "${infile2}" "${outfile2}"

#Next, change attributes
ncatted -O -a long_name,projection_y_coordinate,o,c,y "${outfile2}"
ncatted -O -a standard_name,projection_y_coordinate,o,c,y "${outfile2}"
ncatted -O -a long_name,projection_x_coordinate,o,c,x "${outfile2}"
ncatted -O -a standard_name,projection_x_coordinate,o,c,x "${outfile2}"

#check on unitchoice and change .nc file appropriately
if [ $unitchoice -eq 1 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,index "${outfile2}"
ncatted -O -a units,projection_x_coordinate,o,c,index "${outfile2}"
elif [ $unitchoice -eq 2 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,meters "${outfile2}"
ncatted -O -a units,projection_x_coordinate,o,c,meters "${outfile2}"
elif [ $unitchoice -eq 3 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,kilometers "${outfile2}"
ncatted -O -a units,projection_x_coordinate,o,c,kilometers "${outfile2}"
elif [ $unitchoice -eq 4 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,meters "${outfile2}"
ncatted -O -a units,projection_x_coordinate,o,c,meters "${outfile2}"
elif [ $unitchoice -eq 5 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,kilometers "${outfile2}"
ncatted -O -a units,projection_x_coordinate,o,c,kilometers "${outfile2}"
fi

################################
#cool, so our entire water year of SWED is now converted over properly to .nc. 
#Let us now extract just the final day and rename it appropriately. First, figure out
#number of time steps in the file.
numsteps=$(/scratch/cdo/bin/cdo -ntime "${outfile1}")

#do swed wo_assim
singleday="${smpath}ctl_files/wo_assim/${STAMP}_swed_wo_assim.nc"
/scratch/cdo/bin/cdo -seltimestep,$numsteps $outfile1 $singleday

#do snod wo_assim
singleday="${smpath}ctl_files/wo_assim/${STAMP}_snod_wo_assim.nc"
/scratch/cdo/bin/cdo -seltimestep,$numsteps $outfile2 $singleday

#clean up a bit
rm "${outfile1}"
rm "${infile1}"
rm "${outfile2}"
rm "${infile2}"

################################
#next, we want to convert this .nc to a geotiff. We can do this with gdal. The synatx:
#>>gdal_translate -of GTiff -a_srs EPSG:xxxx file.nc file.tif
#the -of GTiff requests tiff as output format. The -a_srs EPSG:xxxx sets the projection
#the -a_ullr fixes the weird 'shift' issue we have been having!
fin="${smpath}ctl_files/wo_assim/${STAMP}_swed_wo_assim.nc"
fout="${smpath}ctl_files/wo_assim/${STAMP}_swed_wo_assim.tif"
gdal_translate -of GTiff -a_srs EPSG:32610 -a_ullr 570350 4955850 652450 4832750 $fin $fout
#clean up
rm "${fin}"

fin="${smpath}ctl_files/wo_assim/${STAMP}_snod_wo_assim.nc"
fout="${smpath}ctl_files/wo_assim/${STAMP}_snod_wo_assim.tif"
gdal_translate -of GTiff -a_srs EPSG:32610 -a_ullr 570350 4955850 652450 4832750 $fin $fout
#clean up
rm "${fin}"

################################
#next, let's set values of zero swe to be 'nodata' values. In this way, when we plot the
#tif, those cells will be transparent. I tested this in QGIS and they do show up 
#transparent. Need to deactivate conda and then reactivate it, in order to access
#gdal_calc
source /nfs/attic/dfh/miniconda/bin/activate cso
fin="${smpath}ctl_files/wo_assim/${STAMP}_swed_wo_assim.tif"
fout="${smpath}ctl_files/wo_assim/${STAMP}_mask_swed_wo_assim.tif"
python /nfs/attic/dfh/miniconda/envs/cso/bin/gdal_calc.py -A $fin --outfile=$fout --calc="A*(A>0)" --NoDataValue=0
#clean up
rm "${fin}"

fin="${smpath}ctl_files/wo_assim/${STAMP}_snod_wo_assim.tif"
fout="${smpath}ctl_files/wo_assim/${STAMP}_mask_snod_wo_assim.tif"
python /nfs/attic/dfh/miniconda/envs/cso/bin/gdal_calc.py -A $fin --outfile=$fout --calc="A*(A>0)" --NoDataValue=0
rm "${fin}"
conda deactivate

################################
#cloud optimized geotiff...
fin="${smpath}ctl_files/wo_assim/${STAMP}_mask_swed_wo_assim.tif"
fout="${smpath}ctl_files/wo_assim/${STAMP}_mask_cog_swed_wo_assim.tif"
gdal_translate $fin $fout -co TILED=YES -co COPY_SRC_OVERVIEWS=YES -co COMPRESS=DEFLATE
rm -f $fin
fin="${smpath}ctl_files/wo_assim/${STAMP}_swed_wo_assim.tif"
mv $fout $fin
rm -f $fout
gsutil cp $fin gs://cso_test_upload/or_domain/swed_wo_assim/

#let's move it to /scratch and get it off of depot
fout="${outpath}${STAMP}_swed_wo_assim.tif"
mv $fin $fout

fin="${smpath}ctl_files/wo_assim/${STAMP}_mask_snod_wo_assim.tif"
fout="${smpath}ctl_files/wo_assim/${STAMP}_mask_cog_snod_wo_assim.tif"
gdal_translate $fin $fout -co TILED=YES -co COPY_SRC_OVERVIEWS=YES -co COMPRESS=DEFLATE
rm -f $fin
fin="${smpath}ctl_files/wo_assim/${STAMP}_snod_wo_assim.tif"
mv $fout $fin
rm -f $fout
gsutil cp $fin gs://cso_test_upload/or_domain/snod_wo_assim/

#let's move it to /scratch and get it off of depot
fout="${outpath}${STAMP}_snod_wo_assim.tif"
mv $fin $fout