#!/usr/bin/env perl

use strict;
use warnings;

use English     qw/ -no_match_vars /;
use List::Util  qw/ sum            /;
use Path::Class;

# Extract the data from the file
my $input_file = file( 'results_dom.csv' );
my @data = map {
	my $line = $ARG;
	# Strip any newline chars off the end
	while ( chomp( $line ) ) {}
	[
		# split into parts and tidy up
		map {
			$ARG =~ s/[\-\/]/_/g;
			$ARG =~ s/crh_greedy/naive_greedy/g;
			lc( $ARG );
		} split( /,/, $line )
	];
} grep {
	# Remove header lines
	$ARG !~ /^\s*#/;
} $input_file->slurp();

# Foreach line, store a line under the name
my %lines_of_name;
my %values_by_class;
foreach my $datum ( @data ) {
	my ( $name, $class, $a, $b ) = @$datum;
	push @{ $lines_of_name{ $name } }, join( ' ', ( $class, $b, $a, uc( $name ), $class ) );
	push @{ $values_by_class{ $class }->[ 0 ] }, $a;
	push @{ $values_by_class{ $class }->[ 1 ] }, $b;
}

# Calculate and print the averages for each class
my @class_averages = map {
	my $class  = $ARG;
	my $values = $values_by_class{ $class };
	[
		$class,
		map {
			my @data = @$ARG;
			sum( @data ) / scalar( @data );
		} @$values
	];
} sort { $a <=> $b } keys( %values_by_class );
print join( '', map { join( ' ', @$ARG ) . "\n"; } @class_averages );

# Output each name's lines in a file storing the name
foreach my $name ( sort( keys( %lines_of_name ) ) ) {
	file( 'benchmark.' . lc( $name ) . '_data.txt' )->spew( join( '', map { "$ARG\n"; } @{ $lines_of_name{ $name } } ) );
}
