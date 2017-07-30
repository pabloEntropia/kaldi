
# visualize PGP from file
# exported ASCII files with PGP contain multiple files, separated by one line containing [filename]

import sys
import numpy as np
import matplotlib.pylab as plt
import os

fn_features = sys.argv[1]


# load ASCII file
fpgp = open(fn_features)
ll = fpgp.readlines()
fpgp.close

figs_folder = sys.argv[2] + '/plots'
if not os.path.exists(figs_folder):
    os.mkdir(figs_folder)

data_folder = sys.argv[2] + '/data'
if not os.path.exists(data_folder):
    os.mkdir(data_folder)

# convert ASCII data to numpy format matrix for one file. (skip first row)
pgp_files = [];
frames = np.array([])
for l in ll:
    # check new files
    if l.find(" [")>0:
        new_file = {'fname': l.split()[0], 'PGP': 0}
        pgp_files.append(new_file)
        frames = np.array([])
        print 'Saving PGP data for file:' + new_file['fname']
        continue
    # accumulate new lines as new feature frames
    l2 = l.replace("]","")
    vals = np.array(l2.split()).astype(float)
    if frames.size == 0:
        frames = vals
    else:
        frames = np.vstack((frames, vals) )
    # check end of file and store results
    if l.find("]") > 0:

        # save numpy
        pgp_files[-1]['PGP'] = frames
        fname = os.path.join(data_folder, pgp_files[-1]["fname"]+'.npy')
        np.save(fname,frames)
        # save plot
#        plt.matshow(frames.T)
#        plt.title('PGP per frame / ' + pgp_files[-1]["fname"])
#        fname = os.path.join(figs_folder, pgp_files[-1]["fname"]+'.png')
#        plt.colorbar()
#        plt.savefig(fname)
#        plt.close()
