
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
if [ $# != 4 ]; then

system=$1
name_db=$2
genre=$3

#get_world_ppgs.sh $system $name_db || exit 1

# data folder where the GMM/DNN models are stored. Internal is data stored in this folder too.
input_data_path=/home/pablo/upf/mt/software/fmllr_data
# folder to save the data
output_data_path=/home/pablo/upf/mt/results/$system

exp_data_path=/home/pablo/upf/mt/software/exp

text_path=/home/pablo/upf/mt/software/text/$name_db


python lab2text.py $text_path $name_db $genre

#OUTPUT DATA:

output_decode=$output_data_path/Decode/$name_db
mkdir -p $output_decode

# PARAMETERS
njobs=1 # we are running one job only. Can't be grater thant the number of speakers

graphdir=$exp_data_path/gmm/$system/graph
decode_dir=$exp_data_path/gmm/$system/"$name_db"-decode
nnet_dir=$exp_data_path/nnet/$system/feature_extractor.nnet

# "Usage: $0 [options] <graph-dir> <data-dir> <decode-dir>" ### What to do?
steps/nnet/decode_pablo.sh --cmd "$decode_cmd" --acwt 0.1 --nj $njobs --nnet $nnet_dir \
$graphdir $input_data_path $decode_dir $text_path

fi
exit 0;
