mfccdir=mfccTest
for i in $mfccdir/raw_mfcc_train.*.txt; do
    echo $i
  ../../../src/featbin/copy-feats t,ark:$i ark,scp:"${i%.txt}.ark","${i%.txt}.scp"
done
