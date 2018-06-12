#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_snpcalling/Interspecies/

export PATH=/opt/apps/rhel7/R-3.3.2/bin:$PATH

FILES=00H*realigned.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "working on $ID"
	BEFORE="$ID"_recal_data.table
	AFTER="$ID"_post_recal_data.table
	PLOTS="$ID"_recalibration_plots.pdf
	../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T AnalyzeCovariates -R ../pp1137_chromosomes3.04.fasta -before $BEFORE -after $AFTER -plots $PLOTS
done

#Repeat for the GF
FILES=000H*realigned.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "calling variants for $ID"
	BEFORE="$ID"_recal_data.table
	AFTER="$ID"_post_recal_data.table
	PLOTS="$ID"_recalibration_plots.pdf
	../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T AnalyzeCovariates -R ../pp1137_chromosomes3.04.fasta -before $BEFORE -after $AFTER -plots $PLOTS
done
