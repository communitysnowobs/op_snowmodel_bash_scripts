#next, we are going to mess with the .nc metadata. CDO treats files as lon / lat, whereas
#we have projected coords out of SnowModel.
# DO SWED (WO_ASSIM) FIRST
################################

smpath="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/wy_snowmodel_assim/"
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

numsteps=$(/scratch/cdo/bin/cdo -ntime "${outfile4}")
echo $numsteps