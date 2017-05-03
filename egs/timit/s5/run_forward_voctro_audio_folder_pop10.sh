
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
# folder with all WAV files from a single speaker/singer.
input_audio_path=/home/pablo/upf/mt/datasets/MALE_POP10
# name of the database to be trained (used as speaker id)
name_db=mpop10
# data folder where the GMM/DNN models are stored. Internal is data stored in this folder too.
input_data_path=/home/pablo/upf/mt/software/kaldi-data


#OUTPUT DATA
# output folder where the PPG output are stored (.numpy and .png files) 
output_bn_data_path=/home/pablo/upf/mt/results/mpop10/ppgs
mkdir -p $output_bn_data_path

output_mfcc_data_path=/home/pablo/upf/mt/results/mpop10/mfccs
mkdir -p $output_mfcc_data_path

# PARAMETERS
njobs=1 # we are running one job only



echo ============================================================================
echo "         Prepare data (from WAV 16bit to SPH format as in TIMIT)          "
echo ============================================================================

audio_input_format_data_voctro.sh $input_audio_path $name_db ${input_data_path} || exit 1
echo "audio folder preprocessing done!" 





echo ============================================================================
echo "         MFCC Feature Extration & CMVN for single audio file          "
echo ============================================================================

# other internal folders where features are generated
data_fmllr=$input_data_path/data_fmllr
data_mfcc=$input_data_path/mfcc



# Now make MFCC features.
src_data_dir=$input_data_path 
mfcc_log_dir=$data_mfcc/log

feats_nj=$njobs

# "Usage: $0 [options] <data-dir> [<log-dir> [<mfcc-dir>] ]";
steps/make_mfcc_voctro.sh --cmd "$train_cmd" --nj $njobs $src_data_dir $mfcc_log_dir $data_mfcc


# export features as ASCII
mfcc_file_out=$data_mfcc/raw_mfcc_voctro.1.ark
../../../src/featbin/copy-feats ark:"$mfcc_file_out" ark,t:"${mfcc_file_out%.ark}.ascii";

# store PGP image as PNG 
python plot_data_voctro.py "${mfcc_file_out%.ark}.ascii" $output_mfcc_data_path/figs


echo "MFCC done!"
steps/compute_cmvn_stats.sh $src_data_dir $mfcc_data_dir $mfccdir
echo "CVMN done!" 



#exit

echo ============================================================================
echo "         Run fMLLR features computation for single file          "
echo ============================================================================

# Trained GMM model folder 
gmmdir=$input_data_path/gmm #  Trained model: GMM directory (originally in exp/tri3)
#gmmdir=exp/tri3 #  Trained model: GMM directory
#transformdir=$gmmdir/decode_test
transformdir=$gmmdir/transformdir

dir=$data_fmllr
src_dir=$input_data_path

# Here for forward path with speakers not used in the training we do not use transformation (use make_fmllr_feats_voctro.sh otherwise) 
 steps/nnet/make_fmllr_feats_voctro_notransf.sh --nj $njobs --cmd "$train_cmd" \
 --transform-dir $transformdir \
 $dir $src_dir $gmmdir $dir/log $dir/data $name_db



echo ============================================================================
echo "         Run DNN Forward path to compute output PPG features          "
echo ============================================================================

# TESTING WITH ONE ARK FILE WITH FMLRR features
# We just call it using .ark files to understand the mechanism of in/out files:
# Output folder for bottle-neck (BN) features
file_in=$data_fmllr/data/feats_fmllr_${name_db}.1.ark
file_out=$output_bn_data_path/raw_bnfea_${name_db}.1.ark

# set nnet filename
file_nnet=$input_data_path/nnet/feature_extractor.nnet

# run the forward net
nnet-forward --use-gpu=no $file_nnet ark:$file_in ark:$file_out


echo ============================================================================
echo "         Export features files (.npy format) and save PPG images          "
echo ============================================================================


# export features as ASCII
../../../src/featbin/copy-feats ark:"$file_out" ark,t:"${file_out%.ark}.ascii";

# store PGP image as PNG 
python plot_data_voctro.py "${file_out%.ark}.ascii" $output_bn_data_path/figs




