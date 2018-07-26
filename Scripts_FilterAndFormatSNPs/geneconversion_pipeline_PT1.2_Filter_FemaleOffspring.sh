#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_SNPcalling_and_GCpipeline/

#apply hard filters

#Female Offspring
I_FILES=Interspecies/00H2F*prevariantfilter.vcf
B_FILES=B/00B1F*prevariantfilter.vcf
D_FILES=D/00D1F*prevariantfilter.vcf

#Female parents:
I_GF=Interspecies/000HGF*prevariantfilter.vcf   #GF for Interspecies only (GM for other crosses)

for VCF in ${I_FILES[@]} ${B_FILES[@]} ${D_FILES[@]} $I_GF
do
	echo "FILE: $VCF"
	NAME="$(echo ${VCF} | awk -F'[.]' '{print $1}')"
	ID="$(echo ${NAME} | awk -F'[_]' '{print $1}')"
	echo "working on $ID"
	#next, filter the snps	
	OUT="$ID"_filteredvariants_ALLSITES.vcf
	java/jdk1.8.0_144/bin/java -jar GATK-3.8-0/GenomeAnalysisTK.jar -T VariantFiltration -R /datacommons/noor/klk37/pp1137_newreference/pp1137_chromosomes3.04.fasta -V $VCF --missingValuesInExpressionsShouldEvaluateAsFailing --filterExpression "DP < 10 || QUAL < 30.0" --filterName "depth_filter_females" -o $OUT
done
