#!/usr/bin/perl -w
#########################################################################################
# Go through putative gene conversions and remove any that have indels in the parent
# female
#
#  USAGE: perl geneconversion_pipeline_3.pl <PF_INDEL_table.txt/> <PutativeGeneConversions/>
#########################################################################################
use strict;

my $pfindels = $ARGV[0]; #Gather indels from the parent female
my @allPutative = <$ARGV[1]/*withParentData_putative_gene_conversions.txt>;

my %pfsites;
open (INDELS, "$pfindels") or die "unable to open $!";
my $header = <INDELS>;
while (my $line = <INDELS>){
	chomp $line;
	my @fields = split /\s+/, $line;
	my $chrom = "$fields[0]";
	my $coord = "$fields[1]";
	for(my $i = ($coord - 5); $i <= ($coord + 5); $i++){ #5bp buffer on either side of indel location
		my $loc = "$chrom,$i";
		$pfsites{$loc} = "indel";
	}
}
close (INDELS);


foreach my $putative(@allPutative){
	$putative =~ m/\/(\w+)_filteredvariants_ALLSITES_(\w+.*)_ParentalHetChecked_withParentData_putative_gene_conversions.txt/;
	my $matchname = $1;
	my $matchchrom = $2;

	my $filtered = "$matchname"."_filteredvariants_ALLSITES_"."$matchchrom"."_ParentalHetChecked_withParentData_IndelFiltered_putative_gene_conversions.txt";
	open (OUT, ">$filtered") or die "unable to open $!";
	my $count = 0;
	print "Working on $matchname, chromosome $matchchrom\n";
	open (IN, $putative) or die "unable to open $!\n";
	while (my $line = <IN>){
		chomp $line;
		my @fields = split /\s+/, $line;
		my $putativechrom = "$fields[1]";
		my @focal = (split /\//,"$fields[3]");
		my $instance = 0;
		foreach my $focal (@focal){
			$instance++;
			my $loc = "$putativechrom,$focal";	
			if (exists $pfsites{$loc}){
				if ($instance == 1){
					$count++;
				}
			} else {
				#already counted with the 1st focal SNP
				if ($instance == 1){
					print OUT "$line\n";
				}
			}
		}
	}	
	print "Done parsing: $putative. Filtered out $count putative conversions\n";
	close (IN);
	close (OUT);

}
print "DONE!\n";
exit;
