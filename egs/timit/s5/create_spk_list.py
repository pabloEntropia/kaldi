import re
import sys
import os
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
name_db = sys.argv[2]

find_files(input_audio_dir, '.wav')
files = [f for f in find_files(input_audio_dir, '.wav')]
files.sort(key=natural_keys)
print 'Created ' + input_audio_dir + '/' +  name_db + '_spk.list'


with open(input_audio_dir + '/'+ name_db + '_spk.list','w') as f:
	for file in files:
		f.write(file.split('.')[0].split('/')[-1]+'\n')
f.close()
