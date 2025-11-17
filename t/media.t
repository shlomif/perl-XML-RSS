use strict;
use warnings;
use Test::More;
use File::Spec;

use_ok("XML::RSS");

sub test_round_trip_parsing {
    my ($filename) = @_;
    
    subtest "$filename round-trip parsing" => sub {
        my $rss = XML::RSS->new(version => '2.0');
        isa_ok($rss, "XML::RSS");

        # Read test data file
        my $data_file = File::Spec->catfile('t', 'data', $filename);

        open my $fh, '<', $data_file or die "Cannot open $data_file: $!";
        my $rss_content = do { local $/; <$fh> };
        close $fh;

        # Parse the RSS feed (media module is now supported natively)
        eval { $rss->parse($rss_content); };
        is($@, '', "Parsed RSS feed with media elements successfully");

        # Pretty print the parsed result to XML
        my $output_xml = $rss->as_string();

        # Parse the output XML again
        my $rss2 = XML::RSS->new(version => '2.0');
        eval { $rss2->parse($output_xml); };
        is($@, '', "Re-parsed generated XML successfully");

        # Verify complete round-trip parsing preserves entire structure
        is_deeply($rss2, $rss, "Complete RSS structure preserved in round-trip");
    };
}


# Test parsing RSS 2.0 feed with media elements at multiple levels
subtest 'media-sample.rss deep comparison' => sub
{
    my $rss = XML::RSS->new(version => '2.0');
    isa_ok($rss, "XML::RSS");

    # Read test data file
    my $data_file = File::Spec->catfile('t', 'data', 'media-sample.rss');

    open my $fh, '<', $data_file or die "Cannot open $data_file: $!";
    my $rss_content = do { local $/; <$fh> };
    close $fh;

    # Parse the RSS feed (media module is now supported natively)
    eval { $rss->parse($rss_content); };
    is($@, '', "Parsed RSS feed with media elements successfully");

    # Check that we have the expected item
    is(scalar @{$rss->{items}}, 1, "RSS feed contains one item");

    my $item = $rss->{items}->[0];
    is($item->{title}, "Sample Media Item", "Item has correct title");

    # === Test Channel-level media elements ===
    ok(exists $rss->{channel}->{media}, "Channel contains media namespace data");
    is($rss->{channel}->{media}->{copyright}, "Copyright 2025 Channel Corp", "Channel media copyright is correct");
    ok(exists $rss->{channel}->{media}->{category}, "Channel contains media:category element");
    is($rss->{channel}->{media}->{category}->{scheme}, "urn:channel:category", "Channel media category scheme is correct");
    is($rss->{channel}->{media}->{category}->{content}, "news media rss", "Channel media category content is correct");

    # === Test Item-level media elements ===
    ok(exists $item->{media}, "Item contains media namespace data");

    # Check item-level media:title
    ok(exists $item->{media}->{title}, "Item contains media:title element");
    is($item->{media}->{title}, "Sample Video Title", "Item media title is correct");

    # Check item-level media:description with type attribute
    ok(exists $item->{media}->{description}, "Item contains media:description element");
    is($item->{media}->{description}->{type}, "html", "Item media description type is correct");
    like($item->{media}->{description}->{content}, qr/strong.*media RSS.*strong/, "Item media description content is correct");

    # Check item-level media:thumbnail
    ok(exists $item->{media}->{thumbnail}, "Item contains media:thumbnail element");
    is($item->{media}->{thumbnail}->{url}, "http://example.com/thumb.jpg", "Item media thumbnail URL is correct");
    is($item->{media}->{thumbnail}->{width}, "120", "Item media thumbnail width is correct");
    is($item->{media}->{thumbnail}->{height}, "90", "Item media thumbnail height is correct");

    # Check item-level media:credit
    ok(exists $item->{media}->{credit}, "Item contains media:credit element");
    is($item->{media}->{credit}->{role}, "photographer", "Item media credit role is correct");
    like($item->{media}->{credit}->{content}, qr/John Doe/, "Item media credit content is correct");

    # Check item-level media:category
    ok(exists $item->{media}->{category}, "Item contains media:category element");
    is($item->{media}->{category}->{scheme}, "urn:flickr:tags", "Item media category scheme is correct");
    is($item->{media}->{category}->{content}, "video tutorial rss demo", "Item media category content is correct");

    # Check simple text elements at item level
    ok(exists $item->{media}->{keywords}, "Item contains media:keywords element");
    is($item->{media}->{keywords}, "video, tutorial, rss, media, demo, sample", "Item media keywords are correct");

    ok(exists $item->{media}->{rating}, "Item contains media:rating element");
    is($item->{media}->{rating}, "nonadult", "Item media rating is correct");

    ok(exists $item->{media}->{copyright}, "Item contains media:copyright element");
    is($item->{media}->{copyright}, "Copyright 2025 Example Corp", "Item media copyright is correct");

    # Check item-level media:text
    ok(exists $item->{media}->{text}, "Item contains media:text element");
    is($item->{media}->{text}->{type}, "plain", "Item media text type is correct");
    is($item->{media}->{text}->{lang}, "en", "Item media text language is correct");
    like($item->{media}->{text}->{content}, qr/Sample video transcript text/, "Item media text content is correct");

    # Check item-level media:hash
    ok(exists $item->{media}->{hash}, "Item contains media:hash element");
    is($item->{media}->{hash}->{algo}, "md5", "Item media hash algorithm is correct");
    like($item->{media}->{hash}->{content}, qr/d41d8cd98f00b204e9800998ecf8427e/, "Item media hash content is correct");

    # Check item-level media:player
    ok(exists $item->{media}->{player}, "Item contains media:player element");
    is($item->{media}->{player}->{url}, "http://example.com/player?video=123", "Item media player URL is correct");
    is($item->{media}->{player}->{width}, "640", "Item media player width is correct");
    is($item->{media}->{player}->{height}, "480", "Item media player height is correct");

    # Check item-level media:restriction
    ok(exists $item->{media}->{restriction}, "Item contains media:restriction element");
    is($item->{media}->{restriction}->{relationship}, "allow", "Item media restriction relationship is correct");
    is($item->{media}->{restriction}->{type}, "country", "Item media restriction type is correct");
    like($item->{media}->{restriction}->{content}, qr/US CA UK/, "Item media restriction content is correct");

    # === Test media:content element and its children ===
    ok(exists $item->{media}->{content}, "Item contains media:content element");

    # Check all media:content attributes are correctly parsed
    my $media_content = $item->{media}->{content};
    is($media_content->{url}, "http://example.com/video.mp4", "Media content URL is correct");
    is($media_content->{type}, "video/mp4", "Media content type is correct");
    is($media_content->{width}, "640", "Media content width is correct");
    is($media_content->{height}, "480", "Media content height is correct");
    is($media_content->{duration}, "120", "Media content duration is correct");

    # Check nested media elements within media:content
    ok(exists $media_content->{title}, "Media content contains nested title");
    is($media_content->{title}, "Content-specific Title", "Nested media title is correct");

    ok(exists $media_content->{description}, "Media content contains nested description");
    is($media_content->{description}->{type}, "plain", "Nested media description type is correct");
    is($media_content->{description}->{content}, "Content-specific description text", "Nested media description content is correct");

    ok(exists $media_content->{thumbnail}, "Media content contains nested thumbnail");
    is($media_content->{thumbnail}->{url}, "http://example.com/content-thumb.jpg", "Nested media thumbnail URL is correct");
    is($media_content->{thumbnail}->{width}, "80", "Nested media thumbnail width is correct");
    is($media_content->{thumbnail}->{height}, "60", "Nested media thumbnail height is correct");

    ok(exists $media_content->{credit}, "Media content contains nested credit");
    is($media_content->{credit}->{role}, "director", "Nested media credit role is correct");
    is($media_content->{credit}->{content}, "Jane Smith", "Nested media credit content is correct");
};

# Test round-trip parsing for all RSS files
test_round_trip_parsing('media-sample.rss');
test_round_trip_parsing('media-group-sample.rss');
test_round_trip_parsing('media-multiple-content.rss');
test_round_trip_parsing('media-multiple-groups.rss');
test_round_trip_parsing('media-custom-prefix.rss');

done_testing();
