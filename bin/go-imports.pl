#!/usr/bin/perl

=pod

Usage:
	imports file ...

Read each file looking for lines like:

	import "foo"
	import (
		"foo"
		"bar"
	)

Echo the imported paths

=cut

use Modern::Perl;
use Data::Dumper;

my $hack_fn;

for my $fn (@ARGV) {
	$hack_fn = $fn;
	scan($fn) if -f $fn && $fn =~ /\.go$/;
}

sub scan {
	my $fn = shift // "";

	return if $fn eq "";

	my $fh;

	if (!open($fh, "<", $fn)) {
		print "ERROR: failed to open $fn\n";
		return
	}

	while (my $line = <$fh>) {
		$line = trim($line);

		if ($line =~ /^import "(\S+)"/) {
			print "$hack_fn: $1\n";
		}

		if ($line =~ /^import \(/) {
			scanblock($fh);
		}
	}

	close($fh);
}

sub scanblock {
	my $fh = shift or die "BUG: scanblock: missing file handle";

	while (my $line = <$fh>) {
		$line = trim($line);
		next if $line eq "";
		last if $line eq ")";

		$line =~ /"(\S+)"/;
		print "$hack_fn: $1\n";
	}
}

sub trim {
	my $str = shift // "";

	$str =~ s/^\s+//;
	$str =~ s/\s+$//;

	return $str;
}

