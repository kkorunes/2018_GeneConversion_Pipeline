#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_snpcalling/

FILES=00B*sorted.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "marking duplicates for $ID"
	OUT="$ID"-dedup.bam
	echo "$OUT"
	METRIC="$ID"-metric.txt
	echo "$METRIC"
	/opt/apps/slurm/java/jre1.8.0_60/bin/java -jar picard.jar MarkDuplicates I=$BAM O=$OUT METRICS_FILE=$METRIC
done

#Repeat for the GF
FILES=000B*sorted.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "marking duplicates for $ID"
	OUT="$ID"-dedup.bam
	echo "$OUT"
	METRIC="$ID"-metric.txt
	echo "$METRIC"
	/opt/apps/slurm/java/jre1.8.0_60/bin/java -jar picard.jar MarkDuplicates I=$BAM O=$OUT METRICS_FILE=$METRIC
done
