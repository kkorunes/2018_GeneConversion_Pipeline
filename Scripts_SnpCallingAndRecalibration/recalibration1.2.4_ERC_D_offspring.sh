#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/new_SNPcalling_and_GCpipeline/D

#Create gVCFs (every position, even non-variant, included)

FILES=/datacommons/noor2/klk37/new_GCpipeline/BAMfiles/00D*realigned.bam
for BAM in $FILES
do 
	NAME="$(echo ${BAM} | awk -F'[/]' '{print $NF}')"
	ID="$(echo ${NAME} | awk -F'[.]' '{print $1}')"
	echo "calling variants for $ID"
	TABLE="$ID"_recal2_data.table
	OUT="$ID".g.vcf
	SCRIPT="$ID".sh
	echo "$OUT"
	echo '#!/bin/bash' > $SCRIPT
	echo '#SBATCH --mem=20GB' >> $SCRIPT
	echo 'cd /datacommons/noor/klk37/new_SNPcalling_and_GCpipeline/D' >> $SCRIPT
	echo "../java/jdk1.8.0_144/bin/java -jar ../GATK-3.8-0/GenomeAnalysisTK.jar -T HaplotypeCaller -R ../pp1137_chromosomes3.04.fasta -I $BAM -ERC BP_RESOLUTION -BQSR $TABLE -o $OUT" >> $SCRIPT
	sbatch $SCRIPT
done
