#!/usr/bin/env perl

use strict;
use warnings;

use Carp              qw/ confess        /;
use Data::Dumper;
use English           qw/ -no_match_vars /;
use feature           qw/ say            /;
use IPC::Run3;
use List::Util        qw/ shuffle        /;
use Path::Class       qw/ dir file       /;

# use Getopt::Long;
# use List::Util                 qw/ max maxstr min minstr                /;
# use Math::Random::MT;
# use Moose;
# use MooseX::Params::Validate;
# use MooseX::Types::Path::Class qw/ Dir File                             /;
# use Params::Util               qw/_INSTANCE _ARRAY _ARRAY0 _HASH _HASH0 /;

my $total_num_lines  = 263312; # = 2^4 * 7 * 2351 ( so some factors include: 8, 14, 16, 28, 56)
# my $num_parts        =     51;
# my $num_repeats      =    100;
# my $num_parts        =      5;
# my $num_repeats      =      2;
my $num_parts        =     29;
my $num_repeats      =    100;

my $root_dir         = dir ( '', 'dev', 'shm', 'compare_crh_df3_cpu_and_mem_usage_dir'  );
my $src_data_dir     = dir ( '', 'cath-tools', 'resolve_stuff', 'for_tony'              );

my $crh_pre_options  = [            ];
my $df3_pre_options  = [ '--indata' ];
my $crh_post_options = [ '--output-file' ];
my $df3_post_options = [ '--out'         ];

my $crh_src_exe      = file( '', 'cath-tools', 'ninja_gcc_release', 'cath-resolve-hits' );
my $df3_src_exe      = file( '', 'cath-tools', 'resolve_stuff', 'df3', 'DomainFinder3'  );
my $crh_src_data     = $src_data_dir->file( 'titin.crh' );
my $df3_src_data     = $src_data_dir->file( 'titin.ssf' );

my $crh_exe          = $root_dir->file( $crh_src_exe ->basename() );
my $df3_exe          = $root_dir->file( $df3_src_exe ->basename() );
my $crh_data         = $root_dir->file( $crh_src_data->basename() );
my $df3_data         = $root_dir->file( $df3_src_data->basename() );

if ( ! -d $root_dir ) {
	$root_dir->mkpath()
		or confess "Cannot create $root_dir : $OS_ERROR";
}

$crh_src_exe->copy_to( $crh_exe ) or confess "Cannot copy $crh_src_exe to $crh_exe : $OS_ERROR";
$df3_src_exe->copy_to( $df3_exe ) or confess "Cannot copy $df3_src_exe to $df3_exe : $OS_ERROR";

foreach my $algo_data (
                        # [ 'CRH', $crh_exe, $crh_src_data, $crh_data, $crh_pre_options, $crh_post_options ],
                        [ 'DF3', $df3_exe, $df3_src_data, $df3_data, $df3_pre_options, $df3_post_options ],
                                                                                                           ) {
	my ( $name, $exe, $src_data, $data, $pre_options, $post_options ) = @$algo_data;
	# confess Dumper( [ $name, $exe, $src_data, $data ] ) . ' ';


	foreach my $part_ctr ( 0 .. ( $num_parts - 1 ) ) {
		my $fraction_aim = $part_ctr / ( $num_parts - 1 );
		my $num_lines    = int( $total_num_lines * $fraction_aim );
		my $fraction     = $num_lines / $total_num_lines;
		if ( $fraction == 0 ) {
			next;
		}
		if ( $num_lines <= 65828 ) {
			next;
		}
		my $time   = 0.0;
		my $memory = 0.0;

		foreach my $repeat_ctr ( 1 .. $num_repeats ) {
			# $num_lines * $num_lines;
			file_subset_copy( $src_data, $data, $num_lines );

			my $output_file = $root_dir->file( 'dummy' );
			if ( -e $output_file ) {
				$output_file->remove()
					or confess "Unable to remove dummy output file \"$output_file\" : $OS_ERROR";
			}

			my $command = [
				'/usr/bin/time',
				'--format',
				'user-seconds:%U max-size-kilobytes:%M',
				"$exe",
				@$pre_options,
				"$data",
				@$post_options,
				"$output_file",
			];

			# say join( " ", @$command );
			my ( $stdout, $stderr );
			run3(
				$command,
				undef,
				\$stdout,
				\$stderr,
			);
			if ( ! -s $output_file ) {
				undef $time;
				undef $memory;
				last;
			}
			# confess Dumper( [ $command, $stdout, $stderr ] ) . ' ';
			if ( $stderr =~ /user-seconds:([\.\d]+) max-size-kilobytes:(\d+)\s*$/ ) {
				$time += $1;
				$memory += $2;
			}
			else {
				confess "Couldn't parse /usr/bin/time stderr : $stderr\n";
			}
		}
		if ( defined( $time ) && defined( $memory ) ) {
			$time   /= $num_repeats;
			$time   /= $num_lines;
			$time   *= 100000;
			$time   /= 60;      # Convert from seconds to minutes
			$memory /= $num_repeats;
			$memory /= $num_lines;
			$memory *= 100000;  # To perform 100k entries
			$memory /= 1000000; # From Kb to Gb
			say "$name $num_lines $time $memory # Columns: algorithm name; num input entries; time in minutes per 100k entries; memory in seconds per 100k entries."
		}
	}
}

sub file_subset_copy {
	my $source_file = shift;
	my $dest_file   = shift;
	my $num_lines   = shift;

	my @lines = $source_file->slurp();
	while ( chomp( @lines ) ) {}
	@lines = shuffle( @lines );
	splice( @lines, $num_lines);
	$dest_file->spew( join( "\n", @lines ) . "\n" );
}
