. ./cmd_local.sh ## Voctro command tools (without GPU)
. ./path.sh ## Source the tools/utils (import the queue.pl)


# Extracted from the tutorial:  http://pages.jh.edu/~echodro1/tutorial/kaldi/kaldi-forcedalignment.html

# mfccdir=mfcc-ali
# for x in data/faligns; do
# echo $x
# steps/make_mfcc.sh --cmd "$train_cmd" --nj 1 $x exp/make_mfcc/$x $mfccdir
# utils/fix_data_dir.sh data/faligns
# steps/compute_cmvn_stats.sh $x exp/make_mfcc/$x $mfccdir
# utils/fix_data_dir.sh data/faligns
# done

dir=exp/tri3_ali_falign/

steps/align_si.sh --cmd "$train_cmd" --nj 1 data/faligns data/lang exp/tri3 exp/tri3_ali_falign || exit 1;

for i in exp/tri3_ali_falign/ali.*.gz;
do ali-to-phones --ctm-output exp/tri3/final.mdl ark:"gunzip -c $i|" -> ${i%.gz}.ctm;
done;

cat exp/tri3_ali_falign/*.ctm > exp/tri3_ali_falign/merged_alignment.txt

Rscript id2phone.R

python splitAlignments.py
