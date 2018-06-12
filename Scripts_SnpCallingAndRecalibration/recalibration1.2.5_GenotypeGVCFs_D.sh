#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_SNPcalling_and_GCpipeline/D

#Create gVCFs (every position, even non-variant, included)

FILES=*.g.vcf
for VCF in $FILES
do 
	NAME="$(echo ${VCF} | awk -F'[/]' '{print $NF}')"
	ID="$(echo ${NAME} | awk -F'[_]' '{print $1}')"
	echo "calling variants for $ID"
	OUT="$ID"_prevariantfilter.vcf
	SCRIPT="$ID".sh
	echo "$OUT"
	echo '#!/bin/bash' > $SCRIPT
	echo '#SBATCH --mem=20GB' >> $SCRIPT
	echo 'cd /datacommons/noor/klk37/new_SNPcalling_and_GCpipeline/D' >> $SCRIPT
	echo "../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T GenotypeGVCFs -R ../pp1137_chromosomes3.04.fasta --variant $VCF -allSites -o $OUT" >> $SCRIPT
	sbatch $SCRIPT
done
