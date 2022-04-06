#!/bin/bash
if [ -z $1 ]
then
	echo "Must input model arch"
	exit 1
fi
MODEL=$1

COMMAND="python3 imagenet/main.py /imagenet --arch $MODEL --epochs 1 --batch-size 10 --print-freq 10"
METRICS="dram__bytes_write.sum,dram__bytes_read.sum,smsp__sass_thread_inst_executed_op_fadd_pred_on.sum,smsp__sass_thread_inst_executed_op_fmul_pred_on.sum,smsp__sass_thread_inst_executed_op_ffma_pred_on.sum"

# ncu files
rm -rf $MODEL
mkdir $MODEL
NCU_RUNTIME_LOG="$MODEL/$MODEL-ncu-runtime.log"
NCU_METRIC_LOG="$MODEL/$MODEL-ncu-metric.log"
rm -rf NCU_TMP_LOG NCU_METRIC_LOG

# nsys file
NSYS_RUNTIME_LOG="$MODEL/$MODEL-nsys-runtime.qdrep"
NSYS_METRIC_LOG="$MODEL/$MODEL-nsys-metric.log"
rm -rf NSYS_RUNTIME_LOG NSYS_METRIC_LOG

echo "*******************************************************"
echo "Starting ncu profiling"
# run ncu
ncu -f --log-file $NCU_RUNTIME_LOG --metrics $METRICS --target-processes all $COMMAND
# compute bytes 
BYTE=`cat $NCU_RUNTIME_LOG | grep -e "dram__bytes_write.sum" -e "dram__bytes_read.sum" | sed -e "s/,/ /g" | grep -e " byte" | awk '{print($3)}' | paste -sd+ | bc`
KBYTE=`cat $NCU_RUNTIME_LOG | grep -e "dram__bytes_write.sum" -e "dram__bytes_read.sum" | sed -e "s/,/ /g" | grep -e "Kbyte" | awk '{print($3)}' | paste -sd+ | bc`
MBYTE=`cat $NCU_RUNTIME_LOG | grep -e "dram__bytes_write.sum" -e "dram__bytes_read.sum" | sed -e "s/,/ /g" | grep -e "Mbyte" | awk '{print($3)}' | paste -sd+ | bc`
GBYTE=`cat $NCU_RUNTIME_LOG | grep -e "dram__bytes_write.sum" -e "dram__bytes_read.sum" | sed -e "s/,/ /g" | grep -e "Gbyte" | awk '{print($3)}' | paste -sd+ | bc`
TOTAL_BYTES=`awk "BEGIN{ print $BYTE + 1000*$KBYTE + 1000000*$MBYTE + 1000000000*$GBYTE }"`
echo "BYTES" >> $NCU_METRIC_LOG
echo $TOTAL_BYTES >> $NCU_METRIC_LOG
#compute FLOPS
TMP1=`cat $NCU_RUNTIME_LOG | grep -e "smsp__sass_thread_inst_executed_op_fadd_pred_on.sum" -e  "smsp__sass_thread_inst_executed_op_fmul_pred_on.sum" | sed -e "s/,/ /g" | awk '{print $3}' | paste -sd+ | bc`
TMP2=`cat $NCU_RUNTIME_LOG | grep -e "smsp__sass_thread_inst_executed_op_ffma_pred_on.sum" | sed -e "s/,/ /g" | awk '{print $3}' | paste -sd+ | bc`
FLOPS=$((TMP1 + 2*TMP2))
echo "FLOPS" >> $NCU_METRIC_LOG
echo $FLOPS >> $NCU_METRIC_LOG
echo "Completed ncu profiling"
echo "*******************************************************"


echo "*******************************************************"
echo "Starting nsys profiling"
# run nsys
nsys profile -f true -o $NSYS_RUNTIME_LOG $COMMAND
rm -rf $MODEL/tmp_nsys_gputrace.csv
nsys stats --report gputrace $NSYS_RUNTIME_LOG -o $MODEL/tmp_nsys
# compute runtime
echo "Runtime(nsec)" >> $NSYS_METRIC_LOG
tail -n +2 $MODEL/tmp_nsys_gputrace.csv | sed -e "s/,/ /g" | awk '{print $2}' | paste -sd+ | bc >> $NSYS_METRIC_LOG
echo "Completed nsys profiling"
echo "*******************************************************"
