#!/bin/bash
export PATH=$PATH:/share/apps/cuda/11.1.74/bin
sh ~/neural-net-profiling/run_profiler.sh resnet18
sh ~/neural-net-profiling/run_profiler.sh resnet34
sh ~/neural-net-profiling/run_profiler.sh resnet50
