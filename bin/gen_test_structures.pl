#!/usr/bin/env perl

use lib "../lib";
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules";
use lib "/software/pathogen/internal/prod/lib";

use Storable;
use Data::Dumper;

my @v = (
	{
		path   => "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCTRL1/SLX/TyCTRL1_5521546/8086_1#1",
		ref    => "Salmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1",
		mapper => "smalt",
		date   => "11-07-2013"
	},
	{
		path   => "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCTRL2/SLX/TyCTRL2_5521547/8086_1#2",
		ref    => "Salmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1",
		mapper => "smalt",
		date   => "25-06-2013"
	},
	{
		path   => "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCPI1/SLX/TyCPI1_5521548/8086_1#3",
		ref    => "Salmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1",
		mapper => "smalt",
		date   => "25-06-2013"
	}
);
store \@v, 'verbose.store';

my @d = (
	{
		path   => "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCTRL1/SLX/TyCTRL1_5521546/8086_1#1",
		ref    => "Salmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1",
		mapper => "smalt",
		date   => "11-07-2013"
	}
);
store \@d, 'date_filter.store';

