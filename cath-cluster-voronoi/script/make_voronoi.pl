#!/usr/bin/env perl

# mkdir extlib
# cpanm -L extlib Capture::Tiny
# cpanm -L extlib Chart::Gnuplot
# cpanm -L extlib Color::Mix
# cpanm -L extlib Log::Log4perl::Tiny
# cpanm -L extlib Math::Geometry::Voronoi
# cpanm -L extlib Math::Random::MT::Perl
# cpanm -L extlib Math::Random::MT
# cpanm -L extlib Path::Tiny

# script/make_voronoi.pl

# convert -background white -alpha off -trim -density 1200 -quality 100 -resize 50% voronoi.eps voronoi.jpg

use strict;
use warnings;

# Core
use English     qw/ -no_match_vars /;
use Storable    qw/ dclone         /;
use List::Util  qw/ first uniq     /;
use FindBin;
use Path::Tiny;

use lib "$FindBin::Bin/../extlib/lib/perl5";

# Non-core (local)
use Capture::Tiny       qw/ capture     /;
use Chart::Gnuplot;
use Color::Mix;
use List::MoreUtils     qw/ first_index /;
use Log::Log4perl::Tiny qw/ :easy       /;
use Math::Geometry::Voronoi;
use Math::Random::MT;

my $cath_cluster_exe = '/cath-tools/ninja_clang_debug_shared/cath-cluster';

my $num_points       =   60;
# my $num_points       =  100;
# my $num_points       =  500;
# my $num_points       = 1200;
# my $num_points       = 3000;

main();

use Data::Dumper;

sub main {
	# Initialise random number seed (or specify a specific number to make reproducible)
	my $rng = Math::Random::MT->new();

	# Make some random points
	my @points = map { [ $rng->rand( 1.5 ) - 0.25,
	                     $rng->rand( 1.5 ) - 0.25 ]; } ( 1..$num_points );

	# Get cluster data for the points
	my $cluster_data = get_cluster_data_of_points( \@points );
	my ( $spans, $clust_of_point_idx ) = @$cluster_data;

	# Get a list of the cluster numbers
	my @clusters = uniq( sort { $a <=> $b } @$clust_of_point_idx );

	# load a set of points
	my $voronoi = Math::Geometry::Voronoi->new( points => dclone( [ @points ] ) );

	# Compute the Voronoi tessellation
	$voronoi->compute;

	# Get a mapping from the $voronoi's points index to the original index
	my @point_index_of_voronoi_index = map {
		my $voronoi_index = $ARG;
		my $index = first_index { @$ARG ~~ @{ $voronoi->points()->[ $voronoi_index ] } } @points;
		$index;
	} ( 0 .. $#points );

	# Get the pairs of indices for the pairs of neighbouring points
	my @connected_point_pairs = map {
		my ( $a, $b, $c, $voronoi_index1, $voronoi_index2 ) = @$ARG;
		my $index1 = $point_index_of_voronoi_index[ $voronoi_index1 ];
		my $index2 = $point_index_of_voronoi_index[ $voronoi_index2 ];
		[ $index1, $index2 ];
	} @{ $voronoi->lines() };

	# Calculate the pairs of connected clusters
	my %connected_clusters;
	foreach my $connected_point_pair ( @connected_point_pairs ) {
		my @connected_clusts_pair = map { $clust_of_point_idx->[ $ARG ]; } @$connected_point_pair;
		$connected_clusters{ $connected_clusts_pair[ 0 ] }->{ $connected_clusts_pair[ 1 ] } = 1;
		$connected_clusters{ $connected_clusts_pair[ 1 ] }->{ $connected_clusts_pair[ 0 ] } = 1;
	}

	# A hash from cluster index to colour index
	my %colour_index_of_cluster;

	# A subroutine for calculating the indices of the clusters that are
	# coloured and connected to the cluster with the specified index
	my $coloured_connected_clusters_of_cluster = sub {
		my $cluster = shift;
		my @connections = sort { $a <=> $b } keys( %{ $connected_clusters{ $cluster } } );
		return [
			grep {
				exists( $colour_index_of_cluster{ $ARG } );
			} @connections
		];
	};

	# While not all clusters have been assigned a colour
	while ( scalar( keys( %colour_index_of_cluster ) ) < scalar( @clusters ) ) {
		# Rank all not-yet-coloured clusters in descending order of number of adjacent coloured clusters
		my @cluster_pref = sort {
			scalar( @{ $coloured_connected_clusters_of_cluster->( $b ) } )
			<=>
			scalar( @{ $coloured_connected_clusters_of_cluster->( $a ) } )
			or
			$a <=> $b
		}
		grep {
			! exists( $colour_index_of_cluster{ $ARG } )
		} @clusters;

		# Grab (one of) the not-yet-coloured cluster(s) with the most adjacent coloured clusters
		my $cluster = $cluster_pref[ 0 ];

		# Get the colours already used by this cluster's adjacent coloured clusters
		my %used_colour_indices = map {
			( $colour_index_of_cluster{ $ARG }, 1 );
		} @{ $coloured_connected_clusters_of_cluster->( $cluster ) };

		# Choose the first index that isn't already used by the adjacent coloured clusters and store it
		my $colour_index = first { ! exists( $used_colour_indices{ $ARG } ) } ( 0 .. scalar( keys( %used_colour_indices ) ) );
		$colour_index_of_cluster{ $cluster } = $colour_index;
	}

	# Build a map from point index to colour
	my @colours = ( qw/ blue red orange green purple green yellow black / );
	my @colour_of_point_index = map {
		$colours[ $colour_index_of_cluster{ $clust_of_point_idx->[ $ARG ] } ];
	} ( 0 .. $#points );

	# Create chart object and specify the properties of the chart
	my $chart = Chart::Gnuplot->new(
		bmargin   => 0,
		imagesize => '5.0,5.0',
		lmargin   => 0,
		output    => 'voronoi.eps',
		rmargin   => 0,
		size      => 'square',
		terminal  => 'eps',
		tmargin   => 0,
		xrange    => [ 0, 1 ],
		xtics     => undef,
		yrange    => [ 0, 1 ],
		ytics     => undef,
	);

	# Store the points by the colour of their cluster
	my %points_by_color;
	foreach my $point_index ( 0 .. $#points ) {
		push @{ $points_by_color{ $colour_of_point_index[ $point_index ] } }, $points[ $point_index ];
	}

	# Draw polygons for each of the points
	my $colour_mix = Color::Mix->new;
	foreach my $polygon ( $voronoi->polygons() ) {
		my $voronoi_point_index = shift @$polygon;
		my $point_index         = $point_index_of_voronoi_index[ $voronoi_point_index ];
		my $raw_colour          = $colour_of_point_index[ $point_index ];
		push @$polygon, $polygon->[ 0 ];
		$chart->polygon(
			vertices => [
				map { join( ', ', @$ARG ); } @$polygon
			],
			fill => {
				color => '#' . $colour_mix->lighten( $raw_colour, 6.5 ),
			},
		);
	}

	# Draw the lines of the clusters' spanning trees
	foreach my $span ( @$spans ) {
		my @local_points = map { $points[ $ARG ]; } @$span;
		$chart->line(
			width    => 2,
			color    => $colour_of_point_index[ $span->[ 0 ] ],
			from     => join( ',', @{ $local_points[  0 ] } ),
			to       => join( ',', @{ $local_points[ -1 ] } ),
		);
	}

	# For each colour, plot a dataset object the points in that colour
	$chart->plot2d(
		map {
			my $colour = $ARG;
			my $points_of_colour = $points_by_color{ $colour };
			Chart::Gnuplot::DataSet->new(
				color     => '#' . $colour_mix->darken( $colour, 4 ),
				pointsize => 0.3,
				pointtype => 7,
				style     => "points",
				xdata     => [ map { $ARG->[ 0 ] } @$points_of_colour ],
				ydata     => [ map { $ARG->[ 1 ] } @$points_of_colour ],
			);
		} sort( keys( %points_by_color ) )
	);
}

=head2 get_cluster_data_of_points

Call cath-cluster on the distances between the specified points and return:
 * pairs of points in the cluster spanning trees and
 * the cluster number corresponding to each point

=cut

sub get_cluster_data_of_points {
	my $points = shift;
	my $links_tempfile = Path::Tiny->tempfile();
	my $names_tempfile = Path::Tiny->tempfile();
	my $spans_tempfile = Path::Tiny->tempfile();
	my $clust_tempfile = Path::Tiny->tempfile();

	# Write the half-all-vs-all matrix of distances between the points
	$links_tempfile->spew(
		join (
			'',
			map {
				my $index_a = $ARG;
				my $point_a = $points->[ $index_a ];
				join(
					'',
					map {
						my $index_b = $ARG;
						my $point_b = $points->[ $index_b ];
						join( ' ', $index_a, $index_b, point_distance( $point_a, $point_b ), '100' ) . "\n";
					} ( $index_a + 1 .. $#$points )
				);
			} ( 0 .. $#$points )
		)
	);

	# Write the names
	$names_tempfile->spew(
		map {
			$ARG . ' ' . $ARG . "\n";
		} ( 0 .. $#$points )
	);

	# Call cath-cluster
	my @cluster_command = (
		$cath_cluster_exe,
		'--links-infile',        "$links_tempfile",
		'--names-infile',        "$names_tempfile",
		'--clust-spans-to-file', "$spans_tempfile",
		'--clusters-to-file',    "$clust_tempfile",
	);
	WARN 'Executing command ' . join( ' ', @cluster_command );
	my ( $cluster_stdout, $cluster_stderr, $cluster_exit ) = capture {
		system @cluster_command;
	};

	# Grab the spans lines
	my $spans_data = $spans_tempfile->slurp();
	my @spans_lines = split( /\n+/, $spans_data );
	while ( chomp( @spans_lines ) ) {}

	# Grab the clusters lines
	my $clust_data = $clust_tempfile->slurp();
	my @clust_lines = split( /\n+/, $clust_data );
	while ( chomp( @clust_lines ) ) {}

	# Process the data
	my @spans_pairs       = map { [   split( /\s+/, $ARG )           ]; } @spans_lines;
	my @entry_clust_pairs = map { [ ( split( /\s+/, $ARG ) )[ 0, 1 ] ]; } @clust_lines;

	my @clust_of_point_idx;
	foreach my $entry_clust_pair ( @entry_clust_pairs ) {
		my ( $entry, $clust ) = @$entry_clust_pair;
		@clust_of_point_idx[ $entry ] = $clust;
	}

	return [ \@spans_pairs, \@clust_of_point_idx ];
}

=head2 point_distance

Return the distance between the two specified points

Eg `point_distance( [ 3, 8 ], [ 4, 9 ] )` returns `sqrt( 2 )`

=cut

sub point_distance {
	my $point_a     = shift;
	my $point_b     = shift;
	my ( $ax, $ay ) = @$point_a;
	my ( $bx, $by ) = @$point_b;
	my $x           = $ax - $bx;
	my $y           = $ay - $by;
	return sqrt( $x * $x + $y * $y );
}
