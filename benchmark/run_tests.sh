#!/bin/bash
WVTOOL=../../VA-BSIM3v3/util/getwvres.py
FILES="comprt gstage oneshot opamp qatest ro_17 test1 test10 test11 test12 test13 test14 test2 test3 test4 test5 test6 test7 test8 test9"
doSim=$1
checkTr0=$2
resFile=results-`date +%Y%m%d%H%M`.log
rm -rf $resFile
if [ -z $doSim ]; then
  echo "Ignore simulation ..."
elif [ $doSim == "1" ]; then
  for file in $FILES; do
      echo Running netlist $file.b4 ...
      hspice -i $file.b4 -o out/hsp_$file
      cd va
      hspice -i $file.b4 -o out/hspva_$file
      cd ..
  done
  echo finished simulation ...
fi

## Check DC
FILESDC=(qatest test1 test10 test11 test12 test13 test14 test2 test3 test4 test5 test6 test7 test8 test9 test10_geo_flip_n1  test10_geo_flip_p1  test10_geo_std_n1  test10_geo_std_p1)
FILESDCN=(12 61 61 91 91 91 91 61 61 61 91 31 91 61 61 25 25 25 25)

for ((i=0; i<${#FILESDCN[@]}; i++)); do
    echo Comparing netlist for DC ${FILESDC[$i]}.b4 C vs. VA...
    echo "python getwvres.py out/hsp_${FILESDC[$i]}.sw0 va/out/hspva_${FILESDC[$i]}.sw0 ${FILESDCN[$i]}" >> $resFile
    python $WVTOOL dc out/hsp_${FILESDC[$i]}.sw0 va/out/hspva_${FILESDC[$i]}.sw0 ${FILESDCN[$i]} >> $resFile 2>&1 
done

## Check AC
FILESAC=(gstage opamp)
for ((i=0; i<${#FILESAC[@]}; i++)); do
    echo Comparing netlist for AC ${FILESAC[$i]}.b4 C vs. VA...
    echo "python getwvres.py out/hsp_${FILESAC[$i]}.ac0 va/out/hspva_${FILESAC[$i]}.ac0 " >> $resFile
    python $WVTOOL ac out/hsp_${FILESAC[$i]}.ac0 va/out/hspva_${FILESAC[$i]}.ac0  >> $resFile 2>&1 
done

## Check Tran
FILESTR=(comprt oneshot ro_17)
for ((i=0; i<${#FILESTR[@]}; i++)); do
    echo Comparing netlist for Tran ${FILESTR[$i]}.b4 C vs. VA...
    echo "python getwvres.py out/hsp_${FILESTR[$i]}.mt0 va/out/hspva_${FILESTR[$i]}.mt0 " >> $resFile
    python $WVTOOL tran out/hsp_${FILESTR[$i]}.mt0 va/out/hspva_${FILESTR[$i]}.mt0  >> $resFile 2>&1 
done

## extra test for processing tr0 file with same way as AC/DC
extrsp='comprt'
if [ "$checkTr0" == "1" ]; then
  echo "python getwvres.py out/hsp_$extrsp.tr0 va/out/hspva_$extrsp.tr0 " >> $resFile
  python $WVTOOL ac out/hsp_$extrsp.tr0 va/out/hspva_$extrsp.tr0  >> $resFile 2>&1 
fi
