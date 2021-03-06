#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_snpcalling/D

#Extract SNPs and apply hard filters to get the knownsites.vcf
FILES=00D*raw-recal_1.vcf
for VCF in $FILES
do 
	ID="$(echo ${VCF} | awk -F'[.]' '{print $1}')"
	echo "working on $ID"
	SNPS="$ID"-SNPS.vcf
	echo "$SNPS"
	../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T SelectVariants -R ../pp1137_chromosomes3.04.fasta -V $VCF -selectType SNP -o $SNPS
	#now we have a vcf containing just the snps from the file of raw variants
	#next, filter the snps	
	OUT="$ID"-knownsites2.vcf
	../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T VariantFiltration -R ../pp1137_chromosomes3.04.fasta -V $SNPS \
		--filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" --filterName "knownsites2_filter" -o $OUT
	
done

#Repeat for the GF
FILES=000D*raw-recal_1.vcf
for VCF in $FILES
do 
	ID="$(echo ${VCF} | awk -F'[.]' '{print $1}')"
	echo "working on $ID"
	SNPS="$ID"-SNPS.vcf
	echo "$SNPS"	
	../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T SelectVariants -R ../pp1137_chromosomes3.04.fasta -V $VCF -selectType SNP -o $SNPS	
	OUT="$ID"-knownsites2.vcf
	../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T VariantFiltration -R ../pp1137_chromosomes3.04.fasta -V $SNPS \
		--filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" --filterName "knownsites2_filter" -o $OUT
done
