#!/bin/bash

# this will run inside the singularity container

 export HOME_CONTAINER=/singularity_home/ 
 export BOTS_DIR=$HOME_CONTAINER/Resibots 
 export SFERES_DIR=$HOME_CONTAINER/sferes2
 export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib/x86_64-linux-gnu:/lib:/usr/lib:/usr/local/lib:/usr/lib/x86_64-linux-gnu:$BOTS_DIR/lib

source activate
binary_type=$1
replicate_number=$2
RESULTS_DIR=$3 # destination folder

mkdir $RESULTS_DIR
mkdir $RESULTS_DIR/${binary_type}_${control_type}
outputdir="${RESULTS_DIR}/${binary_type}/exp${replicate_number}"
mkdir ${outputdir}
binary=${SFERES_DIR}/build/exp/Rhexps/rhex_metaCMAES_${binary_type}_binary
currentdir=$PWD
# get the last filename
max="-1"
get_last_filename()
{
# get the last filename
shopt -s extglob
cd ${outputdir}
files=`ls -d !(*.*)` # gen_files don't have extension
for gen_file in $files; do
	number=${gen_file#"gen_"}
	#echo $number
	if (( $number > $max )); then
    		max=$number
	fi

done
}

get_last_filename
echo "max generation found is $max"
cd $currentdir
echo "am now in $PWD"
if (( $max > 0 )); then
	echo "will resume at ${outputdir}/gen_$max"
	${binary} ${replicate_number} --d ${outputdir} --number-threads 40 --resume ${outputdir}/gen_$max >> ${outputdir}/log.txt
else
	echo "will start new run"
	${binary} ${replicate_number} --d ${outputdir} --number-threads 40 >> ${outputdir}/log.txt
fi
