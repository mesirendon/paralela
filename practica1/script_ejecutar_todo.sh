#!/bin/bash

gcc blur-effect.c -o blur-effect -pthread

threads=1
kernel=3

echo '╔═══════════════════════════════╗'
echo '║     Processing 4k image       ║'
echo '╚═══════════════════════════════╝'
echo "K: Kernel, T: Thread, ms: Milisenconds"
echo -e "K\tT\tms"
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-4k.bmp outputs/landscape-4k.bmp $kernel $threads | tee -a logs/4k
  kernel=$(($kernel + 1))
done

threads=2
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-4k.bmp outputs/landscape-4k.bmp $kernel $threads | tee -a logs/4k
  kernel=$(($kernel + 1))
done

threads=4
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-4k.bmp outputs/landscape-4k.bmp $kernel $threads | tee -a logs/4k
  kernel=$(($kernel + 1))
done

threads=8
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-4k.bmp outputs/landscape-4k.bmp $kernel $threads | tee -a logs/4k
  kernel=$(($kernel + 1))
done

threads=16
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-4k.bmp outputs/landscape-4k.bmp $kernel $threads | tee -a logs/4k
  kernel=$(($kernel + 1))
done
