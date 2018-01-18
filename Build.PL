use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    'module_name' => "XML::RSS",
    'requires' =>
    {
        'DateTime' => 0,
        'DateTime::Format::Mail' => 0,
        'DateTime::Format::W3CDTF' => 0,
        'HTML::Entities' => 0,
        'perl' => '5.008',
        'XML::Parser' => '2.23',
    },
    build_requires =>
    {
        'Test::More' => 0,
    },
    configure_requires =>
    {
        'Module::Build' => '0.36',
    },
    'license' => "perl",
    dist_author => 'Shlomi Fish <shlomif@cpan.org>',
    meta_merge =>
    {
        resources =>
        {
            repository => "https://github.com/shlomif/perl-XML-RSS",
            homepage => "http://perl-rss.sourceforge.net/",
        },
        keywords =>
        [
            "feed",
            "feeds",
            "generate",
            "generating",
            "parse",
            "parsing",
            "rss",
            "RSS",
            "web-feed",
            "web-feeds",
            "xml",
        ],
    },
);
$build->create_build_script;
