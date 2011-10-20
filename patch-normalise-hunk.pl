#!/usr/bin/perl
#
# Takes a single unified diff hunk on stdin, normalises it and
# emits it again on stdout, potentially splitting it into
# multiple hunks.  Useful as a filter for editors, e.g. nedit.
#
# Copyright (c) 2005 Greg Banks <gnb@alphalink.com.au>
#

my $verbose = 0;
my @lines;
my $ostart, $olength, $nstart, $nlength, $context;
my $n;
my $NUM_CONTEXT_LINES = 3;
my @errlines;

foreach my $a (@ARGV)
{
    if ($a eq '--verbose')
    {
	$verbose++;
    }
    else
    {
	die "Unknown option: $a";
    }
}

sub error
{
    foreach my $l (@errlines)
    {
	print "$l\n";
    }
    print "##### " . join(' ',@_) . "\n";
    while (<STDIN>)
    {
	print $_;
    }
    exit(1);
}

# Read the hunk
while (<STDIN>)
{
    chomp;
    $lineno++;
    push(@errlines, $_);

    print STDERR "\$_=\"$_\"\n" if ($verbose);

    if (!defined($nlength))
    {
    	# first line
	($ostart, $olength, $nstart, $nlength, $context) =
	    m/^@@ -(\d+),(\d+) \+(\d+),(\d+) @@(.*)$/;
	error "first line is not a hunk header"
	    unless defined($nlength);
    }
    else
    {
    	error "not a valid unified diff hunk line, expecting leading ' ','+' or '-'"
	    unless m/^([ +-])/;
	push(@lines, $_);
    }
}

# Dump some state for debugging
if ($verbose)
{
    print STDERR "ostart=$ostart\n";
    print STDERR "olength=$olength\n";
    print STDERR "nstart=$nstart\n";
    print STDERR "nlength=$nlength\n";
    print STDERR "context=\"$context\"\n";
    print STDERR "lines=(\n";
    foreach my $l (@lines)
    {
	print STDERR "    \"$l\"\n";
    }
    print STDERR ")\n";
    print STDERR ")\n";
}

my @hunks;

sub add_hunk
{
    my ($ostart, $nstart, $context, @lines) = @_;

    push(@hunks, {
	    ostart => $ostart,
	    olength => scalar(grep { m/^[- ]/ } @lines),
	    nstart => $nstart,
	    nlength => scalar(grep { m/^[+ ]/ } @lines),
	    context => $context,
	    lines => [ @lines ],
	    });
}

# Gather lines into one or more hunks with a
# minimum of surrounding context each.
my $oline = $ostart;
my $nline = $nstart;
my @hunklines;
my $started_hunk = 0;
my $ncontext = 0;
for my $line (@lines)
{
    printf STDERR "# -%u +%u %s\n", $oline, $nline, $line if ($verbose);
    if ($line =~ m/^ /)
    {
	# context line
	if ($started_hunk == 0)
	{
	    # leading context
	    print STDERR "# leading context\n" if ($verbose);
	    shift(@hunklines) if (scalar(@hunklines) == $NUM_CONTEXT_LINES);
	    push(@hunklines, $line);
	    $ncontext = scalar(@hunklines);
	}
	else
	{
	    # context after a change
	    if ($ncontext == 2*$NUM_CONTEXT_LINES)
	    {
		# end this hunk
		my @lines = splice(@hunklines,0,-($ncontext-$NUM_CONTEXT_LINES));
		$ncontext = scalar(@hunklines);
		printf STDERR "# ending hunk with %u lines, %u leftover\n",
			scalar(@lines), scalar(@hunklines) if ($verbose);
		add_hunk($ostart, $nstart, $context, @lines);
		$started_hunk = 0;
	    }
	    else
	    {
		push(@hunklines, $line);
		$ncontext++;
		printf STDERR "# saving line %u of trailing context\n", $ncontext if ($verbose);
	    }
	}
	$oline++;
	$nline++;
    }
    else
    {
	# old or new line
	print STDERR "# old or new line\n" if ($verbose);
	if (!$started_hunk)
	{
	    printf STDERR "# starting hunk\n" if ($verbose);
	    $ostart = $oline - $ncontext;
	    $nstart = $nline - $ncontext;
	    $started_hunk = 1;
	}
	$ncontext = 0;
	push(@hunklines, $line);
	if ($line =~ m/^+/)
	{
	    $oline++;
	}
	else
	{
	    $nline++;
	}
    }
}
if ($started_hunk)
{
    my $ntrim = ($ncontext <= $NUM_CONTEXT_LINES ? scalar(@hunklines) : -($ncontext-$NUM_CONTEXT_LINES));
    my @lines = splice(@hunklines,0,$ntrim);
    printf STDERR " # last hunk with %u lines\n", scalar(@lines) if ($verbose);
    add_hunk($ostart, $nstart, $context, @lines);
}

# dump some more state for debugging
if ($verbose)
{
    print STDERR "hunks=(\n";
    for my $h (@hunks)
    {
	print STDERR "    (\n";
	print STDERR "        ostart=$h->{ostart}\n";
	print STDERR "        olength=$h->{olength}\n";
	print STDERR "        nstart=$h->{nstart}\n";
	print STDERR "        nlength=$h->{nlength}\n";
	print STDERR "        context=\"$h->{context}\"\n";
	print STDERR "        lines=(\n";
	for my $l (@{$h->{lines}})
	{
	    print STDERR "            \"$l\"\n";
	}
	print STDERR "        )\n";
	print STDERR "    )\n";
    }
    print STDERR ")\n";
}

# emit the normalised hunks
for my $hunk (@hunks)
{
    printf "@@ -%u,%u +%u,%u @@%s\n",
	$hunk->{ostart}, $hunk->{olength}, $hunk->{nstart}, $hunk->{nlength}, $hunk->{context};
    foreach my $l (@{$hunk->{lines}})
    {
	print "$l\n";
    }
}
