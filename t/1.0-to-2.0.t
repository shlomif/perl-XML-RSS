#!/usr/bin/perl

use strict;
use warnings;

use File::Spec;

use Test::More tests => 7;

use XML::RSS;

{
    my $rss = XML::RSS->new;
    $rss->parsefile(File::Spec->catfile(File::Spec->curdir(), "t", "data", "merlyn1.rss"));

    $rss->{output} = "2.0";
    my $string = $rss->as_string;

    # TEST
    ok (index($string, q{<lastBuildDate>Sat, 14 Oct 2006 21:15:36 -0000</lastBuildDate>}) >= 0,
        "Correct date was found",
    );

    # TEST
    ok (index($string, q{<pubDate>Sat, 14 Oct 2006 21:15:36 -0000</pubDate>}) >= 0,
        "Correct pubDate was found",
    );    
}

{
    my $rss = XML::RSS->new;
    $rss->parsefile(File::Spec->catfile(File::Spec->curdir(), "t", "data", "merlyn1.rss"));

    $rss->{output} = "0.91";
    my $string = $rss->as_string;

    my $index = index($string, qq{<pubDate>Sat, 14 Oct 2006 21:15:36 -0000</pubDate>\n<lastBuildDate>Sat, 14 Oct 2006 21:15:36 -0000</lastBuildDate>\n});
    # TEST
    ok ($index >= 0,
        "Correct date was found in 1.0 -> 0.91 conversion",
    );
}

{
    my $rss = XML::RSS->new;
    $rss->parsefile(File::Spec->catfile(File::Spec->curdir(), "t", "data", "2.0","sf-hs-with-pubDate.rss"));

    $rss->{output} = "1.0";
    my $string = $rss->as_string;

    my $index = index($string, qq{<dc:date>2006-09-24T10:12:49Z</dc:date>\n});
    # TEST
    ok ($index >= 0,
        "Correct date was found in 1.0 -> 0.91 conversion",
    );

    my $item_index = index($string, "<item");

    # TEST
    ok ($index < $item_index,
        "Correct date comes before the first item (hence not contained within)."
    );
}

{
    my $rss = XML::RSS->new;
    $rss->parsefile(File::Spec->catfile(File::Spec->curdir(), "t", "data", "2.0","sf-hs-with-lastBuildDate.rss"));

    $rss->{output} = "1.0";
    my $string = $rss->as_string;

    my $index = index($string, qq{<dc:date>2006-09-24T10:12:49Z</dc:date>\n});
    # TEST
    ok ($index >= 0,
        "Correct date was found in 1.0 -> 0.91 conversion",
    );

    my $item_index = index($string, "<item");

    # TEST
    ok ($index < $item_index,
        "Correct date comes before the first item (hence not contained within)."
    );
}
