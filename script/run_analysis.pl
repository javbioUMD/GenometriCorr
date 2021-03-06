#!/usr/bin/env perl

use strict;
use warnings;

my $usage = "Usage: $0 <a.bed> <b.bed>\n";
my $a = shift or die $usage;
my $b = shift or die $usage;

my $base = $a . '_' . $b;
$base =~ s/\./\_/g;

my $time = time;
my $outfile = $time . '.R';
open(OUT, '>', $outfile) || die "Could not open $outfile for writing: $!\n";

print OUT <<EOF;
#load packages
library('GenometriCorr')
library("rtracklayer")

#define hg19
human.chrom.length <- c(249250621, 243199373, 198022430, 191154276, 180915260, 171115067,
                        159138663, 146364022, 141213431, 135534747,135006516, 133851895,
                        115169878, 107349540, 102531392, 90354753, 81195210, 78077248,
                        59128983, 63025520, 48129895, 51304566, 59373566, 155270560)

#define hg38
human.chrom.length <- c(248956422,242193529,198295559,190214555,181538259,170805979,
                        159345973,145138636,138394717,133797422,135086622,133275309,
                        114364328,107043718,101991189,90338345,83257441,80373285,
                        58617616,64444167,46709983,50818468,57227415,156040895)

names(human.chrom.length) <- c("chr1", "chr2", "chr3", "chr4", "chr5", "chr6",
                               "chr7", "chr8", "chr9", "chr10", "chr11", "chr12",
                               "chr13", "chr14", "chr15", "chr16", "chr17", "chr18",
                               "chr19", "chr20", "chr21", "chr22", "chrY", "chrX")

my_chr <- c("chr1", "chr2", "chr3", "chr4", "chr5", "chr6",
            "chr7", "chr8", "chr9", "chr10", "chr11", "chr12",
            "chr13", "chr14", "chr15", "chr16", "chr17", "chr18",
            "chr19", "chr20", "chr21", "chr22", "chrY", "chrX")

pn.area <- 100
pn.dist <- 100
pn.jacc <- 100

a <- as(import('$a'),"RangedData")
b <- as(import('$b'), "RangedData")

a_vs_b <- GenometriCorrelation(a, b, chromosomes.length = human.chrom.length,
                               #chromosomes.to.proceed = c("chr1", "chr2", "chr3"),
                               chromosomes.to.proceed = my_chr,
                               ecdf.area.permut.number = pn.area,
                               mean.distance.permut.number = pn.dist,
                               jaccard.measure.permut.number = pn.jacc,
                               keep.distributions = TRUE, showProgressBar = TRUE)

sink('$base.out')
a_vs_b
sink()

graphical.report(a_vs_b, pdffile = "${base}_dist.pdf", show.chromosomes = c("chr1"), show.all = FALSE)
visualize(a_vs_b, pdffile = "${base}_overlap.pdf", show.chromosomes = c("chr1"), show.all = FALSE)
q()
EOF

close(OUT);

system("R --no-save < $outfile");

unlink($outfile);

warn("Done\n");

exit(0);
