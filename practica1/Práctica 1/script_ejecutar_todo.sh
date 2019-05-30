#!/bin/bash

gcc blur-effect.c -o blur-effect -pthread

echo '╔═══════════════════════════════╗'
echo '║ Processing 4k image           ║'
echo '╚═══════════════════════════════╝'
echo "K: Kernel, T: Thread, ms: Milisenconds"
echo -e "K\tT\ts"
echo '═════════════════════════════════'

echo -e "K\tT\ts" > logs/4k.csv

threads=1
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-4k.bmp outputs/landscape-4k.bmp $kernel $threads | tee -a logs/4k.csv
  kernel=$(($kernel + 1))
done

threads=2
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-4k.bmp outputs/landscape-4k.bmp $kernel $threads | tee -a logs/4k.csv
  kernel=$(($kernel + 1))
done

threads=4
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-4k.bmp outputs/landscape-4k.bmp $kernel $threads | tee -a logs/4k.csv
  kernel=$(($kernel + 1))
done

threads=8
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-4k.bmp outputs/landscape-4k.bmp $kernel $threads | tee -a logs/4k.csv
  kernel=$(($kernel + 1))
done

threads=16
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-4k.bmp outputs/landscape-4k.bmp $kernel $threads | tee -a logs/4k.csv
  kernel=$(($kernel + 1))
done

echo '╔═══════════════════════════════╗'
echo '║ Processing 1080p image        ║'
echo '╚═══════════════════════════════╝'
echo "K: Kernel, T: Thread, ms: Milisenconds"
echo -e "K\tT\ts"
echo '═════════════════════════════════'

echo -e "K\tT\ts" > logs/1080.csv

threads=1
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-1080.bmp outputs/landscape-1080.bmp $kernel $threads | tee -a logs/1080.csv
  kernel=$(($kernel + 1))
done

threads=2
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-1080.bmp outputs/landscape-1080.bmp $kernel $threads | tee -a logs/1080.csv
  kernel=$(($kernel + 1))
done

threads=4
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-1080.bmp outputs/landscape-1080.bmp $kernel $threads | tee -a logs/1080.csv
  kernel=$(($kernel + 1))
done

threads=8
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-1080.bmp outputs/landscape-1080.bmp $kernel $threads | tee -a logs/1080.csv
  kernel=$(($kernel + 1))
done

threads=16
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-1080.bmp outputs/landscape-1080.bmp $kernel $threads | tee -a logs/1080.csv
  kernel=$(($kernel + 1))
done

echo '╔═══════════════════════════════╗'
echo '║ Processing 720p image         ║'
echo '╚═══════════════════════════════╝'
echo "K: Kernel, T: Thread, ms: Milisenconds"
echo -e "K\tT\ts"
echo '═════════════════════════════════'

echo -e "K\tT\ts" > logs/720.csv

threads=1
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-720.bmp outputs/landscape-720.bmp $kernel $threads | tee -a logs/720.csv
  kernel=$(($kernel + 1))
done

threads=2
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-720.bmp outputs/landscape-720.bmp $kernel $threads | tee -a logs/720.csv
  kernel=$(($kernel + 1))
done

threads=4
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-720.bmp outputs/landscape-720.bmp $kernel $threads | tee -a logs/720.csv
  kernel=$(($kernel + 1))
done

threads=8
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-720.bmp outputs/landscape-720.bmp $kernel $threads | tee -a logs/720.csv
  kernel=$(($kernel + 1))
done

threads=16
kernel=3
while [ $kernel -le 15 ]
do
  ./blur-effect images/landscape-720.bmp outputs/landscape-720.bmp $kernel $threads | tee -a logs/720.csv
  kernel=$(($kernel + 1))
done
