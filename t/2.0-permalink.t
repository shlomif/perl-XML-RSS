#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use File::Spec;
use XML::RSS;

my $rss = new XML::RSS;
$rss->parsefile(File::Spec->catfile("examples", 'rss-permalink.xml') );
my $item_with_guid_true = $rss->{'items'}->[0];
my $item_with_guid_missing = $rss->{'items'}->[1];
my $item_with_guid_false = $rss->{'items'}->[2];

# TEST
ok ($item_with_guid_true->{"permaLink"}, 
    "guid is set to true, so the permalink should be true"
);

# TEST
ok ($item_with_guid_missing->{"permaLink"},
    "guid is missing, so the permalink should be true"
);

# TEST
ok ((!$item_with_guid_false->{"permaLink"}),
    "guid is false, so the permalink should be false"
);
