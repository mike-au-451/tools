#!/usr/bin/perl

=pod

Quick cd.  Uses an info file to associate tags with directories so that you 
can "cd to a tag"without having to type paths.

This script can be invoked directly, but should really be used with an alias
and a function so the the current environment can be modified:

```
	#!/bin/bash

	# qcd runs in a subshell.
	# capture the output and execute cd in the current shell.
	# allow usage like 'qq foo' with the alias
	function qcd-run {
		cd $(perl $HOME/bin/qcd.pl $@)
	}

	alias qq=qcd-run
```

Usage:

	qq tag
	qq tag/extra/path/elements

The extra path elements are optional.  If present the script replaces the tag
and appends the extra elements.

The Info File:

The info file consists of records, one per line.  Each record is a three part
tuple with each element separated by tilde:

	tag~path~dynamic

The tag is an (alomst) arbitrary string, usually short, that you associate 
with the path.  The tag should be unique.  The path is optional, if present 
it is the directory to change to.  The dynamic part is optional.  If present 
it will be passed to a subshell and executed.  It is expected to return a 
path of some kind.  Either the path or the dynamic part should be present, 
not both.

Installation:

You need perl and the packages Modern::Perl and Data::Dumper
You need a linux-style grep that supports perl-style regular expressions.

On Ubuntu:

	sudo apt update
	sudo apt install perl
	cpan install Modern::Perl

=cut

# TODO:
# 1.  Allow comments in the info file.
#     This implies grepping the file, allowing multiple hits, but ignoring
#     any line starting with a hash.

use Modern::Perl;
use Data::Dumper;

if (scalar @ARGV == 0) {
	print $ENV{'PWD'} . "\n";
	exit 1;
}

# ARGV[0] is of the form:
# 
#   aa/bb/cc
# 
# Split off the "aa" to use to lookup the root.
# If the root is found (uniquely) join the new root with the "bb/cc"
# to form the actual path:
# 
#   root/bb/cc

my @elems = split(/\//, $ARGV[0]);
my $target = shift @elems;	# aa/bb/cc => bb/cc

# Run grep over the first field only.
# Run two searches, the first matching over the whole tag, then matching
# any substring in the tag.  The idea is to allow specific tags that are
# unambiguous, even if tag elements appear multiple times like 'mono'.
my @matches;

@matches = qx(grep -P '^$target\[^~\]*~' $ENV{'HOME'}/lib/qcd.info);
if (1 != @matches) {
	@matches = qx(grep -P '^\[^~\]*$target\[^~\]*~' $ENV{'HOME'}/lib/qcd.info);
}

if (1 != @matches) {
	# Either zero or non unique match
	print STDERR "no unique match\n";
	print $ENV{'PWD'} . "\n";
	exit 1;
}

my $matched = $matches[0];
my $stem = join("/", @elems);
$stem = "/$stem" if $stem ne "";

@elems = split(/~/, $matched, -1);
if (scalar @elems < 3) {
	# Syntax error in qcd.info
	print $ENV{'PWD'} . "\n";
	exit 1;
}

my $root = "";
$elems[2] = trim($elems[2]);
if ($elems[2] ne "") {
	# TODO:
	# Run embedded scripts for dynamic lookup
	my $ix = 2;
	for (; $ix < @elems - 1; $ix++) {
		# Copy the elems to a temp file,
		# then source the temp file into the current shell,
		# then clean up the temp file.
		print $elems[$ix] . "\n";
	}
	print trim(qx($elems[$ix])) . $stem . "\n";
}
else {
	$root = $elems[1];
	print "$root$stem\n";
}

sub trim {
	my $str = shift // "";
	$str =~ s/^\s+//;
	$str =~ s/\s+$//;

	return $str;
}

