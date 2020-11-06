## 1.数据预处理
合并fastq数据
<br> cat fastq_pass/*.fastq >115.fastq
<br> nanopolish需要用到原始信号。首先，需要创建一个索引文件，该文件将读取的ID与FAST5文件中的信号建立链接。
<br>
```nanopolish index -d fast5_files/ output.fastq```
## 2. 将reads和参考基因组进行比对
```minimap2 -a -x map-ont reference.fasta output.fastq | samtools sort -T tmp -o output.sorted.bam samtools index output.sorted.bam ```

## 3.甲基化位点检测
```nanopolish call-methylation -t 8 -r output.fastq -b output.sorted.bam -g reference.fasta -w "chr20:5,000,000-10,000,000" > methylation_calls.tsv ```
