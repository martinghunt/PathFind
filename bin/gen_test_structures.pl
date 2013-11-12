#!/usr/bin/env perl

use lib "../lib";
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules";
use lib "/software/pathogen/internal/prod/lib";

use Path::Find;
use Storable;
use Data::Dumper;

my ( $pathtrack, $dbh, $root ) = Path::Find->get_db_info('pathogen_prok_track');

my @fastq_lanes =
  ( '5749_8#1', '5749_8#2', '5749_8#3', '5749_8#4', '5749_8#5', '5749_8#6' );
my @fastq_paths = (
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/TL266/SLX/TL266_1728612/5749_8#1/5749_8#1_1.fastq.gz",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/TL266/SLX/TL266_1728612/5749_8#1/5749_8#1_2.fastq.gz",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/2950/SLX/2950_1728613/5749_8#2/5749_8#2_1.fastq.gz",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/2950/SLX/2950_1728613/5749_8#2/5749_8#2_2.fastq.gz",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/3507/SLX/3507_1728614/5749_8#3/5749_8#3_1.fastq.gz",
"lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Blautia/producta/TRACKING/1707/3507/SLX/3507_1728614/5749_8#3/5749_8#3_2.fastq.gz",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Chlamydophila/pneumoniae/TRACKING/1707/straina/SLX/straina_1728615/5749_8#4/5749_8#4_1.fastq.gz",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Chlamydophila/pneumoniae/TRACKING/1707/straina/SLX/straina_1728615/5749_8#4/5749_8#4_2.fastq.gz",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/bongori/TRACKING/1707/46082A21/SLX/46082A21_1728616/5749_8#5/5749_8#5_1.fastq.gz",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/bongori/TRACKING/1707/46082A21/SLX/46082A21_1728616/5749_8#5/5749_8#5_2.fastq.gz",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/bongori/TRACKING/1707/46082E21/SLX/46082E21_1728617/5749_8#6/5749_8#6_1.fastq.gz",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/bongori/TRACKING/1707/46082E21/SLX/46082E21_1728617/5749_8#6/5749_8#6_2.fastq.gz"
);

store \@fastq_lanes, 'fastq_lanes.store';

