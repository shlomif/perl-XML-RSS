# $Id: version.t,v 1.1 2002/11/12 10:41:50 comdog Exp $

use Test::More tests => 6;

$|++;

use XML::RSS;

my @versions = qw( 0.9 0.91 1.0 );

my $rss = XML::RSS->new( version => '0.9' );
isa_ok( $rss, 'XML::RSS' );
make_rss( $rss );
like( $rss->as_string, 
	qr|<rdf:RDF[\d\D]+xmlns="http://my.netscape.com/rdf/simple/0.9/"[^>]*>|,
	"rdf tag for version $version" );

my $rss = XML::RSS->new( version => '0.91' );
isa_ok( $rss, 'XML::RSS' );
make_rss( $rss );
like( $rss->as_string, qr/<rss version="0.91">/,
	"rss tag for version $version" );

my $rss = XML::RSS->new( version => '1.0' );
isa_ok( $rss, 'XML::RSS' );
make_rss( $rss );
like( $rss->as_string, 
	qr|<rdf:RDF[\d\D]+xmlns="http://purl.org/rss/1.0/"[^>]*>|,
	"rdf tag for version $version" );
	
sub make_rss
	{
	my $rss = shift;
	
	$rss->channel(
		title => 'Test RSS',
		link  => 'http://www.example.com',
		);
		
	}
