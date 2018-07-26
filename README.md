# 2018_GeneConversion_Pipeline
Scripts for genome alignment, SNP calling, and recombination identification. 

The same pipeline was executed on the 3 crosses, which are labeled in the scripts as: 
* "B" (within species, homokaryotypic). 
* "D" (within species, heterokaryotypic on the 3rd chromosome). 
* "Interspecies" or "Interspp" (interspecies cross between D. pseudoobscura and D. persimilis).

#### Sequence alignment scripts are contained subdirectory "Scripts_AlignmentAndPreprocessing":
All read data from the 3 crosses were mapped to the PP1137 reference using bwa v0.7.5. After alignment, SAMtools v1.4 was used to convert to BAM, sort, and index each genome. Picard was used to mark duplicates, and the Genome Analysis Toolkit (GATK) v3.8 RealignerTargetCreator and IndelRealigner were used for local realignment around indels.

#### The SNP calling pipeline is contained in the subdirectory "Scripts_SnpCallingAndRecalibration":
In summary, each BAM file was provided to GATK’s HaplotypeCaller to obtain initial variant calls. These initial variant calls were hard-filtered to obtain a set of high-confidence SNPs, which were subsequently used for Base Quality Score Recalibration (BQSR). We used BaseRecalibrator to analyze covariation in the dataset, and then performed a second pass to analyze covariation after recalibration. A second iteration was performed to check for “convergence”. This base recalibration yielded the original reads with recalibrated base quality scores, and we then repeated HaplotypeCaller with this recalibrated data

#### Filter and parsing prior to gene conversion detection is in the subdirectory "Scripts_FilterAndFormatSNPs":
First GATK hard filters were applied, with more stringent filters applied to the female parents. GATK "VariantsToTable" was applied to make the data easier to parse. The grandparents and male parents of each cross were checked for unexpected heterozygosity, and the flagged sites were added to offspring files, along with the genotypes from each parent.

#### Scripts to scan the offspring genomes for putative gene conversion are in "Scripts_DetectGeneConversion":
Separate scripts are provided for scanning the hemizygous male X chromosomes and the rest of the sequences (female X chromosomes and all autosomes).
