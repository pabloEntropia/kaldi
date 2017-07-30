
# VOCTRO RUN FORWARD PPG FOR AN AUDIO FOLDER WITH MULTIPLE RECORDINGS FROM THE SAME SPEAKER/SINGER

echo ============================================================================
echo "         Audio to Posterior PhonoGrams (PPG) computation           "
echo "         Voctro Labs. Barcelona. 2017.                             "
echo "        (scripts based on Kaldi project TIMIT recipes)             "
echo ============================================================================



# Config:

. ./cmd_local.sh ## Voctro command tools (without GPU)
. ./path.sh ## Source the tools/utils (import the queue.pl)


# INPUT DATA:
# name of the database to be trained (used as speaker id)
if [ $# != 3 ]; then

system=$1
name_db=$2

# folder with all WAV files from a single speaker/singer.
input_audio_path=/home/pablo/upf/mt/datasets/$name_db

# data folder where the GMM/DNN models are stored. Internal is data stored in this folder too.
input_data_path=/home/pablo/upf/mt/software/data
exp_data_path=/home/pablo/upf/mt/software/exp


# folder to save the data
output_data_path=/home/pablo/upf/mt/results/$system


#OUTPUT DATA:
# output folder where the output features are stored (.numpy and .png files)
output_data_path=$output_data_path/mfcc-kaldi/$name_db
# output_mfcc_data_path=$output_data_path/mfcc_world/$name_db
mkdir -p $output_data_path
# mkdir -p $output_mfcc_data_path

# PARAMETERS
njobs=1 # we are running one job only
feats_nj=$njobs



echo ============================================================================
echo "         Prepare data (from WAV 16bit to SPH format as in TIMIT)          "
echo ============================================================================

audio_input_format_data_voctro.sh $input_audio_path $name_db ${input_data_path} || exit 1
echo "audio folder preprocessing done!"



echo ============================================================================
echo "            MFCC Kaldi Feature Extraction for single audio file             "
echo ============================================================================


#    echo "Usage: $0 [options] <data-dir> [<log-dir> [<fbank-dir>] ]";
steps/make_mfcc_voctro.sh --cmd "$train_cmd" --nj $njobs $input_data_path $input_data_path/log $output_data_path

# export features as ASCII
fbank_file_out=$output_data_path/raw_mfcc_voctro.1.ark
../../../src/featbin/copy-feats ark:"$fbank_file_out" ark,t:"${fbank_file_out%.ark}.ascii";

# Saving as Numpy Data
python plot_data_voctro.py "${fbank_file_out%.ark}.ascii" $output_data_path


echo ============================================================================
echo "                   Removing asci and ark data                             "
echo ============================================================================

rm $fbank_file_out
rm ${fbank_file_out%.ark}.ascii
rm ${fbank_file_out%.ark}.scp

fi
exit 0;
