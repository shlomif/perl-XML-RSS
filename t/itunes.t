use XML::RSS;

use Test::More tests => 3;
use Test::Differences;

my @expecting = split(
    "---\n",
    do { local $/; <DATA> }
);
my $output;

my $simple_rss  = new XML::RSS(version => '2.0');
my $sub_rss     = new XML::RSS(version => '2.0');
my $complex_rss = new XML::RSS(version => '2.0');

foreach my $rss ($simple_rss, $sub_rss, $complex_rss) {
    $rss->add_module(
        prefix => 'itunes',
        uri    => 'http://www.itunes.com/dtds/podcast-1.0.dtd'
    );
}

$simple_rss->channel(itunes => {category => {text => 'Technology'}});

$sub_rss->channel(
    itunes => {
        category => {
            text     => 'Technology',
            category => {text => 'Computers'}
        }
    }
);

$complex_rss->channel(
    itunes => {
        category => [
            {   text     => 'Society & Culture',
                category => {text => 'History'}
            },
            {   text     => 'Technology',
                category => [{text => 'Gadgets'}, {text => 'Computers'}, {text => 'News'}]
            }
        ]
    }
);


foreach my $rss ($simple_rss, $sub_rss, $complex_rss) {
    eq_or_diff($rss->as_string . "\n", shift @expecting, 'itunes tests');
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>

<rss version="2.0"
 xmlns:blogChannel="http://backend.userland.com/blogChannelModule"
 xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
>

<channel>
<title></title>
<link></link>
<description></description>
<itunes:category text="Technology"/>

</channel>
</rss>
---
<?xml version="1.0" encoding="UTF-8"?>

<rss version="2.0"
 xmlns:blogChannel="http://backend.userland.com/blogChannelModule"
 xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
>

<channel>
<title></title>
<link></link>
<description></description>
<itunes:category text="Technology">
<itunes:category text="Computers"/>
</itunes:category>

</channel>
</rss>
---
<?xml version="1.0" encoding="UTF-8"?>

<rss version="2.0"
 xmlns:blogChannel="http://backend.userland.com/blogChannelModule"
 xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
>

<channel>
<title></title>
<link></link>
<description></description>
<itunes:category text="Society &#x26; Culture">
<itunes:category text="History"/>
</itunes:category>
<itunes:category text="Technology">
<itunes:category text="Gadgets"/>
<itunes:category text="Computers"/>
<itunes:category text="News"/>
</itunes:category>

</channel>
</rss>
