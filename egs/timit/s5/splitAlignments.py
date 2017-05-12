#!/bin/sh

#  splitAlignments.py
#  
#
#  Created by Eleanor Chodroff on 3/25/15.
#
#
#
import sys,csv
results=[]

#name = name of first text file in final_ali.txt
#name_fin = name of final text file in final_ali.txt

name = "TIMIT_parallel_a001"
name_fin = "1TIMIT_parallel_a006"
try:
    with open("exp/tri3_ali_falign/final_ali.txt") as f:
        next(f) #skip header
        for line in f:
            columns=line.split("\t")
            name_prev = name
            name = columns[1]
            if (name_prev != name):
                try:
                    with open(('exp/tri3_ali_falign/' + name_prev)+".txt",'w') as fwrite:
                        writer = csv.writer(fwrite)
                        fwrite.write("\n".join(results))
                        fwrite.close()
                #print name
                except Exception, e:
                    print "Failed to write file",e
                    sys.exit(2)
                del results[:]
                results.append(line[0:-1])
            else:
                results.append(line[0:-1])
except Exception, e:
    print "Failed to read file",e
    sys.exit(1)
# this prints out the last textfile (nothing following it to compare with)
try:
    with open(('exp/tri3_ali_falign/' + name_prev)+".txt",'w') as fwrite:
        writer = csv.writer(fwrite)
        fwrite.write("\n".join(results))
        fwrite.close()
                #print name
except Exception, e:
    print "Failed to write file",e
    sys.exit(2)