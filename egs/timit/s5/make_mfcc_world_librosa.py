# Created by Pablo Alonso 09/05/2017

# This scripts reads a wav.scp file to obain the mfcc of the sp of all the WAV files in.
# The data is outut as a Kaldi style .txt

import sys
import os
import numpy as np
import pyworld as pw
import soundfile as sf
from librosa.filters import mel
from librosa.filters import dct
from matplotlib import pyplot as plt


def dither (x, d):
    samples = np.random.randn(len(x))
    samples = samples/ np.std(samples)
    x = x + d *samples
    return x

def preemph(x, alpha):
    y = x[1:] - alpha * x[:-1]
    return y

def lifter(x, L=22):
    n = np.arange(len(x)-1) +1
    x[1:] *=  1 + (L / 2.0) * np.sin(np.pi * n  / float(L))
    return x

eps = np.finfo(float).eps


data_dir = sys.argv[1]
mfcc_dir = sys.argv[2]
set_name = sys.argv[3]
jobs = int(sys.argv[4])

do_ext_f0 = False
if len(sys.argv) == 6:
    do_ext_f0 = float(sys.argv[5])


scp = open(data_dir + '/wav.scp')
lines = scp.readlines()
scp.close

print '%i files found.' %len(lines)

if not os.path.exists(mfcc_dir):
    os.mkdir(mfcc_dir)

uttsPerJob = len(lines) / jobs
jobIt = uttsPerJob + len(lines) % jobs

jobLines = lines[:jobIt]

for job in range(jobs):
    name = mfcc_dir + '/raw_mfcc_' + set_name + '.' + str(job+1) +'.txt'
    file = open(name,'w')

    count = 0
    for line in jobLines:
        print 'Processing %i out of %i for the job %i'  %(count, len(lines), job)
        print 'This job ends in the file n: %i' %jobIt
        count += 1
        parse = line.split(" ")
        kID = parse[0]
        filename = parse[4]

        x, fs = sf.read(filename, dtype='int32')

        x = dither(x, 1.0)

        #  2. preemph
        x  = preemph(x, .97)

        f0, t = pw.dio(x, fs, 60.0, 800.0, 2.0, 10.0)
        #f0 = pw.stonemask(x, _f0, t, fs)


        # todo: import f0
        f0file = filename.split(".WAV")[0] + '.f0'
        if os.path.exists(f0file):
            print "Importing f0 from %s" %f0file
            a = open(f0file)
            text = a.read().rstrip()
            a.close()
            ext_f0 = np.frombuffer(text, dtype=np.float32, count=-1, offset=0)

            ext_f0 = np.array(ext_f0[0:len(f0)*2:2], dtype=float)
            f0 = ext_f0
#            print ext_f0.shape
#            print f0.shape
#            plt.plot(ext_f0, label='external f0')
#            plt.plot(f0, label='World f0')
#            plt.legend()
#            plt.show()
        else:
            print "Not .f0 file found. Using World DIO."

        # 3. world SP
        sp = pw.cheaptrick(x, f0, t, fs) **.5

        sp  /=  2**15

        # 4. Librosa MelBands
        mel_basis = mel(fs, 1024, 23, 20, fs/2, True, None) 
        MelBands = np.dot(mel_basis, sp.T).T**2
 
        #  MelBands = np.apply_along_axis(MelBands_algo, 1, sp.astype(np.float32))

        # 5. Log
        logMelBands = np.log(MelBands)

        # 6. Essentia DCT(log())
        dct_basis = dct(13,23)

        DCT = np.dot(dct_basis, logMelBands.T).T
        mfcc = np.apply_along_axis(lifter, 1, DCT)

        file.write(kID + '  [\n')
        for i in range(len(mfcc) -1):
            file.write(' '.join(map(str, mfcc[i, :])) + ' \n')

        file.write(' '.join(map(str, mfcc[-1, :])) + ' ]\n')
    file.close()

    jobLines = lines[jobIt: jobIt + uttsPerJob]
    jobIt += uttsPerJob
