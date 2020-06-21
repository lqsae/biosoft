## 1.数据预处理
```
multi_to_single_fast5
    -i, --input_path <(path) folder containing multi_read_fast5 files>
    -s, --save_path <(path) to folder where single_read fast5 files will be output>
    [optional] -t, --threads <(int) number of CPU threads to use; default=1>
    [optional] --recursive <if included, recursively search sub-directories for multi_read files> 
```
## 2 数据转为single-fast5之后，用albacore 软件call base
```
source activate albacore
read_fast5_basecaller.py 
	--input /mnt/CCX/User/liuqingshan/methylation/deepsignal/00.data/115.single_fast5_reads 
	-f FLO-PRO002 -k SQK-LSK109 
	-c /mnt/CCX/User/liuqingshan/basecall/115/r941_450bps_linear_prom.cfg  #配置文件
	--recursive 
	--worker_threads 10  
	--save_path /mnt/CCX/User/liuqingshan/basecall/115 
	--output_format fastq,fast5
  ```
  
  ## 3 甲基化检测[deepmod](https://github.com/WGLab/DeepMod)
  ```
  source activate /mnt/CCX/Share/software/Anaconda3/envs/deepmod
python /mnt/CCX/User/liuqingshan/deepmod/DeepMod-master/bin/DeepMod.py detect 
	--wrkBase /mnt/CCX/User/liuqingshan/basecall/115/workspace/pass  
	--Ref  /mnt/CCX/User/liuqingshan/deepmod/02.test/A01.fa  
	--outFolder  out_folder 
	--basecall_1d Basecall_1D_001  
	--Base C  
	--modfile  /mnt/CCX/User/liuqingshan/deepmod/DeepModmaster/train_mod/rnn_f7_wd21_chr1to10_4/mod_train_f7_wd21_chr1to10 
	--FileID A01 --threads 4
  ```
