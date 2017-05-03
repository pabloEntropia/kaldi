
# VOCTRO RUN FORWARD PPG 

echo ============================================================================
echo "         Audio to Posterior PhonoGrams (PPG) computation           "
echo "         Voctro Labs. Barcelona. 2017.    						 "
echo "		  (scripts based on Kaldi project TIMIT recipes)       			 "
echo ============================================================================



# Config:

. ./cmd_local.sh ## Voctro command tools (without GPU)
. ./path.sh ## Source the tools/utils (import the queue.pl)



# INPUT DATA
input_data_path=/mnt/hd20GB/temp_ppg

#data_fmllr=data-fmllr-tri3-voctro # Voctro: this is an internal folder where fMLLR features are generated
data_fmllr=$input_data_path/data_fmllr
data_mfcc=$input_data_path/mfcc

#OUTPUT DATA
output_bn_data_path=/mnt/hd20GB/temp_out_ppg
mkdir -p $output_bn_data_path

# PARAMETERS
njobs=1 # we are running one job (only processing a single audio file)



echo ============================================================================
echo "         Prepare data           "
echo ============================================================================
# audio_input_format_data_voctro.sh $timit $test_name || exit 1


# TODO: write wav.scp for all files in a folder (e.g MAIKA scripts) and use ".sph" format.
# Check how they do it when processing the TIMIT dataset

# TODO: convert MS-WAV file format to SPHERE format using sox. Create a SPH folder
#sox '/mnt/hd20GB/audio/SI1559.wav' '/mnt/hd20GB/audio/SI1559.sph'

# TODO: compute a CVMN file from a given speaker using all files in a folder. (e.g. all MAIKA script recordings).





echo ============================================================================
echo "         MFCC Feature Extration & CMVN for single audio file          "
echo ============================================================================



# Now make MFCC features.
src_data_dir=$input_data_path 
mfcc_log_dir=$data_mfcc/log

feats_nj=$njobs

# "Usage: $0 [options] <data-dir> [<log-dir> [<mfcc-dir>] ]";
steps/make_mfcc_voctro.sh --cmd "$train_cmd" --nj $njobs $src_data_dir $mfcc_log_dir $data_mfcc
echo "MFCC done!"
steps/compute_cmvn_stats.sh $src_data_dir $mfcc_data_dir $mfccdir
echo "CVMN done!" 



#exit

echo ============================================================================
echo "         Run fMLLR features computation for single file          "
echo ============================================================================

# Trained model folder 
echo "TODO voctro: put the ggmdir/decode_test folder in a custom -models folder-"
gmmdir=exp/tri3 #  Trained model: GMM directory

dir=$data_fmllr
src_dir=$input_data_path


steps/nnet/make_fmllr_feats_voctro.sh --nj $njobs --cmd "$train_cmd" \
 --transform-dir $gmmdir/decode_test \
 $dir $src_dir $gmmdir $dir/log $dir/data 



echo ============================================================================
echo "         Run DNN Forward path to compute output PPG features          "
echo ============================================================================

# TESTING WITH ONE ARK FILE WITH FMLRR features
# We just call it using .ark files to understand the mechanism of in/out files:
# Output folder for bottle-neck (BN) features
file_in=$data_fmllr/data/feats_fmllr_voctro.1.ark
file_out=$output_bn_data_path/raw_bnfea_voctro.1.ark

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




