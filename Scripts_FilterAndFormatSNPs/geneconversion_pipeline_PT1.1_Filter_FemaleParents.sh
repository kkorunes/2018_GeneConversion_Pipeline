#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_SNPcalling_and_GCpipeline/

#Extract SNPs and apply hard filters

#Female parents:
I_MOM=Interspecies/00HP2F*prevariantfilter.vcf
B_MOM=B/00BP1F_prevariantfilter.vcf
D_MOM=D/00DP1F_prevariantfilter.vcf

for VCF in $I_MOM $I_GF $B_MOM $D_MOM
do
	echo "FILE: $VCF"
	NAME="$(echo ${VCF} | awk -F'[.]' '{print $1}')"
	ID="$(echo ${NAME} | awk -F'[_]' '{print $1}')"
	echo "working on $ID"
	SNPS="$ID"-SNPS.vcf
	echo "$SNPS"
	java/jdk1.8.0_144/bin/java -jar GATK-3.8-0/GenomeAnalysisTK.jar -T SelectVariants -R /datacommons/noor/klk37/pp1137_newreference/pp1137_chromosomes3.04.fasta -V $VCF -selectType SNP -o $SNPS
	#now we have a vcf containing just the snps from the file of raw variants
	#next, filter the snps	
	OUT="$ID"_filteredvariants.vcf
	java/jdk1.8.0_144/bin/java -jar GATK-3.8-0/GenomeAnalysisTK.jar -T VariantFiltration -R /datacommons/noor/klk37/pp1137_newreference/pp1137_chromosomes3.04.fasta -V $SNPS --filterExpression "QD < 2.0 || DP < 10 || QUAL < 30.0" --filterName "depth_filter_females" --filterExpression "FS > 60.0 || SOR > 3.0" --filterName "StrandBias" -o $OUT	
done
