
import sys,re,glob,os

def natural_keys(text):
    '''
    alist.sort(key=natural_keys) sorts in human order
    http://nedbatchelder.com/blog/200712/human_sorting.html
    (See Toothy's implementation in the comments)
    '''
    return [ atoi(c) for c in re.split('(\d+)', text) ]

def atoi(text):
    return int(text) if text.isdigit() else text

def find_files(directory, pattern):
    for root, dirs, files in os.walk(directory):
        for basename in files:
            if basename.lower().endswith(pattern):
                filename = os.path.join(root, basename)
                yield filename


def get_files(dir, pattern='.lab'):
    find_files(dir, pattern)
    files = [f for f in find_files(dir, pattern)]
    files.sort(key=natural_keys) # Does it matter?

    print 'Found', len(files), 'audio files (' + pattern + ')'
    return files

data_dir = sys.argv[1]

name_db = sys.argv[2]

genre = sys.argv[3]

files = get_files(data_dir)

with open(data_dir + '/'+ 'text', 'w') as f:
    for file in files:
        lab = open(file)
        lines = lab.readlines()
        lab.close()
        name = file.split("/")[-1].split(".lab")[0]
        f.write(name_db + "_" + name + ' ')
        for line in lines:
            phone = line.split(" ")[-1]

            f.write(phone.rstrip() + ' ')
        if file is not files[-1]:
            f.write('\n')
f.close()

stm = ";; LABEL \"O\" \"Overall\" \"Overall\"\n;; LABEL \"F\" \"Female\" \"Female speakers\"\n;; LABEL \"M\" \"Male\" \"Male speakers\"\n"


with open(data_dir + '/'+ 'stm', 'w') as f:
    f.write(stm)
    for file in files:
        lab = open(file)
        lines = lab.readlines()
        lab.close()
        name = file.split("/")[-1].split(".lab")[0]
        time = float(lines[-1].split(" ")[-2])/1e7
        f.write(name_db + "_" + name + ' ')
        f.write('1 ')
        f.write(name_db + ' ')
        f.write('0.0 ')
        f.write('%.3f ' %time)
        f.write('<O,%s> ' %genre)
        for line in lines:
            phone = line.split(" ")[-1]
            f.write(phone.rstrip())
            if line is not lines[-1]:
                f.write(' ')
        if file is not files[-1]:
            f.write('\n')
f.close()
