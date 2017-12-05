#!/usr/bin/env perl

=head1 USAGE

setenv PDBDIR $PWD
setenv CATH_TOOLS_PDB_PATH $PWD
singledelta -test=test_script.pl 2a50 -in_place

=cut

# Strict / warnings
use warnings;
use strict;

# Core
use Carp              qw/ confess        /;
use Cwd               qw/ cwd            /;
use Data::Dumper;
use English           qw/ -no_match_vars /;

# Non-core
use DDP colored => 1;
use IPC::Run3;
use Path::Class;

my $file_2a50 = $ENV{ PDBDIR } . '/2a50';
my $file_3ako = $ENV{ PDBDIR } . '/3ako';
my $file_3cgl = $ENV{ PDBDIR } . '/3cgl';

if ( scalar( @ARGV ) > 1 ) {
	confess 'Usage...';
}

if ( scalar( @ARGV ) > 0 ) {
	my ( $param ) = @ARGV;
	foreach my $file_stem_ref ( \$file_2a50, \$file_3ako, \$file_3cgl ) {
		my $file_stem = $$file_stem_ref;
		if ( $param =~ /$file_stem/ ) {
			$$file_stem_ref = $param;
		}
	}
}

my $temp_output_dir = dir( '/tmp/delta_reduce_orient_crash.ssaps_dir' );

my $core_file = file( 'core' );

my @command = (
	'/cath-tools/ninja_gcc_relwithdebinfo/cath-superpose',
	( '--do-the-ssaps=' . $temp_output_dir ),
	'--pdb-infile', $file_2a50,
	'--pdb-infile', $file_3ako,
	'--pdb-infile', $file_3cgl,
	qw#
		--align-regions D[2a50B]:B
		--align-regions D[3akoA]:A
		--align-regions D[3cglF]:F
		--sup-to-pymol-file
		/tmp/a.pml
	#
);

# warn "\n";
# warn localtime() . ' : ' . cwd() . "\n";
# warn localtime() . ' : ' . `pwd`;
# warn localtime() . ' : ' . `ls -l`;
# warn localtime() . ' : ' . join( ' ', @command )."\n";

if ( -e $temp_output_dir ) {
	$temp_output_dir->rmtree()
		or confess 'Unable to remove ' . $temp_output_dir . ' : ' . $OS_ERROR;
}

if ( -e $core_file ) {
	$core_file->remove()
		or confess 'Unable to remove ' . $core_file . ' : ' . $OS_ERROR;
}

my ( $stdout, $stderr );
my $return = run3 ( \@command, \undef, \$stdout, \$stderr );
my %results = (
	return => $return,
	stderr => $stderr,
	stdout => $stdout,
);
p %results;

my $result = ( -e $core_file ) ? 0 : 1;

if ( -e $core_file ) {
	$core_file->remove()
		or confess 'Unable to remove ' . $core_file . ' : ' . $OS_ERROR;
}

p $result;
exit $result;
