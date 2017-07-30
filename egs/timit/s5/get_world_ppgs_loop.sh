#!/bin/bash
if [ $# != 2 ]; then

system=$1

for i in xevi Randy_p003 locked a_train ultimo MWVW0 MPDF0 MGWT0 FCMR0 MALE_POP10 redbone ultimo-verse ultimo-chorus female_low; do
    echo $i
    sh get_world_ppgs.sh $system $i
done

fi
