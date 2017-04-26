#!/bin/bash
#
# Converts Gregorian to Hijri Shamsi

print_usage()
{
   echo "This script converts Gregorian date to Jalali (Hijri Shamsi)."
   echo "Usage: $0 YYYYMMDD"
}

isleap()
{
   let remainder=gr_y%400
   if [[ $remainder -eq 0 ]]; then
      isleapyear=1
      return
   fi
   let remainder=gr_y%100
   if [[ $remainder -eq 0 ]]; then
      isleapyear=0
      return
   fi
   let remainder=gr_y%4
   if [[ $remainder -eq 0 ]]; then
      isleapyear=1
      return
   fi
   #else
   isleapyear=0
}

gr_month_days=(31 28 31 30 31 30 31 31 30 31 30 31)
sh_month_days=(31 31 31 31 31 31 30 30 30 30 30 29)

if [ -z $1 ]; then
   # IF no argument is passed, print error and exit
   echo "ERROR! Missing argument."
   print_usage
   exit 1
else
   arg=$1
   dateyyyymmdd=`date "+%Y%m%d" -d "$arg 01:00"` 
   gr_y=${dateyyyymmdd%????}
   gr_y=$(($gr_y-1600))
   gr_m=${dateyyyymmdd%??}
   gr_m=${gr_m#????}
   gr_m=$(($gr_m-1))
   gr_d=${dateyyyymmdd#??????}
   gr_d=$(($gr_d-1))
fi

let gr_days_passed=365*$gr_y
let gr_days_passed=$gr_days_passed+$((($gr_y+3)/4+($gr_y+399)/400-($gr_y+99)/100))

index=0
while [[ $index -lt $gr_m ]]; do
   let gr_days_passed=$gr_days_passed+${gr_month_days[$index]}
   let index=$index+1
done

isleap

if [[ ($isleapyear -eq 1) && ($gr_m -gt 1) ]]; then
   let gr_days_passed=$gr_days_passed+1
fi

let gr_days_passed=$gr_days_passed+$gr_d

let sh_days_passed=$gr_days_passed-79

let sh_np=$sh_days_passed/12053
let sh_days_passed=$sh_days_passed%12053
let tmp=$sh_days_passed/1461
let sh_year=979+33*$sh_np+4*$tmp
let sh_days_passed=$sh_days_passed%1461

if [[ $sh_days_passed -gt 366 ]]; then
   let sh_days_passed=$sh_days_passed-1
   let sh_year=$sh_year+$sh_days_passed/365
   let sh_days_passed=$sh_days_passed%365
fi

index=0
while [[ ($index -lt 11) && ($sh_days_passed -ge ${sh_month_days[$index]}) ]]
do
   let sh_days_passed=$sh_days_passed-${sh_month_days[$index]}
   let index=$index+1
done

let sh_month=$index+1
if [[ $sh_month -lt 10 ]]; then
   sh_month="0$sh_month"
fi

let sh_day=$sh_days_passed+1
if [[ $sh_day -lt 10 ]]; then
   sh_day="0$sh_day"
fi

echo "$sh_year$sh_month$sh_day"

