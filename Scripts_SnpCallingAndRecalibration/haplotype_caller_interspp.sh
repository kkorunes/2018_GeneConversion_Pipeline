#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_snpcalling/Interspecies/

#Create initial variant calls

FILES=00H*realigned.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "calling variants for $ID"
	OUT="$ID"-raw.vcf
	echo "$OUT"
	../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T HaplotypeCaller -R ../pp1137_chromosomes3.04.fasta -I $BAM -stand_call_conf 50 -o $OUT
done


#Repeat for the GF
FILES=000H*realigned.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "calling variants for $ID"
	OUT="$ID"-raw.vcf
	echo "$OUT"
	../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T HaplotypeCaller -R ../pp1137_chromosomes3.04.fasta -I $BAM -stand_call_conf 50 -o $OUT
done
