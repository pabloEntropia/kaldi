#!/bin/bash
if [ $# != 2 ]; then

system=$1

for i in xevi Randy_p003 locked train ultimo MWVW0 MPDF0 MGWT0 FCMR0; do
    echo $i
    sh get_world_ppgs.sh $system $i
done

fi