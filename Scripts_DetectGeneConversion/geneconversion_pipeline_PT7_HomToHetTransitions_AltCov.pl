#!/usr/bin/perl -w
###############################################################
#  Looks for HOM->HET->HOM transitions in the *.snps file
#  and produces the *.transitions file along with a summary file
#  (*.summary).
#
#  USAGE: perl geneconversion_pipeline_3.pl <SNP_TABLES/>
###############################################################
use strict;

my @SNPS = <$ARGV[0]/*table.txt>;
my $summary = "All_exceptMaleX_Individuals_GC_SUMMARY";
open (SUM, ">$summary") or die "file not found: $!";
print SUM "INDIVIDUAL\tGENECONVERSIONS\tAVGLENGTH\n";
foreach my $indiv(@SNPS){
	$indiv =~ m/00(.*)_table.txt/;
	my $name = "00"."$1";
	next if ($name =~ /Xchr/)&&($name =~ /\dM\d/);
	print "working on $name\n";
	
	# Process the file in windows
	my $windowsize = 10; #set the window size here.
	my $counter = 0;
	open(IN, "$indiv") or die "$!";
	my @all = <IN>;
	close(IN);
	my $linecount = @all;
	print "Total lines to process: $linecount, in windows of $windowsize\n";
	
	my %candidates = ();
	my $convCount = 0;
	my @lengths;
	#these are the starting positions for every window
	WINDOW: for (my $i = 1; $i < ($linecount - $windowsize); $i++){
		open (IN, $indiv) or die "file not found: $!";
		do {<IN>} until ($. == $i); #find the line that starts this window
		my @chunk;
		#print "on line $i\n";
		while(my $line = <IN>){
			chomp $line;
			if ($counter < 10){		
				push (@chunk, $line);	
			}else{		
				#Pass this window to a subroutine to check for gene conversion candidates
				my @converted = transitionScan(\@chunk);
				my $filter = filtercheck(\@chunk);
				my $chrom = "$converted[0]";
				my $snps = "$converted[1]";
				my $convPositions = "$converted[2]";
				my $left = "$converted[3]";
				my $right = "$converted[4]";
				if (($snps > 0) && ($filter == 0)){
					#This looks like a good candidate!
					my $key = "$chrom:$convPositions";
					if (!(exists $candidates{$key})){
						$convCount++;
						my $length = ($right-$left);
						push (@lengths, $length);
						$candidates{$key} = [($name,$chrom,$snps,$convPositions,$left,$right)];	
						print "@converted\n";
					}	
				}
				#Go to next window using the line number offset by 1
				$counter = 0;
				close (IN);
				next WINDOW;
			}
			$counter++;
		}
		close (IN);
	}	
	print "Done parsing individual: $indiv\n";

	if (%candidates){
		my $output = "$name"."_putative_gene_conversions.txt";
		open (OUT, ">$output") or die "file not found: $!\n";
		foreach my $key (sort keys %candidates){
			print OUT join("\t",@{$candidates{$key}}), "\n";
		}
		close(OUT);
	}

	my $total = 0;
	foreach(@lengths){
		$total += $_;
	}
	my $avgLength = 0;
	if ($convCount > 0){
		$avgLength = ($total/$convCount);
	} 
	print SUM "$name\t$convCount\t$avgLength\n";
}

close(SUM);
print "DONE!\n";
exit;

###########################################################################
#SUBROUTINES
###########################################################################

# see if all positions in a window passed the filters
sub filtercheck{
	my $chunk_ref = shift;
	my @chunk = @$chunk_ref;
	my @filter;
	foreach my $line(@chunk){
		my @fields = split /\s+/, $line;
		chomp @fields;	
		my $filterfield = "$fields[4]";
		push (@filter, $filterfield);
	}
	my $failed = 0;
	foreach my $position (@filter){
		if ("$position" ne "PASS"){
			$failed++;	
		}
	}	
	#Return the number of positions that failed one of the filters
	return $failed;
}



# look for transitions of HOM(>=3)->HET(<5 && >=1)->HOM(>=3)
sub transitionScan{
	my $chunk_ref = shift;
	my @chunk = @$chunk_ref;
	my @gts;
	my @hethom;
	my $result = 0;
	my @summary = (0,0,0,0,0);
	my @chromosome;
	my @positions;
	my @ads; #for checking the depths
	#added:
	my @pfGTs;

	foreach my $line(@chunk){
		#print "LINE: $line\n";
		my @fields = split /\s+/, $line;
		chomp @fields;
		if ((scalar @fields) < 9){ #skip if missing field
			return @summary;
		}
		
		my $chrom = "$fields[0]";
		push (@chromosome, $chrom);
		my $pos = "$fields[1]";
		push (@positions, $pos);
		my $gt = "$fields[5]";
		push (@gts, $gt);
		#added the following lines to check that pf is actually het and we have PM information
		my $pf = "$fields[7]";
		my $pm = "$fields[8]";
		my $depths = "$fields[6]";
		push (@ads, $depths);
	
		my @pfAlleles = split /\//, $pf;
		if (("$pfAlleles[0]" eq "$pfAlleles[1]")||("$pfAlleles[0]" !~ /[A-Z]?/) || ("$pfAlleles[1]" !~ /[A-Z]?/ )){
			return @summary;
		}else{
			push(@pfGTs,"het");
		}		
		my $ref = "uncertain";
		my $alt = "uncertain";
		my @pmAlleles = split /\//, $pm;
		if (("$pmAlleles[0]" eq "$pmAlleles[1]")&&("$pmAlleles[0]" !~ /\./)){
			$ref = "$pmAlleles[0]";	#the male parent is homozygous, use this as the reference
		}else{
			return @summary;
		}
	
		#get the alt
		if("$pfAlleles[0]" eq "$ref"){
			$alt = $pfAlleles[1];
		} elsif ("$pfAlleles[1]" eq "$ref"){
			$alt = $pfAlleles[0];
		}else{
			return @summary;
		}
				
		#print "alleles:$gt, pm=$pm,pf=$pf\n"; 
		my @alleles = split /\//, $gt;
		if ("$alleles[0]" eq "$ref"){
			if ("$alleles[1]" eq "$ref"){
				push (@hethom, "homref");
			}elsif("$alleles[1]" eq "$alt"){
				push (@hethom, "het");
			}else{
				return @summary;
			}
		}elsif("$alleles[0]" eq "$alt"){
			if ("$alleles[1]" eq "$alt"){
				push (@hethom, "homalt");
			}elsif("$alleles[1]" eq "$ref"){
				push (@hethom, "het");
			}else{
				return @summary;
			}
		}else{
			#print "Warning: $chrom,$pos has an allele (@alleles) that matched neither parent.  PF=$pf and PM=$pm\n";
			return @summary;
		}
		#print "\t@hethom\n";	
	}

	#check that the chromosomes are the same across the chunk;
	my $newchrom = 0;
	my $hetcount = 0;
	foreach my $number (@chromosome){
		if ("$number" ne "$chromosome[0]"){
			$newchrom++;
		}
	}

	if (($newchrom == 0)&&(scalar @chunk == scalar @hethom)){	
		my $differences = 0; #count how many positions are different from the outer positions
		my @middle;
		#Does this first state equal the last? if so, check for >=3 on each end
		if (("$hethom[0]" =~ /hom/) && ("$hethom[0]" eq "$hethom[-1]") && ("$hethom[0]" eq "$hethom[1]") && ("$hethom[1]" eq "$hethom[2]")){
			#check the last 3 elements:
			if (("$hethom[-1]" eq "$hethom[-2]") && ("$hethom[-2]" eq "$hethom[-3]")){
				#see if anything in the middle is different
				@middle = @hethom[3 .. 6];	
				foreach my $mid (@middle){
					if ("$mid" ne "$hethom[0]"){
						$differences++;
	 				}
				}
			}
		}			

		if ($differences == 1) {
			# this is a 1-SNP putative conversion
			$result = 1;
		} elsif ($differences == 2) {
			#make sure that they are consecutive:
			if ("$middle[0]" eq "$middle[1]"){
				#this is a 2-SNP putative conversion
				$result = 2;	
			}
		} elsif ($differences == 3) {
			#make sure they are consecutive:
			if (("$middle[0]" eq "$middle[1]") && ("$middle[1]" eq "$middle[2]")){
				#this is a 3-SNP putative conversion
				$result = 3;
			}
		} elsif ($differences == 4) { #this is a 4-SNP putative conversion
			$result = 4;
		}
	
		if ($result > 0){
			#Figure out the coordinates of the converted and flanking SNPs
			my @conversions;
			#find where the het/hom state changes
			my $left = 0;
			my $right = 0;
			my $counter = 0;
			my @pfCheck; #ADDED!!!
			my @depthCheck;
			for (my $i = 0; $i < @hethom; $i++){
				my $state = "$hethom[$i]";
				if ("$state" ne "$hethom[0]"){
					push (@conversions, "$positions[$i]");
					push (@pfCheck, "$pfGTs[$i]");
					push (@depthCheck, "$ads[$i]");
					if ($counter == 0){
						$left = "$positions[$i-1]";
					}
					$counter++;
				}
				if (($counter == $differences)&&($right==0)){ #we've found the whole tract, and already stored the R flanking snp
					$right = "$positions[$i+1]";
				}
			}	
		
			my $conv = join("\/", @conversions);			
			#Return the number of converted SNPs if this looks like a conversion tract:
			# $result equals the number converted
			#check that flanking snps are less that 10000bp apart
			my $maxtract = ($right-$left);
				
			#ADDED CHECK PFS
			my $failedpfs = 0;
			foreach my $check(@pfCheck){
				if ($check eq "hom"){
					$failedpfs++;
				}
			}	
			#ADDED CHECK ALLELE DEPTHS
			my $faileddepths = 0;
			foreach my $ad(@depthCheck){		
				my @alleledepths = split /,/, $ad;
				my $total = ($alleledepths[0] + $alleledepths[1]);
				foreach my $depth(@alleledepths){
					if(($depth < 3)||(($depth/$total) < 0.25)){
						$faileddepths++;	
					}
				}	
			}

			if (($maxtract < 10001)&&($failedpfs == 0)&&($faileddepths == 0)){
				@summary = ("$chromosome[0]",$result,$conv,$left,$right);
			}	
		}
	}
	#print "genotypes: @gts\nhethome: @hethom\n"; #\nsummary:@summary\n";
	return @summary;
}
