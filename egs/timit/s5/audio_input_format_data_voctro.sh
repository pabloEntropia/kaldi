# Audio input format data (adapted from TIMIT input)
#
# Script used to load the WAV audio files into the correct way for the MFCC testing process.


# functions in local/timit_data_prep.sh script
#local/timit_data_prep.sh $timit || exit 1


if [ $# -ne 3 ]; then
   echo "Arguments are: <input_audop_folder> <test_name> <data_ouput_folder>"
   echo "e.g. /mnt/my_HD/MALE_POP_DB mpop1 /mnt/my_test/data"
   exit 1;
fi


echo =================================================================
echo "Functions originally in local/timit_data_prep"
echo =================================================================

input_folder=$1
echo "input folder is: "$input_folder
test_name=$2 
echo "test name is: "$test_name
data_folder=$3 
echo "data folder is: "$data_folder

dir=`pwd`/data/local/data
lmdir=`pwd`/data/local/nist_lm
mkdir -p $dir $lmdir
local=`pwd`/local
utils=`pwd`/utils
conf=`pwd`/conf



. ./path.sh # Needed for KALDI_ROOT
export PATH=$PATH:$KALDI_ROOT/tools/irstlm/bin
sph2pipe=$KALDI_ROOT/tools/sph2pipe_v2.5/sph2pipe
if [ ! -x $sph2pipe ]; then
   echo "Could not find (or execute) the sph2pipe program at $sph2pipe";
   exit 1;
fi


tmpdir=$(mktemp -d /tmp/kaldi.XXXX);
trap 'rm -rf "$tmpdir"' EXIT


echo ============================================================================
echo "                       Create $test_name _spk.list file                    "
echo ============================================================================

python create_spk_list.py $input_folder $test_name


# Create spk2utt and utt2spk files for a single speaker
#echo "TODO: creat eutt2spk and spk2utt files using a python scripts"
# 
# python create_spk2utt_files.py "$wav_folder" $data_folder/utt2spk $data_folder/spk2utt
echo ============================================================================
echo "                      Create utt2spk and spk2utt files                    "
echo ============================================================================

python create_utt_spk_files.py $input_folder/wav $data_folder $test_name


cd $dir

# echo $input_folder 


echo =================================================================
echo "Convert MS-WAV format to SPHERE format using SOX"
echo =================================================================

# It converts MS-WAV file format (16bit 44kHz) to SPHERE format using sox. Create a SPH folder

wav_folder=$input_folder/wav
sph_folder=$input_folder/${test_name}
# create folder for SPHERE format files if needed
if [ ! -d $sph_folder ]; then mkdir $sph_folder; fi
 
cd $wav_folder
for i in *.wav ; do  sox $i -r 16k $sph_folder/${i%.wav}.sph ; done
cd $sph_folder
for i in *.sph ; do  mv $i ${i%.sph}.WAV ; done

# copy speaker list file to temp folder (test name)
if [ ! -f $input_folder/${test_name}_spk.list ]; then echo "Speaker list file does not exists. (look egs/timit/conf files as an example)"; fi

tr '[:upper:]' '[:lower:]' < $input_folder/${test_name}_spk.list > $tmpdir/${test_name}_spk






echo =================================================================
echo " Copy files to internal data folder for test set"
# (Functions originally in local/timit_data_prep)"
echo =================================================================


for x in $test_name; do
  # First, find the list of audio files .
  # Note: train & test sets are under different directories, but doing find on 
  # both and grepping for the speakers will work correctly.
  echo ${x}
  find $sph_folder -iname '*.WAV' \
    | grep -f $tmpdir/${x}_spk > ${x}_sph.flist

  sed -e 's:.*/\(.*\)/\(.*\).WAV$:\1_\2:i' ${x}_sph.flist \
    > $tmpdir/${x}_sph.uttids
  paste $tmpdir/${x}_sph.uttids ${x}_sph.flist \
    | sort -k1,1 > ${x}_sph.scp

  cat ${x}_sph.scp | awk '{print $1}' > ${x}.uttids


  # Do normalization steps. TODO: jjaner. Check if this stepo is necessary
#  cat ${x}.trans | $local/timit_norm_trans.pl -i - -m $conf/phones.60-48-39.map -to 48 | sort > $x.text || exit 1;

  # Create wav.scp
  awk '{printf("%s '$sph2pipe' -f wav %s |\n", $1, $2);}' < ${x}_sph.scp > ${x}_wav.scp



  # functions in local/timit_format_data.sh script
  #srcdir=data/local/data
  #cp $srcdir/${x}_wav.scp data/$x/wav.scp || exit 1;
  # create folder for data files if needed
  if [ ! -d $data_folder ]; then mkdir $data_folder; fi
  #if [ ! -d $data_folder/$x ]; then mkdir $data_folder/$x; fi
  cp ${x}_wav.scp $data_folder/wav.scp || exit 1;





done

echo "Data preparation succeeded"







