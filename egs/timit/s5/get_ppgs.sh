
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

# folder with all WAV files from a single speaker/singer.
input_audio_path=/home/pablo/upf/mt/datasets/$name_db

# data folder where the GMM/DNN models are stored. Internal is data stored in this folder too.
input_data_path=/home/pablo/upf/mt/software/data
exp_data_path=/home/pablo/upf/mt/software/exp
mfcc_data_dir=/home/pablo/upf/mt/software/mfcc_data
fmllr_data_dir=/home/pablo/upf/mt/software/fmllr_data

# folder to save the data
output_data_path=/home/pablo/upf/mt/results/


#OUTPUT DATA:
# output folder where the output features are stored (.numpy and .png files)
output_bn_data_path=$output_data_path/ppgs_fmllr/$name_db
mkdir -p $output_bn_data_path

# PARAMETERS
njobs=1 # we are running one job only
feats_nj=$njobs



echo ============================================================================
echo "         Prepare data (from WAV 16bit to SPH format as in TIMIT)          "
echo ============================================================================

audio_input_format_data_voctro.sh $input_audio_path $name_db ${input_data_path} || exit 1
echo "audio folder preprocessing done!"



echo ============================================================================
echo "         MFCC Feature Extration & CMVN for single audio file          "
echo ============================================================================

# Now make MFCC features.
# "Usage: $0 [options] <data-dir> [<log-dir> [<mfcc-dir>] ]";
steps/make_mfcc_voctro.sh --cmd "$train_cmd" --nj $njobs $input_data_path $mfcc_data_dir/log $mfcc_data_dir
# export features as ASCII
#mfcc_file_out=$data_mfcc/raw_mfcc_voctro.1.ark
#../../../src/featbin/copy-feats ark:"$mfcc_file_out" ark,t:"${mfcc_file_out%.ark}.ascii";

# store PGP image as PNG
# python plot_data_voctro.py "${mfcc_file_out%.ark}.ascii" $output_mfcc_data_path
echo "MFCC done!"

# "Usage: $0 [options] <data-dir> [<log-dir> [<cmvn-dir>] ]";
steps/compute_cmvn_stats.sh $input_data_path $mfcc_data_dir/log $mfcc_data_dir

cmvn_file_out=$data_mfcc/cmvn_kaldi-data.ark
# ../../../src/featbin/copy-feats ark:"$cmvn_file_out" ark,t:"${cmvn_file_out%.ark}.ascii";
echo "CVMN done!"



echo ============================================================================
echo "         Get  fMLLR Transform Matrix                                      "
echo ============================================================================

# Trained GMM model folder
gmm_dir=$exp_data_path/gmm #  Trained model: GMM directory (originally in exp/tri3)
decode_dir=$gmm_dir/decode
graph_dir=$gmm_dir/graph

steps/decode_fmllr_voctro.sh --nj $njobs --skip-scoring true --cmd "$decode_cmd" \
$graph_dir $input_data_path $decode_dir



echo ============================================================================
echo "         Run fMLLR features computation for single file                   "
echo ============================================================================

data_fmllr=$exp_data_path/fmllr

# Here for forward path with speakers not used in the training we do not use transformation (use make_fmllr_feats_voctro.sh otherwise)
# "Usage: $0 [options] <tgt-data-dir> <src-data-dir> <gmm-dir> <log-dir> <fea-dir> <name>"
steps/nnet/make_fmllr_feats_pablo.sh --nj $njobs --cmd "$train_cmd" \
--transform-dir $decode_dir \
$fmllr_data_dir $input_data_path $gmm_dir $data_fmllr/log $data_fmllr voctro

#../../../src/featbin/copy-feats ark:"$data_fmllr/feats_fmllr_${name_db}.1.ark" ark,t:"$data_fmllr/feats_fmllr_${name_db}.1.ascii";

# python plot_data_voctro.py "$data_fmllr/data/feats_fmllr_${name_db}.1.ascii" $output_fMLLR_data_path



echo ============================================================================
echo "         Run DNN Forward path to compute output PPG features          "
echo ============================================================================

# TESTING WITH ONE ARK FILE WITH FMLRR features
# We just call it using .ark files to understand the mechanism of in/out files:
# Output folder for bottle-neck (BN) features
file_in=$data_fmllr/feats_fmllr_voctro.1.ark
file_out=$output_bn_data_path/raw_bnfea_voctro.1.ark

# set nnet filename
file_nnet=$exp_data_path/nnet/feature_extractor.nnet

# run the forward net
nnet-forward --use-gpu=no $file_nnet ark:$file_in ark:$file_out


echo ============================================================================
echo "         Export features files (.npy format) and save PPG images          "
echo ============================================================================

# export features as ASCII
 ../../../src/featbin/copy-feats ark:"$file_out" ark,t:"${file_out%.ark}.ascii";

# store PGP image as PNG
 python plot_data_voctro.py "${file_out%.ark}.ascii" $output_bn_data_path


echo ============================================================================
echo "                   Removing asci and ark data                             "
echo ============================================================================

#rm $fbank_file_out
#rm ${fbank_file_out%.ark}.ascii

#rm $mfcc_file_out
#rm ${mfcc_file_out%.ark}.ascii

rm $file_out
rm ${file_out%.ark}.ascii
