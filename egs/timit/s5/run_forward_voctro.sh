# run_forward_voctro.sh
# script to generate the posteriors of the trained DNN (Karel's)


# we follow KArel's instructions as written in this post: https://groups.google.com/forum/#!msg/kaldi-help/uJ7J8CzpjhM/V2rLwMIrCAAJ
#Hi, if you want to obtain posteriors from NN trained by nnet1 tools, the easiest is to use 'egs/wsj/s5/steps/nnet/make_bn_feats.sh', with option '--remove-last-components 0'.  The output is in feature matrix binary format. Eventually the binary output can be converted to ASCII by: 'copy-feats scp:file.scp ark,t:ascii.ark'


timit=/mnt/hd20GB/Ubuntu16_shared/TIMIT # @JJ VOCTRO Linux

# set path for data directories
tgt_data_dir=/mnt/hd20GB/XSource/VoctroLabs/voctroconversion/3rdparty/kaldi/egs/timit/s5/data-fmllr-tri3/test_bn2
src_data_dir=/mnt/hd20GB/XSource/VoctroLabs/voctroconversion/3rdparty/kaldi/egs/timit/s5/data-fmllr-tri3/test
nnet_dir=exp/dnn4_pretrain-dbn_dnn # Karel's DNN (best WER)
log_dir=/mnt/hd20GB/XSource/VoctroLabs/voctroconversion/3rdparty/kaldi/egs/timit/s5/data-fmllr-tri3/test_bn2_log
abs_path_to_bn_feat_dir=/mnt/hd20GB/bn_features2


# run script
steps/nnet/make_bn_feats.sh  --remove-last-components 0 --use-gpu no $tgt_data_dir $src_data_dir $nnet_dir $log_dir $abs_path_to_bn_feat_dir



# convert to ASCII
#../../src/featbin/copy-feats scp:file.scp ark,t:ascii.ark

for f in $abs_path_to_bn_feat_dir/*.scp
do
# convert features to ascii format
../../../src/featbin/copy-feats scp:"$f" ark,t:"${file%.scp}.ascii";
# store PGP image as PNG 
python plot_data_voctro.py "${file%.scp}.ascii" $abs_path_to_bn_feat_dir/figs
done;
 
