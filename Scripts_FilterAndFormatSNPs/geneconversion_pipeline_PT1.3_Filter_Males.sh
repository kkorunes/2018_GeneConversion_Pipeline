#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_SNPcalling_and_GCpipeline/

#Extract SNPs and apply hard filters, requiring less coverage for the male X chromosome (DP 5 rather than 10)

#Male Offspring
I_FILES=Interspecies/00H2M*prevariantfilter.vcf
B_FILES=B/00B1M*prevariantfilter.vcf
D_FILES=D/00D1M*prevariantfilter.vcf
#parents/grandparents:
I_DAD=Interspecies/00HP2M*prevariantfilter.vcf
B_GM=B/000BGM*prevariantfilter.vcf   #GM for B and D (GF for interspecies)
B_DAD=B/00BP1M*prevariantfilter.vcf
D_GM=D/000DGM*prevariantfilter.vcf
D_DAD=D/00DP1M*prevariantfilter.vcf

for VCF in ${I_FILES[@]} ${B_FILES[@]} ${D_FILES[@]} $I_DAD $B_GM $B_DAD $D_GM $D_DAD
do
        echo "FILE: $VCF"
        NAME="$(echo ${VCF} | awk -F'[.]' '{print $1}')"
        ID="$(echo ${NAME} | awk -F'[_]' '{print $1}')"
	echo "working on $ID"
        AUT_SNPS="$ID"-variants_autosomal.vcf
        X_SNPS="$ID"-variants_Xchr.vcf
        java/jdk1.8.0_144/bin/java -jar GATK-3.8-0/GenomeAnalysisTK.jar -T SelectVariants -R /datacommons/noor/klk37/pp1137_newreference/pp1137_chromosomes3.04.fasta -V $VCF \
                -L chromosome_intervals_x.list -o $X_SNPS
        java/jdk1.8.0_144/bin/java -jar GATK-3.8-0/GenomeAnalysisTK.jar -T SelectVariants -R /datacommons/noor/klk37/pp1137_newreference/pp1137_chromosomes3.04.fasta -V $VCF \
                -L chromosome_intervals_autosomes.list -o $AUT_SNPS
        #now, for the X and for the autosomal positions,  we have a vcf containing raw variants
        #next, filter the variants
        OUT_AUT="$ID"_autosomal_filteredvariants_ALLSITES.vcf
        OUT_X="$ID"_Xchr_filteredvariants_ALLSITES.vcf
        java/jdk1.8.0_144/bin/java -jar GATK-3.8-0/GenomeAnalysisTK.jar -T VariantFiltration -R /datacommons/noor/klk37/pp1137_newreference/pp1137_chromosomes3.04.fasta -V $AUT_SNPS \
                --missingValuesInExpressionsShouldEvaluateAsFailing --filterExpression "DP < 10.0 || QUAL < 30.0" --filterName "depth_filter_maleAUT" -o $OUT_AUT
        java/jdk1.8.0_144/bin/java -jar GATK-3.8-0/GenomeAnalysisTK.jar -T VariantFiltration -R /datacommons/noor/klk37/pp1137_newreference/pp1137_chromosomes3.04.fasta -V $X_SNPS \
                --missingValuesInExpressionsShouldEvaluateAsFailing --filterExpression "DP < 5.0 || QUAL < 30.0" --filterName "depth_filter_maleX" -o $OUT_X
done
