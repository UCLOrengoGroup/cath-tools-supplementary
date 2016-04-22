#!/usr/bin/env perl

use strict;
use warnings;

use Carp                       qw/ confess        /;
use Data::Dumper;
use English                    qw/ -no_match_vars /;
use feature                    qw/ say            /;
use Path::Class                qw/ dir file       /;
use List::Util                 qw/ sum            /;

if ( scalar( @ARGV ) != 1 ) {
	confess "Usage: $PROGRAM_NAME input_file\nwhere input file contains columns: score zero_or_one_label";
}
my $input_filename = $ARGV[ 0 ];
my $input_file = file( $input_filename );

if ( ! -s $input_file ) {
	confess "No such non-empty file $input_file exists";
}

my @lines = $input_file->slurp();
while (chomp(@lines)) {}

@lines = map { [ split( /\s+/, $ARG ) ] } @lines;
@lines = sort { $b->[ 0 ] <=> $a->[ 0 ] } @lines;
# confess Dumper( \@lines );

if ( scalar( @lines ) == 0 ) {
	confess "Need at least two lines in file";
}

my $total_positives = sum( map { $ARG->[ 1 ] > 0 } @lines );
my $total_negatives = scalar( @lines ) - $total_positives;

my $false_positives = 0;
my $true_positives  = 0;
my $prev_score = undef;
my @roc_results;
my @prec_rec_results;

# confess Dumper( [ $total_positives, $total_negatives ] );

foreach my $ctr ( 0 .. scalar( @lines ) - 1 ) {
	my ( $score, $label ) = @{ $lines[ $ctr ] };

	if ( $label	 > 0 ) {
		++$true_positives;
	}
	else {
		++$false_positives
	}

	if ( $ctr >= scalar( @lines ) - 1 || $lines[ $ctr + 1 ]->[ 0 ] != $score ) {
		push @roc_results,      [ 100.0 * $false_positives / $total_negatives, 100.0 * $true_positives /   $total_positives                     ];
		push @prec_rec_results, [ 100.0 * $true_positives  / $total_positives, 100.0 * $true_positives / ( $true_positives + $false_positives ) ];
	}
}

file( $input_filename . '.roc'      )->spew( join("\n", map {join "\t", @$ARG} @roc_results      )."\n" );
file( $input_filename . '.prec_rec' )->spew( join("\n", map {join "\t", @$ARG} @prec_rec_results )."\n" );
