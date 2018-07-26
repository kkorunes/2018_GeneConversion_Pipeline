#!/usr/bin/perl -w
######################################################################################
##  Identify heterozygous positions in the Parent Males, 000BGM, 000DGM, and 000HGF.
#   For these sites, add a flag to the filter column. Flag = "UnexpectedHetRegion"
#
# USAGE: perl geneconversion_pipeline_PT3_HetCheck.pl 00HP2M-filteredvariants_autosomal_table.txt \
# 		00HP2M-filtervariants_Xchr_table.txt \
#		00BP1M-filteredvariants_autosomal_table.txt \
#		00BP1M-filteredvariants_Xchr_table.txt \
#		00DP1M-filteredvariants_autosomal_table.txt \
#		00DP1M-filteredvariants_Xchr_table.txt \
#		000BGM-filteredvariants_autosomal_table.txt \
#		000BGM-filteredvariants_Xchr_table.txt \
#		000DGM-filteredvariants_autosomal_table.txt \
#		000DGM-filteredvariants_Xchr_table.txt \
#		000HGF-filteredvariants_table.txt
###################################################################################
use strict;

print "Files to check: @ARGV\n";

foreach my $file(@ARGV) {
	$file =~ m/(.*)_table/;
	my $name = $1;
	my $output = "$name"."_hetfilter_table.txt";
	open (IN, "$file") or die "file not found: $!\n";
	open (OUT, ">$output") or die "file not found: $!\n";
	print "Processing $file\n";
	my $hetcount = 0;
	my $header = <IN>;
	chomp($header);
	print OUT "$header\n";
	while (<IN>){
		my $line = $_;
		chomp;
		my @fields = split /\s+/, $line;
		my $filter = $fields[4];
		my $GT = $fields[5];
		my @GTs = split /\//, $GT;
		if ("$GTs[0]" eq "$GTs[1]") {
			# Homozygous, so print the line as is:
			print OUT "@fields\n";
		} else {
			#If filter was PASS before, replace with "UnexpectedHet". If there was an existing filter,
			# append "UnexpectedHet to the existing info.
			if ("$filter" eq "PASS"){
				splice @fields,4,1,'UnexpectedHet';
				print OUT "@fields\n";
			} else {
				my $newfilter = "$filter".","."UnexpectedHet";
				splice @fields,4,1,$newfilter; #replace filter field with "UnexpectedHetRegion"
				print OUT join("\t","@fields"),"\n";
			}
			$hetcount++;
		}
	}
	print "found $hetcount heterozygous sites in $file\n";
	close (IN);
	close (OUT);
}
 
exit;
