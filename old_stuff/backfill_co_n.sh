#! /bin/bash
#to backfill co_n domain for WY 2021...to use this, you need to have a swed.nc file
#from a snowmodel run (say, from the operational run). You would use this script if you wanted to replace
#the daily grids in my Google Cloud Storage (say you recalibrated the model, e.g.).
#same for snod.nc

#have user set year, month, day of the start of the model run (typically Oct 1 of a given year)
year=2020
month=10
day=01

#define main path
smpath="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/co_n_snowmodel/"
#define output path on scratch
outpath="/scratch/op_snowmodel_outputs/CO_N/"

#use cdo to reset time axis
/scratch/cdo/bin/cdo settaxis,$year-$month-$day,00:00:00,1days \
    "${smpath}ctl_files/wo_assim/swed.nc" "${smpath}ctl_files/wo_assim/swed2.nc"
/scratch/cdo/bin/cdo settaxis,$year-$month-$day,00:00:00,1days \
    "${smpath}ctl_files/wo_assim/snod.nc" "${smpath}ctl_files/wo_assim/snod2.nc"

#next, we are going to mess with the .nc metadata. CDO treats files as lon / lat, whereas
#we have projected coords out of SnowModel.
#DO SWED FIRST
infile1="${smpath}ctl_files/wo_assim/swed2.nc"
outfile1="${smpath}ctl_files/wo_assim/swed3.nc"
ncrename -O -v .lat,projection_y_coordinate -d .lat,projection_y_coordinate -v \
    .lon,projection_x_coordinate -d .lon,projection_x_coordinate "${infile1}" "${outfile1}"

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

#cool, so our entire water year of SWED is now converted over properly to .nc.
#Next, figure out the number of time steps in the file.
numsteps=$(/scratch/cdo/bin/cdo -ntime "${outfile2}")

#mkdir to store the individual time slices.
mkdir -p "${smpath}ctl_files/wo_assim/SWE"
mkdir -p "${smpath}ctl_files/wo_assim/HS"

for ((i=0; i<= $numsteps-1; i++));
do
d=$(date -d "${year}-${month}-${day} +${i} days" '+%d')
m=$(date -d "${year}-${month}-${day} +${i} days" '+%m')
y=$(date -d "${year}-${month}-${day} +${i} days" '+%Y')
stamp="${y}_${m}_${d}"
echo $stamp
singledayswe="${smpath}ctl_files/wo_assim/SWE/$stamp.nc"
singledayhs="${smpath}ctl_files/wo_assim/HS/$stamp.nc"
j=$(($i+1))
echo $j
/scratch/cdo/bin/cdo -seltimestep,$j $outfile1 $singledayswe
/scratch/cdo/bin/cdo -seltimestep,$j $outfile2 $singledayhs

#next, we want to convert this .nc to a geotiff. We can do this with gdal. The synatx:
#>>gdal_translate -of GTiff -a_srs EPSG:xxxx file.nc file.tif
#the -of GTiff requests tiff as output format. The -a_srs EPSG:xxxx sets the projection
#the -a_ullr fixes a slight grid offset.
fin="${smpath}ctl_files/wo_assim/SWE/$stamp.nc"
fout="${smpath}ctl_files/wo_assim/SWE/$stamp.tif"
gdal_translate -of GTiff -a_srs EPSG:32613 -a_ullr 278150 4452450 465350 4246850 $fin $fout
rm -f $fin

fin="${smpath}ctl_files/wo_assim/HS/$stamp.nc"
fout="${smpath}ctl_files/wo_assim/HS/$stamp.tif"
gdal_translate -of GTiff -a_srs EPSG:32613 -a_ullr 278150 4452450 465350 4246850 $fin $fout
rm -f $fin

#next, let's set values of zero swe to be 'nodata' values. In this way, when we plot the
#tif, those cells will be transparent. I tested this in QGIS and they do show up
#transparent. Need to deactivate conda and then reactivate it, in order to access
#gdal_calc
source /nfs/attic/dfh/miniconda/bin/activate cso
fin="${smpath}ctl_files/wo_assim/SWE/$stamp.tif"
fout="${smpath}ctl_files/wo_assim/SWE/${stamp}_mask.tif"
python /nfs/attic/dfh/miniconda/envs/cso/bin/gdal_calc.py -A $fin --outfile=$fout --calc="A*(A>0)" --NoDataValue=0
rm -f $fin

fin="${smpath}ctl_files/wo_assim/HS/$stamp.tif"
fout="${smpath}ctl_files/wo_assim/HS/${stamp}_mask.tif"
python /nfs/attic/dfh/miniconda/envs/cso/bin/gdal_calc.py -A $fin --outfile=$fout --calc="A*(A>0)" --NoDataValue=0
rm -f $fin
conda deactivate

#cloud optimized geotiff...
fin="${smpath}ctl_files/wo_assim/SWE/${stamp}_mask.tif"
fout="${smpath}ctl_files/wo_assim/SWE/${stamp}_swed_wo_assim.tif"
gdal_translate $fin $fout -co TILED=YES -co COPY_SRC_OVERVIEWS=YES -co COMPRESS=DEFLATE
rm -f $fin
gsutil cp $fout gs://cso_test_upload/co_n_domain/swed_wo_assim/

#let's move it to /scratch and get it off of depot
mv $fout "${outpath}${stamp}_swed_wo_assim.tif"

fin="${smpath}ctl_files/wo_assim/HS/${stamp}_mask.tif"
fout="${smpath}ctl_files/wo_assim/HS/${stamp}_snod_wo_assim.tif"
gdal_translate $fin $fout -co TILED=YES -co COPY_SRC_OVERVIEWS=YES -co COMPRESS=DEFLATE
rm -f $fin
gsutil cp $fout gs://cso_test_upload/co_n_domain/snod_wo_assim/

#let's move it to /scratch and get it off of depot
mv $fout "${outpath}${stamp}_snod_wo_assim.tif"

done

#clean up a bit
rm "${outfile1}"
rm "${infile1}"
rm "${outfile2}"
rm "${infile2}"
