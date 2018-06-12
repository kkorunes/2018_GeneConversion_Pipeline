#!/bin/bash
#SBATCH --mem=10GB
cd /datacommons/noor/klk37/new_snpcalling/

#Run after marking duplicates with picard and generating a new index for each BAM
#Creates a target list of intervals which need to be realigned, then performs realignment of the intervals
#The resulting realigned BAM contains all the original reads, but with better local alignments in the regions that were targeted

FILES=00D*dedup.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "marking duplicates for $ID"
	INT="$ID"-indelRealigner.intervals
	OUT="$ID"-realigned.bam
	echo "$OUT"
	/opt/apps/slurm/java/jre1.8.0_60/bin/java -jar GATK-3.7-0/GenomeAnalysisTK.jar -T RealignerTargetCreator -R pp1137_chromosomes3.04.fasta -I $BAM -o $INT
	#perform realignment of the target intervals
	/opt/apps/slurm/java/jre1.8.0_60/bin/java -jar GATK-3.7-0/GenomeAnalysisTK.jar -T IndelRealigner -R pp1137_chromosomes3.04.fasta -I $BAM -targetIntervals $INT -o $OUT
done


#Repeat for the GF
FILES=000D*dedup.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "marking duplicates for $ID"
	INT="$ID"-indelRealigner.intervals
	OUT="$ID"-realigned.bam
	echo "$OUT"
	/opt/apps/slurm/java/jre1.8.0_60/bin/java -jar GATK-3.7-0/GenomeAnalysisTK.jar -T RealignerTargetCreator -R pp1137_chromosomes3.04.fasta -I $BAM -o $INT
	#perform realignment of the target intervals
	/opt/apps/slurm/java/jre1.8.0_60/bin/java -jar GATK-3.7-0/GenomeAnalysisTK.jar -T IndelRealigner -R pp1137_chromosomes3.04.fasta -I $BAM -targetIntervals $INT -o $OUT
done
