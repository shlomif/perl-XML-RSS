#!/usr/bin/perl -w
use strict;

use Test::More tests => 1;
use XML::RSS;

my $rss = XML::RSS->new( version => '2.0' );
$rss->add_module(
        prefix => 'content',
        uri => 'http://purl.org/rss/1.0/modules/content/'
    );
$rss->add_item(
        title   => 'title',
        content => { encoded => 'this is content' },
    );

like $rss->as_string, qr/this is content/;
