
import os
import sys
import re

def find_files(directory, pattern):
    for root, dirs, files in os.walk(directory):
        for basename in files:
            if basename.lower().endswith(pattern):
                filename = os.path.join(root, basename)
                yield filename



def atoi(text):
    return int(text) if text.isdigit() else text

def natural_keys(text):
    '''
    alist.sort(key=natural_keys) sorts in human order
    http://nedbatchelder.com/blog/200712/human_sorting.html
    (See Toothy's implementation in the comments)
    '''
    return [ atoi(c) for c in re.split('(\d+)', text) ]

input_audio_dir = sys.argv[1]
data_dir = sys.argv[2]
name_db = sys.argv[3]


find_files(input_audio_dir, '.wav')
files = [f for f in find_files(input_audio_dir, '.wav')]
print 'Found', len(files), 'audio files (.wav) '

files.sort(key=natural_keys)

spk2utt = str(name_db + ' ')
utt2spk = str('')

for myfile in files:
    spk2utt += name_db + '_' + myfile.split('/')[-1].split('.')[0] + ' '
    utt2spk += name_db + '_' + myfile.split('/')[-1].split('.')[0] + ' ' + name_db + '\n'
spk2utt += '\n'

with open(data_dir+'/spk2utt', 'w') as f:
    f.write(spk2utt)
f.close()
with open(data_dir+'/utt2spk', 'w') as f:
    f.write(utt2spk)
f.close()

print 'spk2utt and utt2spk created.'