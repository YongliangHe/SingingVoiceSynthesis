#!/bin/bash

if test "$#" -ne 4; then
    echo "################################"
    echo "Usage:"
    echo "./08_setup_adapt.sh <voice_name> <duration_trained_model_full_path> <acoustic_trained_model_full_path> <adaptation_method>"
    echo ""
    echo "eg., ./08_setup_adapt.sh adapt_p234 experiments/VCTK_avg/duration_model/nnets_model/feed_forward_6_tanh.model experiments/VCTK_avg/acoustic_model/nnets_model/feed_forward_6_tanh.model fine_tune "
    echo "################################"
    exit 1
fi

setup_data=true

# Adapt one speaker on the AVM
adapt_voice="p234"

# setup directory structure and copy the data
if [ "$setup_data" = true ]; then
    # create a database for each speaker
    for spkid in $adapt_voice; do
        mkdir -p database_$spkid
        mkdir -p database_$spkid/wav
        mkdir -p database_$spkid/txt
        echo "copying the speaker $spkid data to database_$spkid"
        cp VCTK-Corpus/wav48/$spkid/*.wav database_$spkid/wav
        cp VCTK-Corpus/txt/$spkid/*.txt database_$spkid/txt
    done
fi

current_working_dir=$(pwd)
merlin_dir=$(dirname $(dirname $(dirname $current_working_dir)))
experiments_dir=${current_working_dir}/experiments
data_dir=${current_working_dir}/database

# input values
voice_name=$1
dur_trained_model=$2
ac_trained_model=$3
adaptation_method=$4

voice_dir=${experiments_dir}/${voice_name}
acoustic_dir=${voice_dir}/acoustic_model
duration_dir=${voice_dir}/duration_model
synthesis_dir=${voice_dir}/test_synthesis

mkdir -p ${data_dir}
mkdir -p ${experiments_dir}
mkdir -p ${voice_dir}
mkdir -p ${acoustic_dir}
mkdir -p ${duration_dir}
mkdir -p ${synthesis_dir}
mkdir -p ${acoustic_dir}/data
mkdir -p ${duration_dir}/data
mkdir -p ${synthesis_dir}/txt

### create some test files ###
echo "Hello world." > ${synthesis_dir}/txt/test_001.txt
echo "Hi, this is a demo voice from Merlin." > ${synthesis_dir}/txt/test_002.txt
echo "Hope you guys enjoy free open-source voices from Merlin." > ${synthesis_dir}/txt/test_003.txt
printf "test_001\ntest_002\ntest_003" > ${synthesis_dir}/test_id_list.scp

global_config_file=conf/global_settings_adapt.cfg

### default settings ###
echo "######################################" > $global_config_file
echo "############# PATHS ##################" >> $global_config_file
echo "######################################" >> $global_config_file
echo "" >> $global_config_file

echo "MerlinDir=${merlin_dir}" >>  $global_config_file
echo "WorkDir=${current_working_dir}" >>  $global_config_file
echo "" >> $global_config_file

echo "######################################" >> $global_config_file
echo "############# PARAMS #################" >> $global_config_file
echo "######################################" >> $global_config_file
echo "" >> $global_config_file

echo "Voice=${voice_name}" >> $global_config_file
echo "Labels=state_align" >> $global_config_file
echo "QuestionFile=questions-radio_dnn_416.hed" >> $global_config_file
echo "Vocoder=WORLD" >> $global_config_file
echo "SamplingFreq=48000" >> $global_config_file
echo "SilencePhone='sil'" >> $global_config_file
echo "FileIDList=file_id_list.scp" >> $global_config_file
echo "DurTrainedModel=${dur_trained_model}" >> $global_config_file
echo "AcTrainedModel=${ac_trained_model}" >> $global_config_file
echo "AdaptationMethod=${adaptation_method}" >> $global_config_file
echo "" >> $global_config_file

echo "######################################" >> $global_config_file
echo "######### No. of files ###############" >> $global_config_file
echo "######################################" >> $global_config_file
echo "" >> $global_config_file

echo "Train=307" >> $global_config_file 
echo "Valid=25" >> $global_config_file 
echo "Test=25" >> $global_config_file 
echo "" >> $global_config_file

echo "######################################" >> $global_config_file
echo "############# TOOLS ##################" >> $global_config_file
echo "######################################" >> $global_config_file
echo "" >> $global_config_file

#echo "ESTDIR=${merlin_dir}/tools/speech_tools" >> $global_config_file
#echo "FESTDIR=${merlin_dir}/tools/festival" >> $global_config_file
#echo "FESTVOXDIR=${merlin_dir}/tools/festvox" >> $global_config_file
echo "ESTDIR=/l/SRC/speech_tools/bin" >> $global_config_file
echo "FESTDIR=/l/SRC/festival_2_4/festival" >> $global_config_file
echo "FESTVOXDIR=/l/SRC/festvox/" >> $global_config_file
echo "" >> $global_config_file
#echo "HTKDIR=${merlin_dir}/tools/bin/htk" >> $global_config_file
echo "HTKDIR=/l/SRC/htk-3.5/bin" >> $global_config_file
echo "" >> $global_config_file

echo "Step 1:"
echo "Merlin default voice settings configured in \"$global_config_file\""
echo "Modify these params as per your data..."
echo "eg., sampling frequency, no. of train files etc.,"
echo "setup done...!"