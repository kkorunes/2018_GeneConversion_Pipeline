#!/bin/bash
#SBATCH --mem=10GB
cd /datacommons/noor/klk37/new_snpcalling/

FILES=00B*dedup.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "indexing $ID"
	echo "$OUT"
	/opt/apps/slurm/java/jre1.8.0_60/bin/java -jar picard.jar BuildBamIndex I=$BAM
done


/opt/apps/slurm/java/jre1.8.0_60/bin/java -jar picard.jar BuildBamIndex I=000BGM_ATTCCT_L002_001_aln-pe-sorted-dedup.bam
