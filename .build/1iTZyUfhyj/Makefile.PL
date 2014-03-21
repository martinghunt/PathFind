
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Simple wrapper module for VRTrack and DBI. Used for connecting to pathogen tracking databases.",
  "AUTHOR" => "Carla Cummins <cc21\@sanger.ac.uk>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "PathFind",
  "EXE_FILES" => [
    "bin/accessionfind",
    "bin/annotationfind",
    "bin/assemblyfind",
    "bin/bacteria_pan_genome",
    "bin/infofind",
    "bin/mapfind",
    "bin/pathfind",
    "bin/plexfind",
    "bin/reffind",
    "bin/rnaseqfind",
    "bin/snpfind",
    "bin/tradisfind"
  ],
  "LICENSE" => "gpl",
  "NAME" => "PathFind",
  "PREREQ_PM" => {
    "Bio::AutomatedAnnotation::ParseGenesFromGFFs" => 0,
    "Bio::MLST::Databases" => 0,
    "Carp" => 0,
    "Cwd" => 0,
    "DBI" => 0,
    "Data::Dumper" => 0,
    "Exception::Class" => 0,
    "File::Basename" => 0,
    "File::Copy" => 0,
    "File::Path" => 0,
    "File::Slurp" => 0,
    "File::Spec" => 0,
    "File::Temp" => 0,
    "File::chdir" => 0,
    "Getopt::Long" => 0,
    "Moose" => 0,
    "Pathogens::Reports::Mapping::Report" => 0,
    "Storable" => 0,
    "Text::CSV" => 0,
    "VRTrack::Individual" => 0,
    "VRTrack::Lane" => 0,
    "VRTrack::VRTrack" => 0,
    "VertRes::Parser::bamcheck" => 0,
    "VertRes::Utils::VRTrackFactory" => 0,
    "WWW::Mechanize" => 0,
    "YAML::XS" => 0,
    "lib" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "Env::Path" => 0,
    "Test::Exception" => 0,
    "Test::Most" => 0,
    "Test::Output" => 0
  },
  "VERSION" => "1.140790",
  "test" => {
    "TESTS" => "t/*.t t/Path/*.t t/Path/Find/*.t t/Path/Find/CommandLine/*.t"
  }
);


my %FallbackPrereqs = (
  "Bio::AutomatedAnnotation::ParseGenesFromGFFs" => 0,
  "Bio::MLST::Databases" => 0,
  "Carp" => 0,
  "Cwd" => 0,
  "DBI" => 0,
  "Data::Dumper" => 0,
  "Env::Path" => 0,
  "Exception::Class" => 0,
  "File::Basename" => 0,
  "File::Copy" => 0,
  "File::Path" => 0,
  "File::Slurp" => 0,
  "File::Spec" => 0,
  "File::Temp" => 0,
  "File::chdir" => 0,
  "Getopt::Long" => 0,
  "Moose" => 0,
  "Pathogens::Reports::Mapping::Report" => 0,
  "Storable" => 0,
  "Test::Exception" => 0,
  "Test::Most" => 0,
  "Test::Output" => 0,
  "Text::CSV" => 0,
  "VRTrack::Individual" => 0,
  "VRTrack::Lane" => 0,
  "VRTrack::VRTrack" => 0,
  "VertRes::Parser::bamcheck" => 0,
  "VertRes::Utils::VRTrackFactory" => 0,
  "WWW::Mechanize" => 0,
  "YAML::XS" => 0,
  "lib" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



