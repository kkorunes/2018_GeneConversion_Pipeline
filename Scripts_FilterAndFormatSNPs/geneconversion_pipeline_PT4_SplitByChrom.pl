#!/usr/bin/perl -w
#  Split the allOffspring SNPS files by chromosome to make the data more manageable
#  USAGE: perl geneconversion_pipeline_PT4_SplitByChrom.pl directory/
use strict;

my @SNPS = <"$ARGV[0]"/*_table.txt>;
foreach my $input(@SNPS){
	$input =~ m/\/(\w+.*)_table.txt/;
	my $name = $1;
	open (IN, "$input") or die "file not found: $!";
	
	my $out = "temp1.txt";
	my $out2 = "temp2.txt";		
	my $out3 = "temp3.txt";	
	my $out4 = "temp4.txt";
	my $out5 = "temp5.txt";
	my $out6 = "temp6.txt";
	my $out7 = "temp7.txt";
	my $out8 = "temp8.txt";
	my $out9 = "temp9.txt";
	my $out10 = "temp10.txt";
	my $out11 = "temp11.txt";
	my $out12 = "temp12.txt";
	my $out13 = "temp13.txt";
	my $out14 = "temp14.txt";
	my $out15 = "temp15.txt";

	if ($name =~ m/autosomal/){
		$out = "$name"."_chr2_table.txt";
		$out2 = "$name"."_chr3_table.txt";
		$out3 = "$name"."_chr4_group1_table.txt";
		$out4 = "$name"."_chr4_group2_table.txt";
		$out5 = "$name"."_chr4_group3_table.txt";
		$out6 = "$name"."_chr4_group4_table.txt";	
		$out7 = "$name"."_chr4_group5_table.txt";
	}elsif($name =~ m/Xchr/){
		$out8 = "$name"."_chrXL_group1a_table.txt";
		$out9 = "$name"."_chrXL_group1e_table.txt";
		$out10 = "$name"."_chrXL_group3a_table.txt";
		$out11 = "$name"."_chrXL_group3b_table.txt";
		$out12 = "$name"."_chrXR_group3a_table.txt";
		$out13 = "$name"."_chrXR_group5_table.txt";
		$out14 = "$name"."_chrXR_group6_table.txt";
		$out15 = "$name"."_chrXR_group8_table.txt";
	}else{
		$out = "$name"."_chr2_table.txt";
		$out2 = "$name"."_chr3_table.txt";
		$out3 = "$name"."_chr4_group1_table.txt";
		$out4 = "$name"."_chr4_group2_table.txt";
		$out5 = "$name"."_chr4_group3_table.txt";
		$out6 = "$name"."_chr4_group4_table.txt";
		$out7 = "$name"."_chr4_group5_table.txt";
		$out8 = "$name"."_chrXL_group1a_table.txt";
		$out9 = "$name"."_chrXL_group1e_table.txt";
		$out10 = "$name"."_chrXL_group3a_table.txt";
		$out11 = "$name"."_chrXL_group3b_table.txt";
		$out12 = "$name"."_chrXR_group3a_table.txt";
		$out13 = "$name"."_chrXR_group5_table.txt";
		$out14 = "$name"."_chrXR_group6_table.txt";
		$out15 = "$name"."_chrXR_group8_table.txt";
	}

	open (OUT, ">$out");
	open (OUT2, ">$out2");
	open (OUT3, ">$out3");
	open (OUT4, ">$out4");
	open (OUT5, ">$out5");
	open (OUT6, ">$out6");
	open (OUT7, ">$out7");
	open (OUT8, ">$out8");
	open (OUT9, ">$out9");
	open (OUT10, ">$out10");
	open (OUT11, ">$out11");
	open (OUT12, ">$out12");
	open (OUT13, ">$out13");
	open (OUT14, ">$out14");
	open (OUT15, ">$out15");
	
	my $header = <IN>;
	print "Header : $header\n";
	print OUT "$header";
	print OUT2 "$header";
	print OUT3 "$header";
	print OUT4 "$header";
	print OUT5 "$header";
	print OUT6 "$header";
	print OUT7 "$header";
	print OUT8 "$header";
	print OUT9 "$header";
	print OUT10 "$header";
	print OUT11 "$header";
	print OUT12 "$header";
	print OUT13 "$header";
	print OUT14 "$header";
	print OUT15 "$header";
	
	while (<IN>){
		chomp();
		my $line = $_;
		if ($line =~ m/(\w+)\s.*/){
			my $chr = $1;
			if ($chr eq 2){
				print OUT "$line\n";
			}
			elsif ($chr eq 3){
                	        print OUT2 "$line\n";
                	}
			elsif ($chr eq "4_group1"){
				print OUT3 "$line\n";
			}
			elsif ($chr eq "4_group2"){
                	        print OUT4 "$line\n";
                	}
			elsif ($chr eq "4_group3"){
                	        print OUT5 "$line\n";
                	}
			elsif ($chr eq "4_group4"){
                	        print OUT6 "$line\n";
                	}
			elsif ($chr eq "4_group5"){
                	        print OUT7 "$line\n";
                	}
			elsif ($chr eq "XL_group1a"){
                	        print OUT8 "$line\n";
                	}
			elsif ($chr eq "XL_group1e"){
                	        print OUT9 "$line\n";
                	}
			elsif ($chr eq "XL_group3a"){
                	        print OUT10 "$line\n";
                	}
			elsif ($chr eq "XL_group3b"){
                	        print OUT11 "$line\n";
                	}
			elsif ($chr eq "XR_group3a"){
                	        print OUT12 "$line\n";
                	}
			elsif ($chr eq "XR_group5"){
                	        print OUT13 "$line\n";
                	}
			elsif ($chr eq "XR_group6"){
                	        print OUT14 "$line\n";
                	}
			elsif ($chr eq "XR_group8"){
                	        print OUT15 "$line\n";
                	}
			else{
				print "Can't find the right file for $1\n";
				next;
			}
		}	
		else{
			next;
		}
	}
	print "Done splitting $input by chromosomes\n";
}
exit;
