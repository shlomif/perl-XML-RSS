use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder::Manifest;

my $build = Test::Run::Builder::Manifest->new(
    'module_name' => "XML::RSS",
    'requires' => 
    {
        'DateTime' => 0,
        'DateTime::Format::Mail' => 0,
        'DateTime::Format::W3CDTF' => 0,
        'HTML::Entities' => 0,
        'XML::Parser' => '2.23',
    },
    build_requires =>
    {
        'Test::Manifest' => '0.9',
        'Test::More' => 0,
    },
    'license' => "perl", 
);
$build->create_build_script;
