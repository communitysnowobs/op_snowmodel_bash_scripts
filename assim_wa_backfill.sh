#! /bin/bash
#this will test out the full operational flow for WA for assim...

#have user set year, month, day of the start of the model run (typically Oct 1 of a given year)
year=2020
month=10
day=01

#define main path
smpath="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/wa_ne_snowmodel/"
#define output path on scratch
outpath="/scratch/op_snowmodel_outputs/WA/"

#end of model run
#d=30
#m=9
#y=2021

################################
#run the query for met --> adjust this python script to manual dates!
cd /nfs/depot/cce_u1/hill/dfh/op_snowmodel/op_snowmodel_python_scripts
source /nfs/attic/dfh/miniconda/bin/activate ee
ipython met_data_backfill_wa.py
conda deactivate

################################
#run assim snowmodel... --> adjust to manual dates.
cd /nfs/depot/cce_u1/hill/dfh/op_snowmodel/op_snowmodel_python_scripts
source /nfs/attic/dfh/miniconda/bin/activate snowmodelcal
ipython assim_backfill_wa.py
conda deactivate

echo
echo "snowmodel has finished"
echo

################################
#time to clean up a bit...delete ssmt and sspr grads files, both in 
#the wo_assim and the wi_assim folders. We just don't need them. 

smpath="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/wa_ne_snowmodel/"
#define output path on scratch
outpath="/scratch/op_snowmodel_outputs/WA/"

rm "${smpath}outputs/wi_assim/ssmt.gdat"
rm "${smpath}outputs/wi_assim/sspr.gdat"
rm "${smpath}outputs/wo_assim/ssmt.gdat"
rm "${smpath}outputs/wo_assim/sspr.gdat"

################################
#Next, a TON of data repackaging.
#convert the grads output to .nc
/scratch/cdo/bin/cdo -f nc import_binary "${smpath}ctl_files/wo_assim/swed.ctl" "${smpath}ctl_files/wo_assim/swed.nc"
/scratch/cdo/bin/cdo -f nc import_binary "${smpath}ctl_files/wi_assim/swed.ctl" "${smpath}ctl_files/wi_assim/swed.nc"
/scratch/cdo/bin/cdo -f nc import_binary "${smpath}ctl_files/wo_assim/snod.ctl" "${smpath}ctl_files/wo_assim/snod.nc"
/scratch/cdo/bin/cdo -f nc import_binary "${smpath}ctl_files/wi_assim/snod.ctl" "${smpath}ctl_files/wi_assim/snod.nc"

echo
echo "done converting to nc"
echo

#clean up more...we can deled snod and swed gdats (huge files) since we have the .nc now
rm "${smpath}outputs/wi_assim/swed.gdat"
rm "${smpath}outputs/wi_assim/snod.gdat"
rm "${smpath}outputs/wo_assim/swed.gdat"
rm "${smpath}outputs/wo_assim/snod.gdat"

#use cdo to reset the time axis.
/scratch/cdo/bin/cdo settaxis,$year-$month-$day,00:00:00,1days "${smpath}ctl_files/wo_assim/swed.nc" "${smpath}ctl_files/wo_assim/swed2.nc"
/scratch/cdo/bin/cdo settaxis,$year-$month-$day,00:00:00,1days "${smpath}ctl_files/wi_assim/swed.nc" "${smpath}ctl_files/wi_assim/swed2.nc"
/scratch/cdo/bin/cdo settaxis,$year-$month-$day,00:00:00,1days "${smpath}ctl_files/wo_assim/snod.nc" "${smpath}ctl_files/wo_assim/snod2.nc"
/scratch/cdo/bin/cdo settaxis,$year-$month-$day,00:00:00,1days "${smpath}ctl_files/wi_assim/snod.nc" "${smpath}ctl_files/wi_assim/snod2.nc"

echo
echo " done resetting time axis"
echo

#next, we are going to mess with the .nc metadata. CDO treats files as lon / lat, whereas
#we have projected coords out of SnowModel.
# DO SWED (WO_ASSIM) FIRST
################################
#First, change variable and dimension names
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

# DO SWED (WI_ASSIM) next
################################
#First, change variable and dimension names
infile2="${smpath}ctl_files/wi_assim/swed2.nc"
outfile2="${smpath}ctl_files/wi_assim/swed3.nc"
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

# DO SNOD (WO_ASSIM) next
################################
#First, change variable and dimension names
infile3="${smpath}ctl_files/wo_assim/snod2.nc"
outfile3="${smpath}ctl_files/wo_assim/snod3.nc"
ncrename -O -v .lat,projection_y_coordinate -d .lat,projection_y_coordinate -v .lon,projection_x_coordinate -d .lon,projection_x_coordinate "${infile3}" "${outfile3}"

#Next, change attributes
ncatted -O -a long_name,projection_y_coordinate,o,c,y "${outfile3}"
ncatted -O -a standard_name,projection_y_coordinate,o,c,y "${outfile3}"
ncatted -O -a long_name,projection_x_coordinate,o,c,x "${outfile3}"
ncatted -O -a standard_name,projection_x_coordinate,o,c,x "${outfile3}"

#check on unitchoice and change .nc file appropriately
if [ $unitchoice -eq 1 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,index "${outfile3}"
ncatted -O -a units,projection_x_coordinate,o,c,index "${outfile3}"
elif [ $unitchoice -eq 2 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,meters "${outfile3}"
ncatted -O -a units,projection_x_coordinate,o,c,meters "${outfile3}"
elif [ $unitchoice -eq 3 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,kilometers "${outfile3}"
ncatted -O -a units,projection_x_coordinate,o,c,kilometers "${outfile3}"
elif [ $unitchoice -eq 4 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,meters "${outfile3}"
ncatted -O -a units,projection_x_coordinate,o,c,meters "${outfile3}"
elif [ $unitchoice -eq 5 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,kilometers "${outfile3}"
ncatted -O -a units,projection_x_coordinate,o,c,kilometers "${outfile3}"
fi

# DO SNOD (WI_ASSIM) last
################################
#First, change variable and dimension names
infile4="${smpath}ctl_files/wi_assim/snod2.nc"
outfile4="${smpath}ctl_files/wi_assim/snod3.nc"
ncrename -O -v .lat,projection_y_coordinate -d .lat,projection_y_coordinate -v .lon,projection_x_coordinate -d .lon,projection_x_coordinate "${infile4}" "${outfile4}"

#Next, change attributes
ncatted -O -a long_name,projection_y_coordinate,o,c,y "${outfile4}"
ncatted -O -a standard_name,projection_y_coordinate,o,c,y "${outfile4}"
ncatted -O -a long_name,projection_x_coordinate,o,c,x "${outfile4}"
ncatted -O -a standard_name,projection_x_coordinate,o,c,x "${outfile4}"

#check on unitchoice and change .nc file appropriately
if [ $unitchoice -eq 1 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,index "${outfile4}"
ncatted -O -a units,projection_x_coordinate,o,c,index "${outfile4}"
elif [ $unitchoice -eq 2 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,meters "${outfile4}"
ncatted -O -a units,projection_x_coordinate,o,c,meters "${outfile4}"
elif [ $unitchoice -eq 3 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,kilometers "${outfile4}"
ncatted -O -a units,projection_x_coordinate,o,c,kilometers "${outfile4}"
elif [ $unitchoice -eq 4 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,meters "${outfile4}"
ncatted -O -a units,projection_x_coordinate,o,c,meters "${outfile4}"
elif [ $unitchoice -eq 5 ]
then
ncatted -O -a units,projection_y_coordinate,o,c,kilometers "${outfile4}"
ncatted -O -a units,projection_x_coordinate,o,c,kilometers "${outfile4}"
fi

echo
echo "done editing metadata"
echo

################################
#great, so our grids are all now properly converted to nc format. Next, let us figure
#out how many time steps in the file(s).
numsteps=$(/scratch/cdo/bin/cdo -ntime "${outfile4}")
echo $numsteps

#mkdir to store the individual time slices.
mkdir -p "${smpath}ctl_files/wo_assim/SWE"
mkdir -p "${smpath}ctl_files/wo_assim/HS"
mkdir -p "${smpath}ctl_files/wi_assim/SWE"
mkdir -p "${smpath}ctl_files/wi_assim/HS"

#start a loop to deal with each day.

for ((i=0; i<= $numsteps-1; i++));
do
d=$(date -d "${year}-${month}-${day} +${i} days" '+%d')
m=$(date -d "${year}-${month}-${day} +${i} days" '+%m')
y=$(date -d "${year}-${month}-${day} +${i} days" '+%Y')
stamp="${y}_${m}_${d}"

echo
echo $stamp
j=$(($i+1))
echo $j

#pull out individual day .nc files.
singleday="${smpath}ctl_files/wo_assim/SWE/$stamp.nc"
/scratch/cdo/bin/cdo -seltimestep,$j $outfile1 $singleday

singleday="${smpath}ctl_files/wo_assim/HS/$stamp.nc"
/scratch/cdo/bin/cdo -seltimestep,$j $outfile3 $singleday

singleday="${smpath}ctl_files/wi_assim/SWE/$stamp.nc"
/scratch/cdo/bin/cdo -seltimestep,$j $outfile2 $singleday

singleday="${smpath}ctl_files/wi_assim/HS/$stamp.nc"
/scratch/cdo/bin/cdo -seltimestep,$j $outfile4 $singleday


################################
#next, we want to convert this .nc to a geotiff. We can do this with gdal. The synatx:
#>>gdal_translate -of GTiff -a_srs EPSG:xxxx file.nc file.tif
#the -of GTiff requests tiff as output format. The -a_srs EPSG:xxxx sets the projection
#the -a_ullr fixes the weird 'shift' issue we have been having!
fin="${smpath}ctl_files/wo_assim/SWE/$stamp.nc"
fout="${smpath}ctl_files/wo_assim/SWE/$stamp.tif"
gdal_translate -q -of GTiff -a_srs EPSG:32610 -a_ullr 638925 5421375 741525 5299075 $fin $fout
rm -f $fin

echo "1st gdal done"

fin="${smpath}ctl_files/wo_assim/HS/$stamp.nc"
fout="${smpath}ctl_files/wo_assim/HS/$stamp.tif"
gdal_translate -q -of GTiff -a_srs EPSG:32610 -a_ullr 638925 5421375 741525 5299075 $fin $fout
rm -f $fin

fin="${smpath}ctl_files/wi_assim/SWE/$stamp.nc"
fout="${smpath}ctl_files/wi_assim/SWE/$stamp.tif"
gdal_translate -q -of GTiff -a_srs EPSG:32610 -a_ullr 638925 5421375 741525 5299075 $fin $fout
rm -f $fin

fin="${smpath}ctl_files/wi_assim/HS/$stamp.nc"
fout="${smpath}ctl_files/wi_assim/HS/$stamp.tif"
gdal_translate -q -of GTiff -a_srs EPSG:32610 -a_ullr 638925 5421375 741525 5299075 $fin $fout
rm -f $fin

################################
#next, let's set values of zero to be 'nodata' values. In this way, when we plot the
#tif, those cells will be transparent. I tested this in QGIS and they do show up 
#transparent. Need to deactivate conda and then reactivate it, in order to access
#gdal_calc
source /nfs/attic/dfh/miniconda/bin/activate cso
fin="${smpath}ctl_files/wo_assim/SWE/$stamp.tif"
fout="${smpath}ctl_files/wo_assim/SWE/${stamp}_mask.tif"
python /nfs/attic/dfh/miniconda/envs/cso/bin/gdal_calc.py -A $fin --outfile=$fout --calc="A*(A>0.001)" --NoDataValue=0 --quiet
rm -f $fin

fin="${smpath}ctl_files/wo_assim/HS/$stamp.tif"
fout="${smpath}ctl_files/wo_assim/HS/${stamp}_mask.tif"
python /nfs/attic/dfh/miniconda/envs/cso/bin/gdal_calc.py -A $fin --outfile=$fout --calc="A*(A>0.01)" --NoDataValue=0 --quiet
rm -f $fin

fin="${smpath}ctl_files/wi_assim/SWE/$stamp.tif"
fout="${smpath}ctl_files/wi_assim/SWE/${stamp}_mask.tif"
python /nfs/attic/dfh/miniconda/envs/cso/bin/gdal_calc.py -A $fin --outfile=$fout --calc="A*(A>0.001)" --NoDataValue=0 --quiet
rm -f $fin

fin="${smpath}ctl_files/wi_assim/HS/$stamp.tif"
fout="${smpath}ctl_files/wi_assim/HS/${stamp}_mask.tif"
python /nfs/attic/dfh/miniconda/envs/cso/bin/gdal_calc.py -A $fin --outfile=$fout --calc="A*(A>0.01)" --NoDataValue=0 --quiet
rm -f $fin
conda deactivate

echo
echo "done masking"
echo

################################
#convert to cloud optimized geotiff...then clean up and upload.
fin="${smpath}ctl_files/wo_assim/SWE/${stamp}_mask.tif"
fout="${smpath}ctl_files/wo_assim/SWE/${stamp}_swed_wo_assim.tif"
gdal_translate -q $fin $fout -co TILED=YES -co COPY_SRC_OVERVIEWS=YES -co COMPRESS=DEFLATE
rm -f $fin
gsutil cp $fout gs://cso_test_upload/wa_domain/swed_wo_assim/
#let's move it to /scratch and get it off of depot
mv $fout "${outpath}${stamp}_swed_wo_assim.tif"

fin="${smpath}ctl_files/wo_assim/HS/${stamp}_mask.tif"
fout="${smpath}ctl_files/wo_assim/HS/${stamp}_snod_wo_assim.tif"
gdal_translate -q $fin $fout -co TILED=YES -co COPY_SRC_OVERVIEWS=YES -co COMPRESS=DEFLATE
rm -f $fin
gsutil cp $fout gs://cso_test_upload/wa_domain/snod_wo_assim/
#let's move it to /scratch and get it off of depot
mv $fout "${outpath}${stamp}_snod_wo_assim.tif"

fin="${smpath}ctl_files/wi_assim/SWE/${stamp}_mask.tif"
fout="${smpath}ctl_files/wi_assim/SWE/${stamp}_swed_wi_assim.tif"
gdal_translate -q $fin $fout -co TILED=YES -co COPY_SRC_OVERVIEWS=YES -co COMPRESS=DEFLATE
rm -f $fin
gsutil cp $fout gs://cso_test_upload/wa_domain/swed_wi_assim/
#let's move it to /scratch and get it off of depot
mv $fout "${outpath}${stamp}_swed_wi_assim.tif"

fin="${smpath}ctl_files/wi_assim/HS/${stamp}_mask.tif"
fout="${smpath}ctl_files/wi_assim/HS/${stamp}_snod_wi_assim.tif"
gdal_translate -q $fin $fout -co TILED=YES -co COPY_SRC_OVERVIEWS=YES -co COMPRESS=DEFLATE
rm -f $fin
gsutil cp $fout gs://cso_test_upload/wa_domain/snod_wi_assim/
#let's move it to /scratch and get it off of depot
mv $fout "${outpath}${stamp}_snod_wi_assim.tif"

done

  rm "${outfile1}"
  rm "${infile1}"
  rm "${outfile2}"
  rm "${infile2}"
  rm "${outfile3}"
  rm "${infile3}"
  rm "${outfile4}"
  rm "${infile4}"