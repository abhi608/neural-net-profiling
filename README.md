ImageNet Analysis using Roofline Model
-----------------------------------------

File(s) description:<br/>
a100: Runtime log and parsed file for the data collected on A100 GPU<br/>
v100: Runtime log and parsed file for the data collected on V100 GPU<br/>
imagenet: neural network training code files<br/>
scripts: SBATCH and bash scripts to run the profiler and parse the data<br/>
report.pdf: Final report<br/>
<br/>
Steps:<br/>
1. Login to green cluster. Then login to burst node and execute: <br/>
    "srun --account=csci_ga_3033_085_2022sp --partition=c24m170-a100-2 --gres=gpu:a100:2 --pty /bin/bash"<br/>
   to run the bash shell as a job on a100 GPU. This shell program has acces to the underlying A100 GPU.<br/>
   Similar command for V100 is: <br/>
    "srun --account=csci_ga_3033_085_2022sp --partition=n1s8-v100-1 --gres=gpu:1 --pty /bin/bash"<br/>

2. Once logged in, place the folders andfiles in this project in the home directory. This can be done either using scp or using git.<br/>

3. Logout and open a new terminal on your local machine.<br/>

4. Login to greene cluster, followed by "ssh burst"<br/>

5. Once you're inside the burst node, use the scripts: run_batch_a100.sh and run_batch_v100.sh to schedule batch jobs to run of the respective GPUs. Specifically:<br/>
    --> Update your email address in the script - this email will be used to send you notifications about the status of your slurm job.<br/>
    --> Run: "sbatch run_batch_a100.sh" for running the profiler on A100 GPU<br/>
    --> Run: "sbatch run_batch_v100.sh" for running the profiler on V100 GPU<br/>

    These scripts use the slurm job scheduling. The configuration to run the job is present in these bash scripts. This is a standard sbatch file.<br/>

6. Once complete, different folders will be created for all three neural network models. These are same folders as described above.<br/>

7. Steps to use these logs and perform analysis are in the report.<br/>