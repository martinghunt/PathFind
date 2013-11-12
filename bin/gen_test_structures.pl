#!/usr/bin/env perl

use lib "../lib";
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules";
use lib "/software/pathogen/internal/prod/lib";

use Storable;
use Data::Dumper;

my $fq_s = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/TL266/SLX/TL266_1728612/5749_8#1/5749_8#1_1.fastq.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/TL266/SLX/TL266_1728612/5749_8#1/5749_8#1_2.fastq.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/2950/SLX/2950_1728613/5749_8#2/5749_8#2_1.fastq.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/2950/SLX/2950_1728613/5749_8#2/5749_8#2_2.fastq.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/3507/SLX/3507_1728614/5749_8#3/5749_8#3_1.fastq.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/3507/SLX/3507_1728614/5749_8#3/5749_8#3_2.fastq.gz";
my @fq = split(/\s+/, $fq_s);
my @new_fq = add_path(\@fq);
print "FASTQS:\n";
print Dumper \@new_fq;
store \@new_fq, 'fastq_lanes.store';

my $bm_s = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mycobacterium/microti/TRACKING/499/OV254/SLX/OV254_247838/4880_8#1/111360.pe.markdup.bam
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mycobacterium/microti/TRACKING/499/ATCC35782/SLX/ATCC35782_247839/4880_8#2/111363.pe.markdup.bam
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mycobacterium/microti/TRACKING/499/MausIII/SLX/MausIII_247840/4880_8#3/111366.pe.markdup.bam";
my @bm = split(/\s+/, $bm_s);
my @new_bm = add_path(\@bm);
print "BAMS:\n";
print Dumper \@new_bm;
store \@new_bm, 'bam_lanes.store';

sub add_path {
	my $paths = shift;
	my @hashes;
	foreach my $p (@$paths){
		chomp $p;
		push(@hashes, {path => $p});
	}
	return @hashes;
}
