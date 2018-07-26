#!/usr/bin/perl -w
##################################################################################################################
# To each offspring, add a column for the information from the Female Parent and a column for the Male Parent.
#
# USAGE: perl geneconversion_pipeline_PT6_AddParentData.pl Female_Parents_PassedAllHardFilters/Cross/ \
# 			AllSites_VariantsAfterHardFilters/HetChecked_Interspeces  \
# 			AllSites_VariantsAfterHardFilters/Cross/
##################################################################################################################
use strict;

my @moms = <$ARGV[0]/*table.txt>;
my @homparents = <$ARGV[1]/*.txt>;
my @offspring = <$ARGV[2]/*table.txt>;

#foreach male parent
foreach my $dad (@homparents){
	next if ($dad =~ /000/);
	#find the corresponding mom-- first check what chromosome:
	$dad =~ m/hetfilter_(.*)_table/;
	my $dadchrom = $1;
	foreach my $pf(@moms){
		# and what chromosome is this? 
		$pf =~ m/filteredvariants_(.*)_table/;
		my $chromName = $1;
		next unless ($chromName eq $dadchrom);
		print "Working on chromosome $chromName\n\tPM=$dad\n\tPF=$pf\n";
		my %pfdata;
		open (MOM, "$pf") or die "file not found:$!\n";
		my $pfheader = <MOM>;
		while (<MOM>){
			my $line = $_;
			chomp;
			my @fields = split /\s+/, $line;
			my $chrom = $fields[0];
			my $pos = $fields[1];
			my @gt = ($fields[5]);
			my $coord = "$chrom,$pos";
			$pfdata{$coord} = \@gt;
		}
		close (MOM);
		open (DAD, "$dad") or die "file not found:$!\n";
		my $dadheader = <DAD>;
		while (<DAD>){
			my $line = $_;
			chomp;
			my @fields = split /\s+/, $line;
			my $chrom = $fields[0];
			my $pos = $fields[1];
			my $gt = $fields[5];
			my $coord = "$chrom,$pos";
			if (exists $pfdata{$coord}){
				my @parentGTs = @{$pfdata{$coord}};
				push (@parentGTs, $gt);
				$pfdata{$coord}= \@parentGTs;
			}
		}
		close(DAD);

		foreach my $off(@offspring){
			if ($off =~ m/$chromName/){
				my $notInPF = 0;
				my $inPF = 0;
				$off =~ m/(.*)_table/;
				my $offName = $1;
				print "\tFound a corresponding offspring: $off\n";
				my $output = "$offName"."_withParentData_table.txt";
				open (OUT, ">$output") or die "file not found: $!\n";
				open (IN, "$off") or die "file not found: $!\n";
				my $header = <IN>;
				chomp($header);
				my $newheader = "$header\t"."PFgenotype";
				print OUT "$newheader\n";
				while (<IN>){
					my $line = $_;
					chomp;
					my @fields = split /\s+/, $line;
					my $chrom = $fields[0];
					my $pos = $fields[1];
					my $coord = "$chrom,$pos";
					if (exists $pfdata{$coord}){
						my @pfGT = @{$pfdata{$coord}};
						push (@fields,@pfGT);
						print OUT "@fields\n";
						$inPF++;
					}else {
						$notInPF++;
					}
				}			
				close (OUT);
				print "\t$notInPF offspring SNPs from $offName were not found in the Parent Female ($inPF were found)\n";
			}
		}	
	}
}	
 
exit;
