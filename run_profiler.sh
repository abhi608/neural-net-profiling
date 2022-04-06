#!/bin/bash

COMMAND="python3 main.py /imagenet --arch resnet18 --epochs 1 --batch-size 10 --print-freq 10 --seed 42"
MODEL=$1
METRICS="dram__bytes_write.sum,dram__bytes_read.sum,smsp__sass_thread_inst_executed_op_fadd_pred_on.sum,smsp__sass_thread_inst_executed_op_fmul_pred_on.sum,smsp__sass_thread_inst_executed_op_ffma_pred_on.sum"

# ncu files
NCU_RUNTIME_LOG="$MODEL-ncu-runtime.log"
NCU_METRIC_LOG="$MODEL-ncu-metric.log"
rm -rf NCU_TMP_LOG NCU_METRIC_LOG

# nsys file
NSYS_RUNTIME_LOG="$MODEL-nsys-runtime.qdrep"
NSYS_METRIC_LOG="$MODEL-nsys-metric.log"
rm -rf NSYS_RUNTIME_LOG NSYS_METRIC_LOG

# run ncu
ncu -f --log-file $NCU_RUNTIME_LOG --metrics $METRICS --target-processes all $COMMAND
# compute bytes 
echo "BYTES" >> $NCU_METRIC_LOG
cat $NCU_RUNTIME_LOG | grep -e "dram__bytes_write.sum" -e "dram__bytes_read.sum" | awk '{print($3)}' | paste -sd+ | bc >> $NCU_METRIC_LOG
#compute FLOPS
TMP1=`cat $NCU_RUNTIME_LOG | grep -e "smsp__sass_thread_inst_executed_op_fadd_pred_on.sum" -e  "smsp__sass_thread_inst_executed_op_fmul_pred_on.sum" | awk '{print $3}' | paste -sd+ | bc`
TMP2=`cat $NCU_RUNTIME_LOG | grep -e "smsp__sass_thread_inst_executed_op_ffma_pred_on.sum" | awk '{print $3}' | paste -sd+ | bc`
FLOPS=$((TMP1 + 2*TMP2))
echo "FLOPS" >> $NCU_METRIC_LOG
echo $FLOPS >> $NCU_METRIC_LOG