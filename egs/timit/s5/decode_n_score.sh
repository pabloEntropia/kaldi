
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
name_db=$1
genre=$2
# data folder where the GMM/DNN models are stored. Internal is data stored in this folder too.
input_data_path=/home/pablo/upf/mt/software/fmllr_data
# folder to save the data
output_data_path=/home/pablo/upf/mt/results/

exp_data_path=/home/pablo/upf/mt/software/exp

text_path=/home/pablo/upf/mt/software/text/$name_db


python lab2text.py $text_path $name_db $genre

#OUTPUT DATA:

output_decode=$output_data_path/Decode/$name_db
mkdir -p $output_decode

# PARAMETERS
njobs=1 # we are running one job only

graphdir=$exp_data_path/gmm/graph
decode_dir=$exp_data_path/gmm/nnet_decode
nnet_dir=$exp_data_path/nnet/feature_extractor.nnet

# "Usage: $0 [options] <graph-dir> <data-dir> <decode-dir>"
steps/nnet/decode_pablo.sh --nj $njobs --nnet $nnet_dir \
$graphdir $input_data_path $decode_dir $text_path
