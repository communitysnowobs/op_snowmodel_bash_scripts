################################
#time to clean up a bit...delete ssmt and sspr grads files, both in 
#the wo_assim and the wi_assim folders. We just don't need them. 

smpath="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/wy_snowmodel_assim/"

################################
#Next, a TON of data repackaging.
#convert the grads output to .nc
/scratch/cdo/bin/cdo -f nc import_binary "${smpath}ctl_files/wo_assim/swed.ctl" "${smpath}ctl_files/wo_assim/swed.nc"
/scratch/cdo/bin/cdo -f nc import_binary "${smpath}ctl_files/wi_assim/swed.ctl" "${smpath}ctl_files/wi_assim/swed.nc"
/scratch/cdo/bin/cdo -f nc import_binary "${smpath}ctl_files/wo_assim/snod.ctl" "${smpath}ctl_files/wo_assim/snod.nc"
/scratch/cdo/bin/cdo -f nc import_binary "${smpath}ctl_files/wi_assim/snod.ctl" "${smpath}ctl_files/wi_assim/snod.nc"

#use cdo to reset the time axis.
/scratch/cdo/bin/cdo settaxis,$year-$month-$day,00:00:00,1days "${smpath}ctl_files/wo_assim/swed.nc" "${smpath}ctl_files/wo_assim/swed2.nc"
/scratch/cdo/bin/cdo settaxis,$year-$month-$day,00:00:00,1days "${smpath}ctl_files/wi_assim/swed.nc" "${smpath}ctl_files/wi_assim/swed2.nc"
/scratch/cdo/bin/cdo settaxis,$year-$month-$day,00:00:00,1days "${smpath}ctl_files/wo_assim/snod.nc" "${smpath}ctl_files/wo_assim/snod2.nc"
/scratch/cdo/bin/cdo settaxis,$year-$month-$day,00:00:00,1days "${smpath}ctl_files/wi_assim/snod.nc" "${smpath}ctl_files/wi_assim/snod2.nc"
