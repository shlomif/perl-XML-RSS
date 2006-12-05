use Test::More;

eval "use Test::Pod::Coverage";
plan skip_all => "Test::Pod::Coverage required for testing pod coverage" if $@;

plan tests => 1;

# the handle_methods are just for XML::Parser
pod_coverage_ok( "XML::RSS", { also_private => [ qr/^(handle_(char|dec|start)|as_rss_.*)$/ ], }, "XML::RSS is covered" );
