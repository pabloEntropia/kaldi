#  phons2words.py
#
#
#  Created by Eleanor Chodroff on 2/07/16.

import sys,re,glob

pron_ali=open("pron_alignment.txt",'w')
pron=[]

files = glob.glob('[1-9]*.txt')

# process each file
for filei in files:
    print filei
    f = open(filei, 'r')
    header = True
    pron_ali.write('\n')
    for line in f:
    	if header:
    		header = False
    		continue
        line=line.split("\t")
        file=line[1]
        file = file.strip()
        phon_pos=line[6]
        #print phon_pos
        if phon_pos == "SIL":
            phon_pos = "SIL_S"
        phon_pos=phon_pos.split("_")
        phon=phon_pos[0]
        pos=phon_pos[1]
        #print pos
        if pos == "B":
            start=line[9]
            pron.append(phon)
        if pos == "S":
            start=line[9]
            end=line[10]
            pron.append(phon)
            pron_ali.write(file + '\t' + ' '.join(pron) +'\t'+ str(start) + '\t' + str(end))
            pron=[]
        if pos == "E":
            end=line[10]
            pron.append(phon)
            pron_ali.write(file + '\t' + ' '.join(pron) +'\t'+ str(start) + '\t' + str(end))
            pron=[]
        if pos == "I":
            pron.append(phon)
