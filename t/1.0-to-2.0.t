#!/usr/bin/perl

use strict;
use warnings;

use File::Spec;

use Test::More tests => 1;

use XML::RSS;

{
    my $rss = XML::RSS->new;
    $rss->parsefile(File::Spec->catfile("examples", "merlyn1.rss"));

    $rss->{output} = "2.0";
    my $string = $rss->as_string;

    # TEST
    ok (index($string, q{<lastBuildDate>Sat, 14 Oct 2006 21:15:36 -0000</lastBuildDate>}) >= 0,
        "Correct date was found",
    );
}
