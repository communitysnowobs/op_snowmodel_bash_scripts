#! /bin/bash
#to backfill ca domain for WY 2021...to use this, you need to have a swed.nc file
#from a snowmodel run (say, from the operational run). You would use this script if you wanted to replace
#the daily grids in my Google Cloud Storage (say you recalibrated the model, e.g.).
#same for snod.nc

#reset time axis to start 1 Oct of present water year
#get today's date info and figure out year of current water year
day=$(date '+%d')
month=$(date '+%b')
monthnum=$(date '+%m')
year=$(date '+%Y')
if [ $((10#$monthnum)) -lt 10 ]
then
	year=$(($year - 1))
fi

echo "$year"

echo "$year-10-01"

numsteps=10
echo "$numsteps"

for ((i=0; i<=numsteps-1; i++))
do
d=$(date -d "2020-10-01 +${i} days" '+%d')
echo "$d"
m=$(date -d "2020-10-01 +${i} days" '+%m')
echo "$m"
y=$(date -d "2020-10-01 +${i} days" '+%Y')
echo "$y"
done