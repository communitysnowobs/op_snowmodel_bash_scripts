#! /bin/bash
#this will test out the full operational flow for WA for assim...

#have user set year, month, day of the start of the model run (typically Oct 1 of a given year)
year=2021
month=10
day=01

#define main path
smpath="/nfs/depot/cce_u1/hill/dfh/op_snowmodel/co_s_snowmodel/"
#define output path on scratch
outpath="/scratch/op_snowmodel_outputs/CO_S/"

#end of model run
#d=30
#m=9
#y=2021

################################
#run the query for met --> adjust this python script to manual dates!
cd /nfs/depot/cce_u1/hill/dfh/op_snowmodel/op_snowmodel_python_scripts
source /nfs/attic/dfh/miniconda/bin/activate ee
ipython met_data_backfill_co_s.py
conda deactivate