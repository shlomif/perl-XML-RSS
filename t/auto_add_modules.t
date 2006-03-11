# $Id: auto_add_modules.t,v 1.3 2004/04/21 02:44:40 kellan Exp $

use Test::More tests => 3;
use XML::RSS;

$XML::RSS::AUTO_ADD = 1;

my $URL = 'http://freshmeat.net/backend/fm-releases-0.1.dtd';
my $TAG = 'fm';

my $rss = XML::RSS->new();
isa_ok( $rss, 'XML::RSS' );

$rss->parsefile( 'examples/freshmeat.rdf' );

#use Data::Dumper;
#print Data::Dumper::Dumper( $rss );


ok( exists $rss->{modules}{$URL}, 'Freshmeat module exists' );
is( $rss->{modules}{$URL}, $TAG, 'Freshmeat module has right URI' );

