use strict;
use warnings;

use Test::More tests => 14;

BEGIN {
  use_ok("XML::RSS");
}

my $xml;

{ 
    my $rss;
    ok($rss  = XML::RSS->new( 'xml:base' => 'http://example.com' ), "Created new rss");
    is($rss->{'xml:base'}, 'http://example.com', 'Got base');
    $rss->{'xml:base'} = 'http://foo.com/';
    ok($rss->channel( 
        title       => 'Test Feed', 
        link        => "http://example.com",
        description => "Foo",
    ), "Added channel");
    ok($rss->add_item(
        title => 'foo',
        'xml:base' => "http://foo.com/archive/",
        description => {
            content    => "Bar",
            'xml:base' => "http://foo.com/archive/1.html",
        }
    ), "Added item");



    ok($xml = $rss->as_rss_2_0(), "Got xml");
    output_contains($xml, 'xml:base="http://foo.com/"',               "Found rss base");
    output_contains($xml, 'xml:base="http://foo.com/archive/"',       "Found item base");
    output_contains($xml, 'xml:base="http://foo.com/archive/1.html"', "Found description base");
}

{
    my $rss = XML::RSS->new;
    ok($rss->parse($xml, { hashrefs_instead_of_strings => 1 }), "Reparsed xml");
    is($rss->{'xml:base'}, 'http://foo.com/',                   "Found parsed rss base");
    is(scalar(@{$rss->{items}}), 1,                             "Got 1 item");
    my $item = $rss->{items}->[0];
    is($item->{'xml:base'}, 'http://foo.com/archive/',          "Found parsed item base");
    SKIP : {
        if (ref $item->{description} eq 'HASH') {
            is($item->{description}->{'xml:base'}, 'http://foo.com/archive/1.html', 
            "Found parsed description base");
        } else {
            fail("Description is not a hash ref");
        }
    }
}

sub output_contains
{
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($rss_output, $sub_string, $msg) = @_;

    my $ok = ok (index ($rss_output,
        $sub_string) >= 0,
        $msg
    );
    if (! $ok)
    {
        diag("Could not find the substring [$sub_string] in:{{{{\n$rss_output\n}}}}\n");
    }
    return $ok;
}

