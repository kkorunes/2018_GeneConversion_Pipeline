#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_snpcalling/B

FILES=00B*realigned.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "working on $ID"
	KNOWN="$ID"-raw-recal_1-knownsites2.vcf
	TABLE="$ID"_recal2_data.table
	OUT="$ID"_post_recal2_data.table
	echo "$KNOWN"
	../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T BaseRecalibrator -R ../pp1137_chromosomes3.04.fasta -I $BAM -knownSites $KNOWN -BQSR $TABLE -o $OUT
done

#Repeat for the GF
FILES=000B*realigned.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "calling variants for $ID"
	KNOWN="$ID"-raw-recal_1-knownsites2.vcf
	TABLE="$ID"_recal2_data.table
	OUT="$ID"_post_recal2_data.table
	echo "$KNOWN"	
	../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T BaseRecalibrator -R ../pp1137_chromosomes3.04.fasta -I $BAM -knownSites $KNOWN -BQSR $TABLE -o $OUT
done
