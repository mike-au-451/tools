#!/usr/bin/perl

=pod

Reindent files because stupid auto-guessing editors mess it up.  Continually.

Usage:

retab [--space=n] [--tab=n] [--backup] [--verbose] file ...

=cut

use Modern::Perl;
use Getopt::Long;
use File::Slurp;

my %opts;
GetOptions (
	\%opts,
	"backup",
	"tab=s",
	"space=s",
	"verbose",
) or die "FATAL: bad options\n";

$opts{'tab'} //= 0;
$opts{'space'} //= 0;

if ($opts{'tab'} == 0 && $opts{'space'} == 0) {
	# Default to replacing 4 spaces with tabs.
	$opts{'tab'} = 4;
}

my (@lines, $ts);

$ts = time();

for my $file (@ARGV) {
	if (! -f $file) {
		print "ERROR: $file is not a file\n";
		next;
	}

	@lines = read_file($file);
	@lines = retab(@lines);
	@lines = unwhite(@lines);

	if ($opts{'backup'}) {
		rename $file, "$file.$ts";
	}
	write_file($file, @lines);
}

sub retab {
	my @lines = @_;

	my $base_target = " " x $opts{'tab'};
	my ($target, $replac, $ii, $jj);

	# 10 levels of nesting ought to be enough for anyone :)
	for ($ii = 10; $ii > 0; $ii--) {
		$target = $base_target x $ii;
		$replac = "\t" x $ii;

		for ($jj = 0; $jj < @lines; $jj++) {
			$lines[$jj] =~ s/^$target/$replac/;
		}
	}

	return @lines;
}

sub unwhite {
	my @lines = @_;

	my ($jj);

	for ($jj = 0; $jj < @lines; $jj++) {
		$lines[$jj] =~ s/\s+$/\n/;
	}

	return @lines;
}
