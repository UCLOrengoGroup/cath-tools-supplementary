#!/usr/bin/env perl

use strict;
use warnings;

use Carp          qw/ confess        /;
use Data::Dumper;
use English       qw/ -no_match_vars /;
use feature       qw/ say            /;
use JSON          qw/ decode_json    /;
use LWP::Simple;
my $builds_url      = 'https://api.github.com/repos/UCLOrengoGroup/cath-tools/releases';

# http://keepachangelog.com/en/0.3.0/

my $json         = get( $builds_url );
if ( ! defined( $json ) ) {
	confess "Couldn't get \"$builds_url\" : $OS_ERROR";
} 
my $releases = decode_json( $json );

say "# Summary of changes in cath-tools releases\n\n";

print join(
		"\n",
		map {
			my $release      = $ARG;
			my $body         = $release->{ body         } // '';
			my $html_url     = $release->{ html_url     };
			my $tag_name     = $release->{ tag_name     };
			my $name         = $release->{ name         } // '';
			my $published_at = $release->{ published_at };

			$published_at =~ s/T\d{2}:\d{2}:\d{2}Z//g;
			$body =~ s/\b(\w{40})\b/[$1](https:\/\/github.com\/UCLOrengoGroup\/cath-tools\/commit\/$1)/g;
			$body =~ s/#(\d+)\b/[$1](https:\/\/github.com\/UCLOrengoGroup\/cath-tools\/issues\/$1)/g ;

			  "### [$tag_name]($html_url) $name\n\n"
			. $published_at . ' &nbsp; ' . $body
			. "\n\n";
		} @$releases
	);
