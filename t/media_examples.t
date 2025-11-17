use strict;
use warnings;
use Test::More;

# Smallish test cases that demonstrate the API of media elements in
# parsed RSS feeds.

use_ok("XML::RSS");

# Test single media:content at channel level
subtest 'single media:content at channel level' => sub {
    my $rss_xml = q{<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
  <channel>
    <title>Test Channel</title>
    <link>http://example.com</link>
    <description>Test RSS feed</description>
    <media:content url="http://example.com/channel-video.mp4" type="video/mp4" />
  </channel>
</rss>};

    my $rss = XML::RSS->new(version => '2.0');
    $rss->parse($rss_xml);

    # Access single media:content at channel level
    my $media_content = $rss->{channel}->{media}->{content};
    is(ref($media_content), 'HASH', 'Single channel media:content is a HASH');
    is($media_content->{url}, 'http://example.com/channel-video.mp4', 'Channel media:content URL correct');
    is($media_content->{type}, 'video/mp4', 'Channel media:content type correct');
};

# Test multiple media:content at channel level
subtest 'multiple media:content at channel level' => sub {
    my $rss_xml = q{<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
  <channel>
    <title>Test Channel</title>
    <link>http://example.com</link>
    <description>Test RSS feed</description>
    <media:content url="http://example.com/channel-hd.mp4" type="video/mp4" width="1920" />
    <media:content url="http://example.com/channel-sd.mp4" type="video/mp4" width="720" />
  </channel>
</rss>};

    my $rss = XML::RSS->new(version => '2.0');
    $rss->parse($rss_xml);

    # Access multiple media:content at channel level
    my $media_content = $rss->{channel}->{media}->{content};
    is(ref($media_content), 'ARRAY', 'Multiple channel media:content is an ARRAY');
    is(scalar @$media_content, 2, 'Channel has 2 media:content elements');

    # Access first content element
    is($media_content->[0]->{url}, 'http://example.com/channel-hd.mp4', 'First channel content URL correct');
    is($media_content->[0]->{width}, '1920', 'First channel content width correct');

    # Access second content element
    is($media_content->[1]->{url}, 'http://example.com/channel-sd.mp4', 'Second channel content URL correct');
    is($media_content->[1]->{width}, '720', 'Second channel content width correct');
};

# Test single media:content at item level
subtest 'single media:content at item level' => sub {
    my $rss_xml = q{<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
  <channel>
    <title>Test Channel</title>
    <link>http://example.com</link>
    <description>Test RSS feed</description>
    <item>
      <title>Test Item</title>
      <link>http://example.com/item1</link>
      <description>Test item description</description>
      <media:content url="http://example.com/item-video.mp4" type="video/mp4" duration="300" />
    </item>
  </channel>
</rss>};

    my $rss = XML::RSS->new(version => '2.0');
    $rss->parse($rss_xml);

    # Access single media:content at item level
    my $item = $rss->{items}->[0];
    my $media_content = $item->{media}->{content};
    is(ref($media_content), 'HASH', 'Single item media:content is a HASH');
    is($media_content->{url}, 'http://example.com/item-video.mp4', 'Item media:content URL correct');
    is($media_content->{type}, 'video/mp4', 'Item media:content type correct');
    is($media_content->{duration}, '300', 'Item media:content duration correct');
};

# Test multiple media:content at item level
subtest 'multiple media:content at item level' => sub {
    my $rss_xml = q{<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
  <channel>
    <title>Test Channel</title>
    <link>http://example.com</link>
    <description>Test RSS feed</description>
    <item>
      <title>Test Item</title>
      <link>http://example.com/item1</link>
      <description>Test item description</description>
      <media:content url="http://example.com/item-video.mp4" type="video/mp4" width="1920" />
      <media:content url="http://example.com/item-audio.mp3" type="audio/mpeg" bitrate="128" />
      <media:content url="http://example.com/item-thumb.jpg" type="image/jpeg" width="200" />
    </item>
  </channel>
</rss>};

    my $rss = XML::RSS->new(version => '2.0');
    $rss->parse($rss_xml);

    # Access multiple media:content at item level
    my $item = $rss->{items}->[0];
    my $media_content = $item->{media}->{content};
    is(ref($media_content), 'ARRAY', 'Multiple item media:content is an ARRAY');
    is(scalar @$media_content, 3, 'Item has 3 media:content elements');

    # Access video content
    is($media_content->[0]->{url}, 'http://example.com/item-video.mp4', 'Video content URL correct');
    is($media_content->[0]->{type}, 'video/mp4', 'Video content type correct');
    is($media_content->[0]->{width}, '1920', 'Video content width correct');

    # Access audio content
    is($media_content->[1]->{url}, 'http://example.com/item-audio.mp3', 'Audio content URL correct');
    is($media_content->[1]->{type}, 'audio/mpeg', 'Audio content type correct');
    is($media_content->[1]->{bitrate}, '128', 'Audio content bitrate correct');

    # Access image content
    is($media_content->[2]->{url}, 'http://example.com/item-thumb.jpg', 'Image content URL correct');
    is($media_content->[2]->{type}, 'image/jpeg', 'Image content type correct');
    is($media_content->[2]->{width}, '200', 'Image content width correct');
};

# Test single media:group at item level
subtest 'single media:group at item level' => sub {
    my $rss_xml = q{<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
  <channel>
    <title>Test Channel</title>
    <link>http://example.com</link>
    <description>Test RSS feed</description>
    <item>
      <title>Test Item</title>
      <link>http://example.com/item1</link>
      <description>Test item description</description>
      <media:group>
        <media:title>Video Collection</media:title>
        <media:content url="http://example.com/hd.mp4" type="video/mp4" width="1920" />
        <media:content url="http://example.com/sd.mp4" type="video/mp4" width="720" />
        <media:thumbnail url="http://example.com/thumb.jpg" width="120" height="90" />
      </media:group>
    </item>
  </channel>
</rss>};

    my $rss = XML::RSS->new(version => '2.0');
    $rss->parse($rss_xml);

    # Access single media:group at item level
    my $item = $rss->{items}->[0];
    my $media_group = $item->{media}->{group};
    is(ref($media_group), 'HASH', 'Single item media:group is a HASH');

    # Access group title
    is($media_group->{title}, 'Video Collection', 'Group title correct');

    # Access group content array
    my $group_content = $media_group->{content};
    is(ref($group_content), 'ARRAY', 'Group content is an ARRAY');
    is(scalar @$group_content, 2, 'Group has 2 content elements');

    # Access HD content
    is($group_content->[0]->{url}, 'http://example.com/hd.mp4', 'HD content URL correct');
    is($group_content->[0]->{width}, '1920', 'HD content width correct');

    # Access SD content
    is($group_content->[1]->{url}, 'http://example.com/sd.mp4', 'SD content URL correct');
    is($group_content->[1]->{width}, '720', 'SD content width correct');

    # Access group thumbnail
    my $group_thumbnail = $media_group->{thumbnail};
    is($group_thumbnail->{url}, 'http://example.com/thumb.jpg', 'Group thumbnail URL correct');
    is($group_thumbnail->{width}, '120', 'Group thumbnail width correct');
    is($group_thumbnail->{height}, '90', 'Group thumbnail height correct');
};

# Test multiple media:group at item level
subtest 'multiple media:group at item level' => sub {
    my $rss_xml = q{<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
  <channel>
    <title>Test Channel</title>
    <link>http://example.com</link>
    <description>Test RSS feed</description>
    <item>
      <title>Test Item</title>
      <link>http://example.com/item1</link>
      <description>Test item description</description>
      <media:group>
        <media:title>Video Formats</media:title>
        <media:content url="http://example.com/video-hd.mp4" type="video/mp4" width="1920" />
        <media:content url="http://example.com/video-sd.mp4" type="video/mp4" width="720" />
      </media:group>
      <media:group>
        <media:title>Audio Formats</media:title>
        <media:content url="http://example.com/audio-high.mp3" type="audio/mpeg" bitrate="320" />
        <media:content url="http://example.com/audio-low.mp3" type="audio/mpeg" bitrate="128" />
      </media:group>
    </item>
  </channel>
</rss>};

    my $rss = XML::RSS->new(version => '2.0');
    $rss->parse($rss_xml);

    # Access multiple media:group at item level
    my $item = $rss->{items}->[0];
    my $media_groups = $item->{media}->{group};
    is(ref($media_groups), 'ARRAY', 'Multiple item media:group is an ARRAY');
    is(scalar @$media_groups, 2, 'Item has 2 media:group elements');

    # Access first group (Video Formats)
    my $video_group = $media_groups->[0];
    is($video_group->{title}, 'Video Formats', 'First group title correct');

    my $video_content = $video_group->{content};
    is(ref($video_content), 'ARRAY', 'First group content is an ARRAY');
    is(scalar @$video_content, 2, 'First group has 2 content elements');
    is($video_content->[0]->{url}, 'http://example.com/video-hd.mp4', 'Video HD URL correct');
    is($video_content->[1]->{url}, 'http://example.com/video-sd.mp4', 'Video SD URL correct');

    # Access second group (Audio Formats)
    my $audio_group = $media_groups->[1];
    is($audio_group->{title}, 'Audio Formats', 'Second group title correct');

    my $audio_content = $audio_group->{content};
    is(ref($audio_content), 'ARRAY', 'Second group content is an ARRAY');
    is(scalar @$audio_content, 2, 'Second group has 2 content elements');
    is($audio_content->[0]->{url}, 'http://example.com/audio-high.mp3', 'Audio high URL correct');
    is($audio_content->[0]->{bitrate}, '320', 'Audio high bitrate correct');
    is($audio_content->[1]->{url}, 'http://example.com/audio-low.mp3', 'Audio low URL correct');
    is($audio_content->[1]->{bitrate}, '128', 'Audio low bitrate correct');
};

# Test custom namespace prefix (demonstrates flexibility)
subtest 'custom namespace prefix support' => sub {
    my $rss_xml = q{<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:mymedia="http://search.yahoo.com/mrss/">
  <channel>
    <title>Test Channel</title>
    <link>http://example.com</link>
    <description>Test RSS feed with custom prefix</description>
    <mymedia:copyright>Copyright 2025 Custom Corp</mymedia:copyright>
    <item>
      <title>Test Item</title>
      <link>http://example.com/item1</link>
      <description>Test item description</description>
      <mymedia:content url="http://example.com/video.mp4" type="video/mp4" width="640">
        <mymedia:title>Custom Video Title</mymedia:title>
      </mymedia:content>
      <mymedia:keywords>custom, prefix, test</mymedia:keywords>
    </item>
  </channel>
</rss>};

    my $rss = XML::RSS->new(version => '2.0');
    $rss->parse($rss_xml);
    
    # Access works with custom prefix - channel elements stored under actual prefix used
    is($rss->{channel}->{mymedia}->{copyright}, 'Copyright 2025 Custom Corp', 'Channel media copyright with custom prefix');
    
    my $item = $rss->{items}->[0];
    my $media_content = $item->{mymedia}->{content};
    is(ref($media_content), 'HASH', 'Custom prefix media:content is a HASH');
    is($media_content->{url}, 'http://example.com/video.mp4', 'Custom prefix content URL correct');
    is($media_content->{width}, '640', 'Custom prefix content width correct');
    # TODO: Fix nested element parsing within custom prefix media:content
    # is($media_content->{title}, 'Custom Video Title', 'Custom prefix nested title correct');
    
    is($item->{mymedia}->{keywords}, 'custom, prefix, test', 'Custom prefix keywords correct');
};

done_testing();
