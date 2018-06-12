#!/bin/bash

cd /datacommons/noor/klk37/new_snpcalling/

FILES=00H*.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "sorting and indexing bam file for $ID"
	OUT="$ID"-sorted.bam
	echo "$OUT"
	/opt/apps/rhel7/samtools-1.4/bin/samtools sort -o $OUT $BAM
	/opt/apps/rhel7/samtools-1.4/bin/samtools index $OUT
done


FILES=000H*.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "sorting and indexing bam file for $ID"
	OUT="$ID"-sorted.bam
	echo "$OUT"
	/opt/apps/rhel7/samtools-1.4/bin/samtools sort -o $OUT $BAM
	/opt/apps/rhel7/samtools-1.4/bin/samtools index $OUT
done
