# Created by Pablo Alonso 09/05/2017

# This scripts reads a wav.scp file to obain the mfcc of the sp of all the WAV files in.
# The data is outut as a Kaldi style .txt

import sys
import numpy as np
import os
import pyworld as pw
import soundfile as sf
import pysptk as sptk

data_dir = sys.argv[1]
mfcc_dir = sys.argv[2]
set_name = sys.argv[3]
jobs = int(sys.argv[4])


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

        x, fs = sf.read(filename, dtype='float64')

        pyDioOpt = pw.pyDioOption(
            allowed_range=0.1,
            channels_in_octave=2.0,
            f0_ceil=900,
            f0_floor=60,
            frame_period=10.0,
            speed=1.0)

        _f0, t = pw.dio(x, fs, pyDioOpt)
        f0 = pw.stonemask(x, _f0, t, fs)
        sp = pw.cheaptrick(x, f0, t, fs)

        mcep_input = 4  # 0 for dB, 3 for magnitude
        alpha = 0.42
        en_floor = 10 ** (-80 / 20)
        order = 13
        mfcc = np.apply_along_axis(sptk.mcep, 1, sp, order-1, alpha,
                                   itype=mcep_input,
                                   threshold=en_floor,
                                   etype=0)

        file.write(kID + '  [\n')
        for i in range(len(mfcc) -1):
            file.write(' '.join(map(str, mfcc[i, :])) + ' \n')

        file.write(' '.join(map(str, mfcc[-1, :])) + ' ]\n')
    file.close()

    jobLines = lines[jobIt: jobIt + uttsPerJob]
    jobIt += uttsPerJob
