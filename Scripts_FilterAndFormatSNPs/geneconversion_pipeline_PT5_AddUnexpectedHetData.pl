#!/usr/bin/perl -w
######################################################################################
##  Heterozygous positions in the Parent Males, 000BGM, 000DGM, and 000HGF.
#   have a flag to the filter column. Flag = "UnexpectedHetRegion". Add this information
#   to each offspring.
#
# USAGE: perl geneconversion_pipeline_PT5_AddUnexpectedHetData.pl HetChecked_Cross/ Offspring/
###################################################################################
use strict;

my @hetPMs = <$ARGV[0]/00*P*M*_table.txt>;
my @offspring = <$ARGV[1]/*_table.txt>;
foreach my $file(@hetPMs) {
	$file =~ m/hetfilter_(.*)_table/;
	my $name = $1;
	print "Processing file $file\n";
	open (IN, "$file") or die "file not found: $!\n";
	#open (OUT, ">$output") or die "file not found: $!\n";
	my $hetcount = 0;
	my %hetsites;
	my $header = <IN>;
	chomp($header);
	#print OUT "$header\n";
	while (<IN>){
		my $line = $_;
		chomp;
		my @fields = split /\s+/, $line;
		my $pos = $fields[1];
		my $filter = $fields[4];
		my $coord = "$name,$pos";
		# append "UnexpectedHet" to the existing info if the PM is Het at this site
		if ("$filter" =~ /UnexpectedHet/){
			$hetcount++;
			$hetsites{$coord}="ParentalHet";
		} else {
			next;
		}
	}
	close (IN);
	
	#also add flags for Grandparents
	my @grand = <$ARGV[0]/000*_table.txt>;
	foreach my $gp (@grand){
		if ($gp =~ m/$name/){
			print "\tFound corresponding grandparent: $gp\n";
			open (GP, "$gp") or die "file not found $!\n";
			while (<GP>){
				my $line = $_;
				chomp;
				my @fields = split /\s+/, $line;
				my $pos = $fields[1];
				my $filter = $fields[4];
				my $coord = "$name,$pos";
				# append "UnexpectedHet" if the grandparent is het at this site
				if ("$filter" =~ /UnexpectedHet/){
					$hetcount++;
					$hetsites{$coord}="GrandParentalHet";
				} else {
					next;
				}
			}
			close (GP);
		}
	}
	print "Found $hetcount heterzygous parental/grandparental sites in $file\n";

	#now go through the offspring for this cross/chromosome and add flags to their filter columns
	foreach my $off(@offspring){
		if ($off =~ m/$name/){
			print "\tFound a corresponding offspring: $off\n";
			$off =~ m/(.*)_table/;
			my $offName = $1;
			my $hetchecked = "$offName"."_ParentalHetChecked_table.txt";
			open (OUT, ">$hetchecked") or die "file not found: $!\n";
			open (OFF, "$off") or die "file not found: $!\n";
			#append parental het flaf to filter column in offspring
			while (<OFF>){
				my $line = $_;
				chomp;
				my @fields = split /\s+/, $line;
				my $pos = $fields[1];
				my $filter = $fields[4];
				my $coord = "$name,$pos";
				#has this site been flagged as heterozygous in the PM or grandparent?
				if(exists $hetsites{$coord}){
					my $newfilter = "$filter".","."ParentalHet";
					splice @fields,4,1,$newfilter;
					print OUT "@fields\n";
				}else{
					print OUT "@fields\n";
				}	
			}
			close (OFF);
			close (OUT);
		}
	}
}
 
exit;
