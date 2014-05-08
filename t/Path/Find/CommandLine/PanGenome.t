# #!/usr/bin/env perl
# use Moose;
# use Data::Dumper;
# use File::Slurp;
# use File::Path qw( remove_tree);
# use Cwd;
# use File::Temp;

# BEGIN { unshift( @INC, './lib' ) }

# BEGIN {
#     use Test::Most;
#     use Test::Output;
#     use_ok('Path::Find::CommandLine::PanGenome');
# }
# my $script_name = 'Path::Find::CommandLine::PanGenome';
# my $cwd = getcwd();

# my $destination_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
# my $destination_directory = $destination_directory_obj->dirname();

# my (@args, $exp_out, $pang_obj);

# # test file parse
# @args = ("-t", "file", "-i", "t/data/pangenome/pangenome_lanes.txt");

# ok($pang_obj = Path::Find::CommandLine::PanGenome->new(args => \@args, script_name => $script_name), 'initialise object');
# is($pang_obj->_create_pan_genome_cmd, 'create_pan_genome --output_multifasta_files --job_runner LSF --perc_identity 98 *.gff', 'create pan genome command correctly generated');

# @args = ("-t", "file", "-i", "t/data/pangenome/pangenome_lanes.txt", "t/data/pangenome/empty_annotation_file.gff");
# my $dummy_pan_genome_cmd = $cwd.'/t/bin/dummy_create_pan_genome';
# ok(my $pang_dummy_obj = Path::Find::CommandLine::PanGenome->new(args => \@args, 
#   script_name => $script_name, 
#   _create_pan_genome_cmd => $dummy_pan_genome_cmd), 'initialise object with dummy create_pan_genome');
# ok($pang_dummy_obj->run, 'run the full script');
# ok(-e 'output_file_t_data_pangenome_pangenome_lanes_txt/pan_genome_results', 'the script got run');
# ok(-e 'output_file_t_data_pangenome_pangenome_lanes_txt/9852_1#81.gff', 'db gff symlink created');
# ok(-e 'output_file_t_data_pangenome_pangenome_lanes_txt/9802_1#66.gff', 'db gff symlink created');
# ok(-e 'output_file_t_data_pangenome_pangenome_lanes_txt/9716_4#9.gff', 'db gff symlink created');
# ok(-e 'output_file_t_data_pangenome_pangenome_lanes_txt/empty_annotation_file.gff', 'user gff symlink created');

# remove_tree('output_file_t_data_pangenome_pangenome_lanes_txt');

# done_testing();

