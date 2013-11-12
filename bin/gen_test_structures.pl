#!/usr/bin/env perl

use lib "../lib";
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules";
use lib "/software/pathogen/internal/prod/lib";

use Storable;
use Data::Dumper;

my @fastq_paths = ("/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mycobacterium/microti/TRACKING/499/OV254/SLX/OV254_247838/4880_8#1/111360.pe.markdup.bam",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mycobacterium/microti/TRACKING/499/ATCC35782/SLX/ATCC35782_247839/4880_8#2/111363.pe.markdup.bam",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mycobacterium/microti/TRACKING/499/MausIII/SLX/MausIII_247840/4880_8#3/111366.pe.markdup.bam",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mycobacterium/microti/TRACKING/499/MausIV/SLX/MausIV_247841/4880_8#4/111369.pe.markdup.bam",
"/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mycobacterium/microti/TRACKING/499/942272/SLX/942272_247842/4880_8#5/111375.pe.markdup.bam",
);

store \@fastq_lanes, 'bam_lanes.store';

