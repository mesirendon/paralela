#!/bin/bash


echo '╔═══════════════════════════════╗'
echo '║ Processing 4k image           ║'
echo '╚═══════════════════════════════╝'
echo "K: Kernel, ms: Milisenconds"
echo -e "K\ts"
echo '═════════════════════════════════'

echo -e "K\ts" > logs/4k.csv

kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-4k.bmp outputs/landscape-4k-kernel-$kernel.bmp $kernel | tee -a logs/4k.csv
  kernel=$(($kernel + 1))
done

echo '╔═══════════════════════════════╗'
echo '║ Processing 1080p image        ║'
echo '╚═══════════════════════════════╝'
echo "K: Kernel, ms: Milisenconds"
echo -e "K\ts"
echo '═════════════════════════════════'

echo -e "K\ts" > logs/1080.csv

kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-1080.bmp outputs/landscape-1080-kernel-$kernel.bmp $kernel | tee -a logs/1080.csv
  kernel=$(($kernel + 1))
done

echo '╔═══════════════════════════════╗'
echo '║ Processing 720p image         ║'
echo '╚═══════════════════════════════╝'
echo "K: Kernel, ms: Milisenconds"
echo -e "K\ts"
echo '═════════════════════════════════'

echo -e "K\ts" > logs/720.csv

kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-720.bmp outputs/landscape-720-kernel-$kernel.bmp $kernel | tee -a logs/720.csv
  kernel=$(($kernel + 1))
done
