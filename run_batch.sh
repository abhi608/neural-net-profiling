#!/bin/bash
#SBATCH --job-name=av2783-imagenet_profiling
#SBATCH --mail-type=END
#SBATCH --mail-user=av2783@nyu.edu
#SBATCH --output=slurm_%j.out
#SBATCH --account=csci_ga_3033_085_2022sp
#SBATCH --partition=n1s8-v100-1
#SBATCH --gres=gpu:1

cd ~/neural-net-profiling
singularity exec --bind /share/apps/cuda --overlay /share/apps/datasets/imagenet/imagenet-train.sqf:ro --overlay /share/apps/datasets/imagenet/imagenet-val.sqf:ro --nv ~/nn-profile.sif ./complete_profile.sh
