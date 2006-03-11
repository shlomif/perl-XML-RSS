# $Id: auto_add_modules.t,v 1.2 2003/02/20 17:12:46 kellan Exp $

use Test::More tests => 3;
use XML::RSS;

$XML::RSS::AUTO_ADD = 1;

my $URL = 'http://freshmeat.net/backend/fm-releases-0.1.dtd';
my $TAG = 'fm';

my $rss = XML::RSS->new();
isa_ok( $rss, 'XML::RSS' );

$rss->parsefile( 'examples/freshmeat.rdf' );

#print STDERR Data::Dumper::Dumper( $rss );
use Data::Dumper;

ok( exists $rss->{modules}{$URL}, 'Freshmeat module exists' );
is( $rss->{modules}{$URL}, $TAG, 'Freshmeat module has right URI' );

