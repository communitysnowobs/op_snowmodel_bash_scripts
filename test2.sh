#! /bin/bash
year=2020
month=10
day=01

#cool, so our entire water year of SWED is now converted over properly to .nc.
#Next, figure out the number of time steps in the file.
numsteps=10

echo $numsteps

for ((i=0; i<= $numsteps-1; i++));
do
d=$(date -d "${year}-${month}-${day} +${i} days" '+%d')
m=$(date -d "${year}-${month}-${day} +${i} days" '+%m')
y=$(date -d "${year}-${month}-${day} +${i} days" '+%Y')
stamp="${y}_${m}_${d}"
echo $stamp
echo ${i+1}

j=$(($i+1))
echo $j
done
