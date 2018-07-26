#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_SNPcalling_and_GCpipeline/

#Female parents:
I_MOM=Interspecies/prevariantfilter/00HP2F*prevariantfilter.vcf
B_MOM=B/prevariantfilter/00BP1F_prevariantfilter.vcf
D_MOM=D/prevariantfilter/00DP1F_prevariantfilter.vcf

for VCF in $I_MOM $B_MOM $D_MOM
do
	echo "FILE: $VCF"
	NAME="$(echo ${VCF} | awk -F'[.]' '{print $1}')"
	ID="$(echo ${NAME} | awk -F'[_]' '{print $1}')"
	echo "working on $ID"
	INDELS="$ID"-INDELS.vcf
	java/jdk1.8.0_144/bin/java -jar GATK-3.8-0/GenomeAnalysisTK.jar -T SelectVariants -R /datacommons/noor/klk37/pp1137_newreference/pp1137_chromosomes3.04.fasta -V $VCF -selectType INDEL -o $INDELS
	#now we have a vcf containing just the indels from the file of raw variants
done
