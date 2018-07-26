#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_SNPcalling_and_GCpipeline/

#Parse the VCFs into a more usable tab-delimited format using GATK's VariantsToTable

#Input the VCFs with hard filter pass/fail information
VCFS=AllSites_VariantsAfterHardFilters/*.vcf

for VCF in $VCFS
do
	echo "FILE: $VCF"
	ID="$(echo ${VCF} | awk -F'[.]' '{print $1}')"
	echo "working on $ID"
	TABLE="$ID"_table.txt
	# CHROM POS REF ALT GT(genotype) AD(refAlleleDepth,AltAlleleDepth FILTER("pass",or failed filter)
	java/jdk1.8.0_144/bin/java -jar GATK-3.8-0/GenomeAnalysisTK.jar -T VariantsToTable -R /datacommons/noor/klk37/pp1137_newreference/pp1137_chromosomes3.04.fasta \
		-V $VCF \
		-F CHROM -F POS -F REF -F ALT -GF GT -GF AD -F FILTER \
		--showFiltered \
		-o $TABLE
done
