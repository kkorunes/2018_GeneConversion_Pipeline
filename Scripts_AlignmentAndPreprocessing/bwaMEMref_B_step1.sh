#!/bin/bash

cd /datacommons/noor/klk37/new_snpcalling/

#/opt/apps/bin/bwa index pp1137_chromosomes3.04.fasta

FILES=00B*R1_001.fastq.gz
for R1 in $FILES
do 
	R2="$(echo ${R1} | sed -e 's/R1/R2/')"
	ID="$(echo ${R1} | awk -F'[_|.]' '{print $1 "_" $2 "_" $3 "_" $5}')"
	echo "$ID file pair: $R1 $R2"
	OUT="$ID"_aln-pe.sam
	BAM="$ID"_aln-pe.bam
	echo "$OUT"
	RG="@RG\tID:$ID\tPL:illumina\tPU:$ID\tLB:$ID\tSM:$ID"
	echo "$RG"
	/opt/apps/bin/bwa mem -R "$RG" pp1137_chromosomes3.04.fasta $R1 $R2 > $OUT
	/opt/apps/rhel7/samtools-1.4/bin/samtools view -b $OUT > $BAM
	rm $OUT
done
