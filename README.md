# biosoft
常用生物学软件总结
### __GATK群call SNP__
```
java -Xmx8g -jar  GenomeAnalysisTK.jar -T UnifiedGenotyper -R   ref.fa --genotyping_mode DISCOVERY -o sample.vcf -I bam.list -L     SL4.0ch10 -glm BOTH -ploidy 2 -rf BadCigar -nt 1 -nct 1
```
