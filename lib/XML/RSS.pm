package XML::RSS;
use strict;
use Carp;
use XML::Parser;
use HTML::Entities qw(encode_entities_numeric encode_entities);
use base qw(XML::Parser);
use DateTime::Format::Mail;
use DateTime::Format::W3CDTF;

use vars qw($VERSION $AUTOLOAD @ISA $AUTO_ADD);

$VERSION = '1.22';

$AUTO_ADD = 0;

sub _get_ok_fields {
    return {
        "0.9" => {
            channel => {
                title       => '',
                description => '',
                link        => '',
            },
            image => {
                title => undef,
                url   => undef,
                link  => undef,
            },
            textinput => {
                title       => undef,
                description => undef,
                name        => undef,
                link        => undef,
            },
        },
        "0.91" => {
            channel => {
                title          => '',
                copyright      => undef,
                description    => '',
                docs           => undef,
                language       => undef,
                lastBuildDate  => undef,
                'link'         => '',
                managingEditor => undef,
                pubDate        => undef,
                rating         => undef,
                webMaster      => undef,
            },
            image => {
                title       => undef,
                url         => undef,
                'link'      => undef,
                width       => undef,
                height      => undef,
                description => undef,
            },
            skipDays  => {day  => undef,},
            skipHours => {hour => undef,},
            textinput => {
                title       => undef,
                description => undef,
                name        => undef,
                'link'      => undef,
            },
        },
        "2.0" => {
            channel => {
                title          => '',
                'link'         => '',
                description    => '',
                language       => undef,
                copyright      => undef,
                managingEditor => undef,
                webMaster      => undef,
                pubDate        => undef,
                lastBuildDate  => undef,
                category       => undef,
                generator      => undef,
                docs           => undef,
                cloud          => '',
                ttl            => undef,
                image          => '',
                textinput      => '',
                skipHours      => '',
                skipDays       => '',
            },
            image => {
                title       => undef,
                url         => undef,
                'link'      => undef,
                width       => undef,
                height      => undef,
                description => undef,
            },
            skipDays  => {day  => undef,},
            skipHours => {hour => undef,},
            textinput => {
                title       => undef,
                description => undef,
                name        => undef,
                'link'      => undef,
            },
        },
        'default' => {
            channel => {
                title       => '',
                description => '',
                link        => '',
            },
            image => {
                title => undef,
                url   => undef,
                link  => undef,
            },
            textinput => {
                title       => undef,
                description => undef,
                name        => undef,
                link        => undef,
            },
        },
    };
}

my %languages = (
    'af'    => 'Afrikaans',
    'sq'    => 'Albanian',
    'eu'    => 'Basque',
    'be'    => 'Belarusian',
    'bg'    => 'Bulgarian',
    'ca'    => 'Catalan',
    'zh-cn' => 'Chinese (Simplified)',
    'zh-tw' => 'Chinese (Traditional)',
    'hr'    => 'Croatian',
    'cs'    => 'Czech',
    'da'    => 'Danish',
    'nl'    => 'Dutch',
    'nl-be' => 'Dutch (Belgium)',
    'nl-nl' => 'Dutch (Netherlands)',
    'en'    => 'English',
    'en-au' => 'English (Australia)',
    'en-bz' => 'English (Belize)',
    'en-ca' => 'English (Canada)',
    'en-ie' => 'English (Ireland)',
    'en-jm' => 'English (Jamaica)',
    'en-nz' => 'English (New Zealand)',
    'en-ph' => 'English (Phillipines)',
    'en-za' => 'English (South Africa)',
    'en-tt' => 'English (Trinidad)',
    'en-gb' => 'English (United Kingdom)',
    'en-us' => 'English (United States)',
    'en-zw' => 'English (Zimbabwe)',
    'fo'    => 'Faeroese',
    'fi'    => 'Finnish',
    'fr'    => 'French',
    'fr-be' => 'French (Belgium)',
    'fr-ca' => 'French (Canada)',
    'fr-fr' => 'French (France)',
    'fr-lu' => 'French (Luxembourg)',
    'fr-mc' => 'French (Monaco)',
    'fr-ch' => 'French (Switzerland)',
    'gl'    => 'Galician',
    'gd'    => 'Gaelic',
    'de'    => 'German',
    'de-at' => 'German (Austria)',
    'de-de' => 'German (Germany)',
    'de-li' => 'German (Liechtenstein)',
    'de-lu' => 'German (Luxembourg)',
    'el'    => 'Greek',
    'hu'    => 'Hungarian',
    'is'    => 'Icelandic',
    'in'    => 'Indonesian',
    'ga'    => 'Irish',
    'it'    => 'Italian',
    'it-it' => 'Italian (Italy)',
    'it-ch' => 'Italian (Switzerland)',
    'ja'    => 'Japanese',
    'ko'    => 'Korean',
    'mk'    => 'Macedonian',
    'no'    => 'Norwegian',
    'pl'    => 'Polish',
    'pt'    => 'Portuguese',
    'pt-br' => 'Portuguese (Brazil)',
    'pt-pt' => 'Portuguese (Portugal)',
    'ro'    => 'Romanian',
    'ro-mo' => 'Romanian (Moldova)',
    'ro-ro' => 'Romanian (Romania)',
    'ru'    => 'Russian',
    'ru-mo' => 'Russian (Moldova)',
    'ru-ru' => 'Russian (Russia)',
    'sr'    => 'Serbian',
    'sk'    => 'Slovak',
    'sl'    => 'Slovenian',
    'es'    => 'Spanish',
    'es-ar' => 'Spanish (Argentina)',
    'es-bo' => 'Spanish (Bolivia)',
    'es-cl' => 'Spanish (Chile)',
    'es-co' => 'Spanish (Colombia)',
    'es-cr' => 'Spanish (Costa Rica)',
    'es-do' => 'Spanish (Dominican Republic)',
    'es-ec' => 'Spanish (Ecuador)',
    'es-sv' => 'Spanish (El Salvador)',
    'es-gt' => 'Spanish (Guatemala)',
    'es-hn' => 'Spanish (Honduras)',
    'es-mx' => 'Spanish (Mexico)',
    'es-ni' => 'Spanish (Nicaragua)',
    'es-pa' => 'Spanish (Panama)',
    'es-py' => 'Spanish (Paraguay)',
    'es-pe' => 'Spanish (Peru)',
    'es-pr' => 'Spanish (Puerto Rico)',
    'es-es' => 'Spanish (Spain)',
    'es-uy' => 'Spanish (Uruguay)',
    'es-ve' => 'Spanish (Venezuela)',
    'sv'    => 'Swedish',
    'sv-fi' => 'Swedish (Finland)',
    'sv-se' => 'Swedish (Sweden)',
    'tr'    => 'Turkish',
    'uk'    => 'Ukranian'
);

# define required elements for RSS 0.9
my $_REQ_v0_9 = {
    channel => {
        "title"       => [1, 40],
        "description" => [1, 500],
        "link"        => [1, 500]
    },
    image => {
        "title" => [1, 40],
        "url"   => [1, 500],
        "link"  => [1, 500]
    },
    item => {
        "title" => [1, 100],
        "link"  => [1, 500]
    },
    textinput => {
        "title"       => [1, 40],
        "description" => [1, 100],
        "name"        => [1, 500],
        "link"        => [1, 500]
    }
};

# define required elements for RSS 0.91
my $_REQ_v0_9_1 = {
    channel => {
        "title"          => [1, 100],
        "description"    => [1, 500],
        "link"           => [1, 500],
        "language"       => [1, 5],
        "rating"         => [0, 500],
        "copyright"      => [0, 100],
        "pubDate"        => [0, 100],
        "lastBuildDate"  => [0, 100],
        "docs"           => [0, 500],
        "managingEditor" => [0, 100],
        "webMaster"      => [0, 100],
    },
    image => {
        "title"       => [1, 100],
        "url"         => [1, 500],
        "link"        => [0, 500],
        "width"       => [0, 144],
        "height"      => [0, 400],
        "description" => [0, 500]
    },
    item => {
        "title"       => [1, 100],
        "link"        => [1, 500],
        "description" => [0, 500]
    },
    textinput => {
        "title"       => [1, 100],
        "description" => [1, 500],
        "name"        => [1, 20],
        "link"        => [1, 500]
    },
    skipHours => {"hour" => [1, 23]},
    skipDays  => {"day"  => [1, 10]}
};

# define required elements for RSS 2.0
my $_REQ_v2_0 = {
    channel => {
        "title"          => [1, 100],
        "description"    => [1, 500],
        "link"           => [1, 500],
        "language"       => [0, 5],
        "rating"         => [0, 500],
        "copyright"      => [0, 100],
        "pubDate"        => [0, 100],
        "lastBuildDate"  => [0, 100],
        "docs"           => [0, 500],
        "managingEditor" => [0, 100],
        "webMaster"      => [0, 100],
    },
    image => {
        "title"       => [1, 100],
        "url"         => [1, 500],
        "link"        => [0, 500],
        "width"       => [0, 144],
        "height"      => [0, 400],
        "description" => [0, 500]
    },
    item => {
        "title"       => [1, 100],
        "link"        => [1, 500],
        "description" => [0, 500]
    },
    textinput => {
        "title"       => [1, 100],
        "description" => [1, 500],
        "name"        => [1, 20],
        "link"        => [1, 500]
    },
    skipHours => {"hour" => [1, 23]},
    skipDays  => {"day"  => [1, 10]}
};

my $namespace_map = {
    rss10 => 'http://purl.org/rss/1.0/',
    rss09 => 'http://my.netscape.com/rdf/simple/0.9/',

    # rss091 => 'http://purl.org/rss/1.0/modules/rss091/',
    rss20 => 'http://backend.userland.com/blogChannelModule',
};

my %syn_ok_fields = (
    'updateBase'      => '',
    'updateFrequency' => '',
    'updatePeriod'    => '',
);

my %dc_ok_fields = (
    'title'       => '',
    'creator'     => '',
    'subject'     => '',
    'description' => '',
    'publisher'   => '',
    'contributor' => '',
    'date'        => '',
    'type'        => '',
    'format'      => '',
    'identifier'  => '',
    'source'      => '',
    'language'    => '',
    'relation'    => '',
    'coverage'    => '',
    'rights'      => '',
);

my %rdf_resource_fields = (
    'http://webns.net/mvcb/' => {
        'generatorAgent' => 1,
        'errorReportsTo' => 1
    },
    'http://purl.org/rss/1.0/modules/annotate/' => {'reference' => 1},
    'http://my.theinfo.org/changed/1.0/rss/'    => {'server'    => 1}
);

my %empty_ok_elements = (enclosure => 1,);

sub _get_default_modules {
    return {
        'http://purl.org/rss/1.0/modules/syndication/' => 'syn',
        'http://purl.org/dc/elements/1.1/'             => 'dc',
        'http://purl.org/rss/1.0/modules/taxonomy/'    => 'taxo',
        'http://webns.net/mvcb/'                       => 'admin',
        'http://purl.org/rss/1.0/modules/content/'     => 'content',
    };
}

sub _get_default_rss_2_0_modules {
    return {'http://backend.userland.com/blogChannelModule' => 'blogChannel',};
}

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(
        Namespaces    => 1,
        NoExpand      => 1,
        ParseParamEnt => 0,
        Handlers      => {
            Char    => \&handle_char,
            XMLDecl => \&handle_dec,
            Start   => \&handle_start,
            End     => \&_handle_end,
        }
    );

    bless $self, $class;

    $self->_initialize(@_);

    return $self;
}

sub _get_init_default_key_assignments {
    return [
        {key => "version",       default => '1.0',},
        {key => "encode_output", default => 1,},
        {key => "output",        default => "",},
        {key => "encoding",      default => "UTF-8",},
    ];
}

sub _initialize {
    my $self = shift;
    my %hash = @_;

    # internal hash
    $self->{_internal} = {};

    # init num of items to 0
    $self->{num_items} = 0;

    # adhere to Netscape limits; no by default
    $self->{'strict'} = 0;

    # initialize items
    $self->{items} = [];

    # namespaces
    $self->{namespaces}    = {};
    $self->{rss_namespace} = '';

    $self->{_output} = "";

    foreach my $k (@{$self->_get_init_default_key_assignments()})
    {
        my $key = $k->{key};
        $self->{$key} = exists($hash{$key}) ? $hash{$key} : $k->{default};
    }


    # modules
    $self->{modules} = (
        ($self->{version} eq "2.0")
        ? $self->_get_default_rss_2_0_modules()
        : $self->_get_default_modules()
    );

    # stylesheet
    if (exists($hash{stylesheet})) {
        $self->{stylesheet} = $hash{stylesheet};
    }

    my $ok_fields = $self->_get_ok_fields();

    my $ver_ok_fields =
      exists($ok_fields->{$self->{version}})
      ? $ok_fields->{$self->{version}}
      : $ok_fields->{default};

    while (my ($k, $v) = each(%$ver_ok_fields)) {
        $self->{$k} = +{%{$v}};
    }

    if ($self->{version} eq "2.0") {
        $self->{namespaces}->{'blogChannel'} = "http://backend.userland.com/blogChannelModule";
    }
}

sub _rss_out_version {
    my $self = shift;

    if (@_) {
        $self->{_rss_out_version} = shift;
    }
    return $self->{_rss_out_version};
}

sub _out {
    my ($self, $string) = @_;
    $self->{_output} .= $string;
    return;
}

sub _out_tag {
    my ($self, $tag, $inner) = @_;

    return $self->_out("<$tag>" . $self->_encode($inner) . "</$tag>\n");
}

sub _out_ns_tag {
    my ($self, $prefix, $tag, $inner) = @_;

    return $self->_out_tag("${prefix}:${tag}", $inner);
}

sub _out_defined_tag {
    my ($self, $tag, $inner) = @_;

    if (defined($inner)) {
        $self->_out_tag($tag, $inner);
    }

    return;
}

sub _out_inner_tag {
    my ($self, $params, $tag) = @_;

    if (ref($params) eq "") {
        $params = {'ext' => $params, 'defined' => 0,};
    }

    my $ext_tag = $params->{ext};

    if (ref($ext_tag) eq "") {
        $ext_tag = $self->{$ext_tag};
    }

    my $value = $ext_tag->{$tag};

    if ($params->{defined} ? defined($value) : 1) {
        $self->_out_tag($tag, $value);
    }

    return;
}

sub _output_item_tag {
    my ($self, $item, $tag) = @_;

    return $self->_out_tag($tag, $item->{$tag});
}

sub _output_def_image_tag {
    my ($self, $tag) = @_;

    my $ext_tag = "image";
    if (defined($self->{$ext_tag}->{$tag})) {
        $self->_out_inner_tag($ext_tag, $tag);
    }
    return;
}

sub _output_multiple_tags {
    my ($self, $ext_tag, $tags_ref) = @_;

    foreach my $tag (@$tags_ref) {
        $self->_out_inner_tag($ext_tag, $tag);
    }

    return;
}

sub _output_common_textinput_sub_elements {
    my $self = shift;

    $self->_output_multiple_tags("textinput", [qw(title description name link)],);
}

sub _out_textinput_rss_1_0_elems {
    my $self = shift;

    $self->_out_dc_elements($self->textinput());

    # Ad-hoc modules
    # TODO : Should this follow the %rdf_resources conventions of the items'
    # and channel's modules' support ?
    while (my ($url, $prefix) = each %{$self->{modules}}) {
        next if $prefix =~ /^(dc|syn|taxo)$/;
        while (my ($el, $value) = each %{$self->{textinput}->{$prefix}}) {
            $self->_out_ns_tag($prefix, $el, $value);
        }
    }
}

sub _start_top_elem {
    my ($self, $tag, $about_sub) = @_;
    
    my $about = "";
    if ($self->_rss_out_version() eq "1.0") {
        $about = ' rdf:about="' . $self->_encode($about_sub->()) . '"';
    }

    return $self->_out("<$tag$about>\n");
}

sub _output_complete_textinput {
    my $self = shift;

    my $master_tag = ($self->_rss_out_version() eq "2.0") ? "textInput" : "textinput";

    if (defined(my $link = $self->textinput('link'))) {
        $self->_start_top_elem($master_tag, 
            sub { $link }
        );

        $self->_output_common_textinput_sub_elements();

        if ($self->_rss_out_version() eq "1.0") {
            $self->_out_textinput_rss_1_0_elems();
        }

        $self->_end_top_level_elem($master_tag);
    }

    return;
}

sub _flush_output {
    my $self = shift;

    my $ret = $self->{_output};
    $self->{_output} = "";

    return $ret;
}

sub add_module {
    my $self = shift;
    my $hash = {@_};

    $hash->{prefix} =~ /^[a-z_][a-z0-9.\-_]*$/
      or croak "a namespace prefix should look like [a-z_][a-z0-9.\\-_]*";

    $hash->{uri}
      or croak "a URI must be provided in a namespace declaration";

    $self->{modules}->{$hash->{uri}} = $hash->{prefix};
}

sub add_item {
    my $self = shift;
    my $hash = {@_};

    # strict Netscape Netcenter length checks
    if ($self->{'strict'}) {

        # make sure we have a title and link
        croak "title and link elements are required"
          unless ($hash->{title} && $hash->{'link'});

        # check string lengths
        croak "title cannot exceed 100 characters in length"
          if (length($hash->{title}) > 100);
        croak "link cannot exceed 500 characters in length"
          if (length($hash->{'link'}) > 500);
        croak "description cannot exceed 500 characters in length"
          if (exists($hash->{description})
            && length($hash->{description}) > 500);

        # make sure there aren't already 15 items
        croak "total items cannot exceed 15 " if (@{$self->{items}} >= 15);
    }

    # add the item to the list
    if (defined($hash->{mode}) && $hash->{mode} eq 'insert') {
        unshift(@{$self->{items}}, $hash);
    }
    else {
        push(@{$self->{items}}, $hash);
    }

    # return reference to the list of items
    return $self->{items};
}


sub _date_from_dc_date {
    my ($self, $string) = @_;
    my $f = DateTime::Format::W3CDTF->new();
    return $f->parse_datetime($string);
}

sub _date_from_rss2 {
    my ($self, $string) = @_;
    my $f = DateTime::Format::Mail->new();
    return $f->parse_datetime($string);
}

sub _date_to_rss2 {
    my ($self, $date) = @_;

    my $pf = DateTime::Format::Mail->new();
    return $pf->format_datetime($date);
}

sub _date_to_dc_date {
    my ($self, $date) = @_;

    my $pf = DateTime::Format::W3CDTF->new();
    return $pf->format_datetime($date);
}

sub _channel_dc
{
    my ($self, $key) = @_;

    if ($self->channel('dc')) {
        return $self->channel('dc')->{$key};
    }
    else {
        return undef;
    }
}

sub _channel_syn
{
    my ($self, $key) = @_;

    if ($self->channel('syn')) {
        return $self->channel('syn')->{$key};
    }
    else {
        return undef;
    }
}

sub _calc_lastBuildDate_2_0 {
    my $self = shift;
    if (defined(my $d = $self->_channel_dc('date'))) {
        return $self->_date_to_rss2($self->_date_from_dc_date($d));
    }
    else
    {
        # If lastBuildDate is undef we can still return it because we
        # need to return undef.
        return $self->channel("lastBuildDate");
    }
}

sub _calc_lastBuildDate_0_9_1 {
    my $self = shift;
    if (defined(my $d = $self->channel('lastBuildDate'))) {
        return $d;
    }
    elsif (defined(my $d2 = $self->_channel_dc('date'))) {
        return $self->_date_to_rss2($self->_date_from_dc_date($d2));
    }
    else {
        return undef;
    }
}


sub _calc_pubDate {
    my $self = shift;

    if (defined(my $d = $self->channel('pubDate'))) {
        return $d;
    }
    elsif (defined(my $d2 = $self->_channel_dc('date'))) {
        return $self->_date_to_rss2($self->_date_from_dc_date($d2));
    }
    else {
        return undef;
    }
}

sub _get_other_dc_date {
    my $self = shift;

    if (defined(my $d1 = $self->channel('pubDate'))) {
        return $d1;
    }
    elsif (defined(my $d2 = $self->channel('lastBuildDate'))) {
        return $d2;
    }
    else {
        return undef;
    }
}

sub _calc_dc_date {
    my $self = shift;

    if (defined(my $d1 = $self->_channel_dc('date'))) {
        return $d1;
    }
    else {
        my $date = $self->_get_other_dc_date();

        if (!defined($date)) {
            return undef;
        }
        else {
            return $self->_date_to_dc_date($self->_date_from_rss2($date));
        }
    }
}

sub _output_xml_declaration {
    my $self = shift;

    $self->_out('<?xml version="1.0" encoding="' . $self->{encoding} . '"?>' . "\n");
    if (defined($self->{stylesheet})) {
        my $style_url = $self->_encode($self->{stylesheet});
        $self->_out(qq{<?xml-stylesheet type="text/xsl" href="$style_url"?>\n});
    }

    $self->_out("\n");

    return undef;
}

sub _out_image_title_and_url {
    my $self = shift;

    return $self->_output_multiple_tags({ext => "image"}, [qw(title url)]);
}

sub _start_image {
    my $self = shift;

    $self->_start_top_elem("image", sub { $self->image('url') });

    $self->_out_image_title_and_url();

    $self->_output_def_image_tag("link");

    return;
}

sub _start_item {
    my ($self, $item) = @_;

    $self->_start_top_elem("item", sub { $self->_get_item_about($item)});

    $self->_output_common_item_tags($item);

    return;
}

sub _end_top_level_elem {
    my ($self, $elem) = @_;

    $self->_out("</$elem>\n");
}

sub _end_item {
    shift->_end_top_level_elem("item");
}

sub _end_image {
    shift->_end_top_level_elem("image");
}

sub _end_channel {
    shift->_end_top_level_elem("channel");
}


sub _output_def_item_tag {
    my ($self, $item, $tag) = @_;

    if (defined($item->{$tag})) {
        $self->_output_item_tag($item, $tag);
    }

    return;
}

# Outputs the common item tags for RSS 0.9.1 and above.
sub _output_common_item_tags {
    my ($self, $item) = @_;

    $self->_output_multiple_tags({ext => $item, 'defined' => ($self->_rss_out_version() eq "2.0")},
        [qw(title link)],);

    if ($self->_rss_out_version() ne "0.9") {
        $self->_output_def_item_tag($item, "description");
    }

    return;
}

sub _output_channel_tag {
    my ($self, $tag) = @_;

    return $self->_out_inner_tag("channel", $tag);
}

sub _output_common_channel_elements {
    my $self = shift;

    $self->_output_multiple_tags("channel", [qw(title link description)],);
}


sub _out_language {
    my $self = shift;

    return $self->_out_channel_self_dc_field("language");
}

sub _start_channel {
    my $self = shift;

    $self->_start_top_elem("channel", sub { $self->_get_channel_rdf_about });

    $self->_output_common_channel_elements();

    if ($self->_rss_out_version() ne "0.9") {
        $self->_out_language();
    }

    return;
}

# Calculates a channel field that has a dc: and non-dc alternative,
# prefering the dc: one.
sub _calc_channel_dc_field {
    my ($self, $dc_key, $non_dc_key) = @_;

    my $dc_value = $self->_channel_dc($dc_key);

    return defined($dc_value) ? $dc_value : $self->channel($non_dc_key);
}

sub _prefer_dc {
    my $self = shift;

    if (@_) {
        $self->{_prefer_dc} = shift;
    }
    return $self->{_prefer_dc};
}


sub _out_channel_dc_field {
    my ($self, $dc_key, $non_dc_key) = @_;

    return $self->_out_defined_tag(
        ($self->_prefer_dc() ? "dc:$dc_key" : $non_dc_key),
        $self->_calc_channel_dc_field($dc_key, $non_dc_key)
    );
}

sub _out_channel_self_dc_field {
    my ($self, $key) = @_;

    return $self->_out_channel_dc_field($key, $key);
}

sub _out_managing_editor {
    my $self = shift;

    return $self->_out_channel_dc_field("publisher", "managingEditor");
}

sub _out_webmaster {
    my $self = shift;

    return $self->_out_channel_dc_field("creator", "webMaster");
}

sub _out_copyright {
    my $self = shift;

    return $self->_out_channel_dc_field("rights", "copyright");
}

sub _out_editors {
    my $self = shift;

    $self->_out_managing_editor;
    $self->_out_webmaster;
}

sub _get_channel_rdf_about {
    my $self = shift;

    if (defined(my $about = $self->channel('about'))) {
        return $about;
    }
    else {
        return $self->channel('link');
    }
}

sub _output_taxo_topics {
    my ($self, $elem) = @_;

    if (my $list = $elem->{'taxo'}) {
        $self->_out("<taxo:topics>\n  <rdf:Bag>\n");
        foreach my $taxo (@{$list}) {
            $self->_out("    <rdf:li resource=\"" . $self->_encode($taxo) . "\" />\n");
        }
        $self->_out("  </rdf:Bag>\n</taxo:topics>\n");
    }

    return;
}

# Output the Dublin core properties of a certain elements (channel, image,
# textinput, item).

sub _out_dc_elements {
    my $self      = shift;
    my $elem      = shift;
    my $skip_hash = shift || {};

    foreach my $dc (keys %dc_ok_fields) {
        next if $skip_hash->{$dc};

        $self->_out_defined_tag("dc:$dc", $elem->{dc}->{$dc});
    }

    return;
}

# Output the Ad-hoc modules
sub _out_modules_elements {
    my ($self, $super_elem) = @_;

    # Ad-hoc modules
    while (my ($url, $prefix) = each %{$self->{modules}}) {
        next if $prefix =~ /^(dc|syn|taxo)$/;
        while (my ($el, $value) = each %{$super_elem->{$prefix}}) {
            if (    exists($rdf_resource_fields{$url})
                and exists($rdf_resource_fields{$url}{$el}))
            {
                $self->_out(
                    qq{<${prefix}:${el} rdf:resource="} . $self->_encode($value) . qq{" />\n});
            }
            else {
                $self->_out_ns_tag($prefix, $el, $value);
            }
        }
    }

    return;
}

sub _out_complete_outer_tag {
    my ($self, $outer, $inner) = @_;

    my $value = $self->{$outer}->{$inner};

    if (defined($value)) {
        $self->_out("<$outer>\n");
        $self->_out_tag($inner, $value);
        $self->_end_top_level_elem($outer);
    }
}

sub _out_skip_tag {
    my ($self, $what) = @_;

    return $self->_out_complete_outer_tag("skip\u${what}s", $what);
}

sub _out_skip_hours {
    return shift->_out_skip_tag("hour");
}

sub _out_skip_days {
    return shift->_out_skip_tag("day");
}

sub _get_item_about
{
    my ($self, $item) = @_;
    return defined($item->{'about'}) ? $item->{'about'} : $item->{'link'};
}

sub _output_defined_image {
    my $self = shift;

    $self->_start_image();

    my $ver = $self->_rss_out_version();

    if (($ver eq "0.91") || ($ver eq "2.0")) {
        # link, image width, image height and description
        $self->_output_multiple_tags(
            {ext => "image", 'defined' => 1},
            [qw(width height description)],
        );
    }

    if ($ver eq "1.0") {
        # image width
        #$output .= '<rss091:width>'.$self->{image}->{width}.'</rss091:width>'."\n"
        #    if $self->{image}->{width};

        # image height
        #$output .= '<rss091:height>'.$self->{image}->{height}.'</rss091:height>'."\n"
        #    if $self->{image}->{height};

        # description
        #$output .= '<rss091:description>'.$self->{image}->{description}.'</rss091:description>'."\n"
        #    if $self->{image}->{description};

        $self->_out_dc_elements($self->image());
    }

    if (($ver eq "1.0") || ($ver eq "2.0"))
    {
        # Ad-hoc modules for images
        $self->_out_modules_elements($self->image());
    }

    $self->_end_image();
}

sub _is_image_defined {
    my $self = shift;

    return defined ($self->image('url'));
}

sub _output_complete_image {
    my $self = shift;

    if ($self->_is_image_defined())
    {
        $self->_output_defined_image();
    }
}

sub _out_seq_items {
    my $self = shift;

    # Seq items
    $self->_out("<items>\n <rdf:Seq>\n");

    foreach my $item (@{$self->{items}}) {
        $self->_out('  <rdf:li rdf:resource="' .
            $self->_encode($self->_get_item_about($item)) .
            '" />' . "\n");
    }

    $self->_out(" </rdf:Seq>\n</items>\n");
}

sub _get_rdf_decl_mappings
{
    my $self = shift;

    my $modules = $self->{modules};

    return
    [
        (
            ($self->_rss_out_version() eq "1.0") ?
            (
                ["rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#"],
                [undef, "http://purl.org/rss/1.0/"]
            ) :
            ()
        ),
        map { [$modules->{$_}, $_] } keys(%$modules)
    ];
}

sub _render_xmlns {
    my ($self, $prefix, $url) = @_;

    my $pp = defined($prefix) ? ":$prefix" : "";
    
    return qq{ xmlns$pp="$url"\n};
}

sub _get_rdf_xmlnses {
    my $self = shift;

    return 
        join("",
            map { $self->_render_xmlns(@$_) }
            @{$self->_get_rdf_decl_mappings}
        );
}

sub _get_rdf_decl_open_tag
{
    my $self = shift;

    return ($self->_rss_out_version() eq "1.0") ? "<rdf:RDF\n" : 
        qq{<rss version="2.0"\n};
}

sub _get_0_9_rdf_decl
{
    return
    qq{<rdf:RDF\nxmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"\n} .
    qq{xmlns="http://my.netscape.com/rdf/simple/0.9/">\n\n};
}

sub _get_0_9_1_rdf_decl
{
    return
    qq{<!DOCTYPE rss PUBLIC "-//Netscape Communications//DTD RSS 0.91//EN"\n} .
    qq{            "http://my.netscape.com/publish/formats/rss-0.91.dtd">\n\n} .
    qq{<rss version="0.91">\n\n};
}

sub _get_rdf_decl
{
    my $self = shift;

    my $ver = $self->_rss_out_version();

    if ($ver eq "0.9")
    {
        return $self->_get_0_9_rdf_decl();
    }
    elsif ($ver eq "0.91")
    {
        return $self->_get_0_9_1_rdf_decl();
    }
    else
    {
        return $self->_get_rdf_decl_open_tag() .
            $self->_get_rdf_xmlnses() . ">\n\n";
    }
}

sub _out_rdf_decl
{
    my $self = shift;

    return $self->_out($self->_get_rdf_decl);
}

sub _out_guid {
    my ($self, $item) = @_;

    # The unique identifier. Use 'permaLink' for an external
    # identifier, or 'guid' for a internal string.
    # (I call it permaLink in the hash for purposes of clarity.)

    for my $guid (qw(permaLink guid)) {
        if (defined $item->{$guid}) {
            $self->_out('<guid isPermaLink="'
              . ($guid eq 'permaLink' ? 'true' : 'false') . '">'
              . $self->_encode($item->{$guid})
              . '</guid>' . "\n");
            last;
        }
    }
}

sub _out_item_source {
    my ($self, $item) = @_;
    
    if (defined $item->{source} && defined $item->{sourceUrl}) {
        $self->_out('<source url="'
          . $self->_encode($item->{sourceUrl}) . '">'
          . $self->_encode($item->{source})
          . "</source>\n");
    }
}

sub _out_item_enclosure {
    my ($self, $item) = @_;

    if (my $e = $item->{enclosure}) {
        $self->_out(
            "<enclosure " .
            join(' ', 
                map { "$_=\"" . $self->_encode($e->{$_}) . '"' } keys(%$e)
            ) .
            " />\n"
        );
    }
}

sub _get_filtered_items {
    my ($self) = @_;

    my $items = $self->{items};

    if ($self->_rss_out_version() eq "2.0") {
        return
        [
            grep {exists($_->{title}) || exists($_->{description})}
                @$items
        ];
    }
    else {
        return $items;
    }
}

sub _out_item_2_0_tags {
    my ($self, $item) = @_;

    foreach my $tag (qw(author category comments)) {
        $self->_output_def_item_tag($item, $tag);
    }

    $self->_out_guid($item);

    $self->_output_def_item_tag($item, "pubDate");

    $self->_out_item_source($item);

    $self->_out_item_enclosure($item);
}

sub _output_single_item {
    my ($self, $item) = @_;

    my $ver = $self->_rss_out_version();

    $self->_start_item($item);

    if ($ver eq "2.0") {
        $self->_out_item_2_0_tags($item);
    }

    if ($ver eq "1.0") {
        $self->_out_dc_elements($item);

        # Taxonomy module
        $self->_output_taxo_topics($item);
    }

    if (($ver eq "1.0") || ($ver eq "2.0")) {
        $self->_out_modules_elements($item);
    }

    $self->_end_item($item);
}

sub _output_items {
    my $self = shift;

    foreach my $item (@{$self->_get_filtered_items}) {
        $self->_output_single_item($item);
    }
}

sub _output_main_elements {
    my $self = shift;

    $self->_output_complete_image();

    $self->_output_items;

    $self->_output_complete_textinput();
}

# Outputs the last elements - for RSS versions 0.9.1 and 2.0 .
sub _out_last_elements {
    my $self = shift;

    $self->_out("\n");

    $self->_output_main_elements;

    $self->_out_skip_hours();

    $self->_out_skip_days();

    $self->_end_channel;
}

sub _calc_prefer_dc {
    my $self = shift;
    return ($self->_rss_out_version() eq "1.0");
}

sub _output_xml_start {
    my ($self, $ver) = @_;

    $self->_rss_out_version($ver);
    $self->_prefer_dc($self->_calc_prefer_dc());

    $self->_output_xml_declaration();

    $self->_out_rdf_decl;

    $self->_start_channel();
}

sub _get_end_tag_map
{
    return
    { 
        (map { $_ => "rdf:RDF" } qw(0.9 1.0)),
        (map { $_ => "rss" } qw(0.91 2.0)),
    };
}

sub _get_end_tag {
    my $self = shift;

    return $self->_get_end_tag_map()->{$self->_rss_out_version()};
}

sub _out_end_tag {
    my $self = shift;

    return $self->_out("</" . $self->_get_end_tag() . ">");
}

sub _out_all_modules_elems {
    my $self = shift;

    # Dublin Core module
    $self->_out_dc_elements($self->channel(),
        {map { $_ => 1 } qw(language creator publisher rights date)},
    );

    # Syndication module
    foreach my $syn (keys %syn_ok_fields) {
        if (defined(my $value = $self->_channel_syn($syn))) {
            $self->_out_ns_tag("syn", $syn, $value);
        }
    }

    # Taxonomy module
    $self->_output_taxo_topics($self->channel());

    $self->_out_modules_elements($self->channel());
}

sub _output_0_9_rss_middle {
    my $self = shift;

    $self->_end_channel();
    $self->_output_main_elements;
}

sub _output_0_9_1_rss_middle {
    my $self = shift;

    # PICS rating
    $self->_out_def_chan_tags("rating");

    $self->_out_copyright();

    # publication date
    $self->_out_defined_tag("pubDate", $self->_calc_pubDate());

    # last build date
    $self->_out_defined_tag("lastBuildDate", $self->_calc_lastBuildDate_0_9_1());

    # external CDF URL
    $self->_out_def_chan_tags("docs");

    $self->_out_editors;

    $self->_out_last_elements;
}

sub _output_1_0_rss_middle {
    my $self = shift;

    # PICS rating - Dublin Core has not decided how to incorporate PICS ratings yet
    #$$output .= '<rss091:rating>'.$self->{channel}->{rating}.'</rss091:rating>'."\n"
    #$if $self->{channel}->{rating};

    $self->_out_copyright();

    # publication date
    $self->_out_defined_tag("dc:date", $self->_calc_dc_date());

    # external CDF URL
    #$output .= '<rss091:docs>'.$self->{channel}->{docs}.'</rss091:docs>'."\n"
    #if $self->{channel}->{docs};

    $self->_out_editors;

    $self->_out_all_modules_elems;

    $self->_out_seq_items();

    if ($self->_is_image_defined()) {
        $self->_out('<image rdf:resource="' .
            $self->_encode($self->{image}->{url}) . "\" />\n"
        );
    }

    if (defined($self->{textinput}->{'link'})) {
        $self->_out('<textinput rdf:resource="'
          . $self->_encode($self->{textinput}->{'link'}) . "\" />\n"
        );
    }

    $self->_end_channel;

    $self->_output_main_elements;
}

sub _to_array_ref {
    my ($self, $items) = @_;
    return +(ref($items) eq "ARRAY") ? $items : [$items];
}

sub _out_def_chan_tags {
    my ($self, $tags) = @_;
    return $self->_output_multiple_tags(
        {ext => "channel", 'defined' => 1}, 
        $self->_to_array_ref($tags)
    );
}

sub _output_2_0_rss_middle {
    my $self = shift;

    # PICS rating
    # Not supported by RSS 2.0
    # $output .= '<rating>'.$self->{channel}->{rating}.'</rating>'."\n"
    #    if $self->{channel}->{rating};

    # copyright
    $self->_out_copyright();

    # publication date
    $self->_out_defined_tag("pubDate", $self->_calc_pubDate());

    $self->_out_defined_tag("lastBuildDate", $self->_calc_lastBuildDate_2_0());

    # external CDF URL
    $self->_out_def_chan_tags("docs");

    $self->_out_editors;

    $self->_out_channel_self_dc_field("category");
    $self->_out_channel_self_dc_field("generator");

    # Insert cloud support here

    # ttl
    $self->_out_channel_self_dc_field("ttl");

    $self->_out_modules_elements($self->channel());

    $self->_out_last_elements;
}

sub _get_rss_middle_method_map {
    return {
        "0.9" => '_output_0_9_rss_middle',
        "0.91" => '_output_0_9_1_rss_middle',
        "1.0" => '_output_1_0_rss_middle',
        "2.0" => '_output_2_0_rss_middle',
    };
}

sub _output_rss_middle {
    my $self = shift;

    my $method = $self->_get_rss_middle_method_map()->{$self->_rss_out_version};

    return $self->$method();
}

# $self->_render_complete_rss_output($xml_version)
#
# This function is the workhorse of the XML output and does all the work of
# rendering the RSS, delegating the work to specialised functions.
#
# It accepts the requested version number as its argument.


sub _render_complete_rss_output {
    my ($self, $ver) = @_;

    $self->_output_xml_start($ver);

    $self->_output_rss_middle;

    $self->_out_end_tag;

    return $self->_flush_output();
}

sub as_rss_0_9 {
    return shift->_render_complete_rss_output("0.9");
}

sub as_rss_0_9_1 {
    return shift->_render_complete_rss_output("0.91");
}

sub as_rss_1_0 {
    return shift->_render_complete_rss_output("1.0");
}

sub as_rss_2_0 {
    return shift->_render_complete_rss_output("2.0");
}



sub _get_output_methods_map {
    return {
        '0.9'  => "as_rss_0_9",
        '0.91' => "as_rss_0_9_1",
        '2.0'  => "as_rss_2_0",
        '1.0'  => "as_rss_1_0",
    };
}

sub _get_default_output_method {
    return "as_rss_1_0";
}

sub _get_output_method {
    my ($self, $version) = @_;

    if (my $output_method = $self->_get_output_methods_map()->{$version}) {
        return $output_method;
    }
    else {
        return $self->_get_default_output_method();
    }
}

sub _get_output_version {
    my $self = shift;
    return ($self->{output} =~ /\d/) ? $self->{output} : $self->{version};
}

sub as_string {
    my $self = shift;

    my $version = $self->_get_output_version();

    my $output_method = $self->_get_output_method($version);

    return $self->$output_method();
}

# Checks if inside a possibly namespaced element
# TODO : After increasing test coverage convert all such conditionals to this
# method.
sub _my_in_element {
    my ($self, $elem) = @_;

    return $self->within_element($elem)
      || $self->within_element($self->generate_ns_name($elem, $self->{rss_namespace}));
}

sub _get_elem_namespace_helper {
    my ($self, $el) = @_;

    my $ns = $self->namespace($el);

    return (defined($ns) ? $ns : "");
}

sub _get_elem_namespace {
    my ($self, $el) = @_;

    my $ns = _get_elem_namespace_helper(@_);

    my $verdict = (!$ns && !$self->{rss_namespace})
      || ($ns eq $self->{rss_namespace});

    return ($ns, $verdict);
}

sub _get_current_namespace {
    my $self = shift;

    return _get_elem_namespace($self, $self->current_element);
}

sub handle_char {
    my ($self, $cdata) = (@_);

    # image element
    if (_my_in_element($self, "image")) {
        my ($ns, $verdict) = _get_current_namespace($self);

        # If it's in the default namespace
        if ($verdict) {
            $self->{'image'}->{$self->current_element} .= $cdata;
        }
        else {

            # If it's in another namespace
            $self->{'image'}->{$ns}->{$self->current_element} .= $cdata;

            # If it's in a module namespace, provide a friendlier prefix duplicate
            $self->{modules}->{$ns}
              and $self->{'image'}->{$self->{modules}->{$ns}}->{$self->current_element} .= $cdata;
        }

        # item element
    }
    elsif (defined($self->{_inside_item_elem})) {
        return
          if $self->within_element(
            $self->generate_ns_name("topics", 'http://purl.org/rss/1.0/modules/taxonomy/'));

        my ($ns, $verdict) = _get_current_namespace($self);

        # If it's in the default RSS 1.0 namespace
        if ($verdict) {
            my $elem = $self->current_element;
            if (@{$self->{'items'}} < $self->{num_items}) {
                push @{$self->{items}}, {};
            }
            my $item = $self->{'items'}->[$self->{num_items} - 1];
            if ($elem eq "guid") {
                $item->{$item->{isPermaLink} ? "permaLink" : "guid"} .= $cdata;
            }
            else {
                $item->{$elem} .= $cdata;
            }
        }
        else {

            # If it's in another namespace
            $self->{'items'}->[$self->{num_items} - 1]->{$ns}->{$self->current_element} .= $cdata;

            # If it's in a module namespace, provide a friendlier prefix duplicate
            $self->{modules}->{$ns}
              and $self->{'items'}->[$self->{num_items} - 1]->{$self->{modules}->{$ns}}
              ->{$self->current_element} .= $cdata;
        }

        # textinput element
    }
    elsif (

        # We cannot call these as methods because of the catch that
        # XML::Parser uses XML::Parser::Expat to do the caching which is a
        # distinct object than our own parser.
        _my_in_element($self, "textinput") || _my_in_element($self, "textInput")
      )
    {
        my ($ns, $verdict) = _get_current_namespace($self);

        # If it's in the default namespace
        if ($verdict) {
            $self->{'textinput'}->{$self->current_element} .= $cdata;
        }
        else {

            # If it's in another namespace
            $self->{'textinput'}->{$ns}->{$self->current_element} .= $cdata;

            # If it's in a module namespace, provide a friendlier prefix duplicate
            $self->{modules}->{$ns}
              and $self->{'textinput'}->{$self->{modules}->{$ns}}->{$self->current_element}
              .= $cdata;
        }

        # skipHours element
    }
    elsif (_my_in_element($self, "skipHours")) {
        $self->{'skipHours'}->{$self->current_element} .= $cdata;

        # skipDays element
    }
    elsif (_my_in_element($self, "skipDays")) {
        $self->{'skipDays'}->{$self->current_element} .= $cdata;

        # channel element
    }
    elsif ($self->within_element("channel")
        || $self->within_element($self->generate_ns_name("channel", $self->{rss_namespace})))
    {
        return
          if $self->within_element(
            $self->generate_ns_name("topics", 'http://purl.org/rss/1.0/modules/taxonomy/'));

        my ($ns, $verdict) = _get_current_namespace($self);

        # If it's in the default namespace
        if ($verdict) {
            $self->{'channel'}->{$self->current_element} .= $cdata;
        }
        else {

            # If it's in another namespace
            $self->{'channel'}->{$ns}->{$self->current_element} .= $cdata;

            # If it's in a module namespace, provide a friendlier prefix duplicate
            $self->{modules}->{$ns}
              and $self->{'channel'}->{$self->{modules}->{$ns}}->{$self->current_element} .= $cdata;
        }
    }
}

sub handle_dec {
    my ($self, $version, $encoding, $standalone) = (@_);
    $self->{encoding} = $encoding;

    #print "ENCODING: $encoding\n";
}

sub handle_start {
    my $self    = shift;
    my $el      = shift;
    my %attribs = @_;

    # beginning of RSS 0.91
    if ($el eq 'rss') {
        if (exists($attribs{version})) {
            $self->{_internal}->{version} = $attribs{version};
        }
        else {
            croak "Malformed RSS: invalid version\n";
        }

        # beginning of RSS 1.0 or RSS 0.9
    }
    elsif ($el eq 'RDF') {
        my @prefixes = $self->new_ns_prefixes;
        foreach my $prefix (@prefixes) {
            my $uri = $self->expand_ns_prefix($prefix);
            $self->{namespaces}->{$prefix} = $uri;

            #print "$prefix = $uri\n";
        }

        # removed assumption that RSS is the default namespace - kellan, 11/5/02
        #
        foreach my $uri (values %{$self->{namespaces}}) {
            if ($namespace_map->{'rss10'} eq $uri) {
                $self->{_internal}->{version} = '1.0';
                $self->{rss_namespace} = $uri;
                last;
            }
            elsif ($namespace_map->{'rss09'} eq $uri) {
                $self->{_internal}->{version} = '0.9';
                $self->{rss_namespace} = $uri;
                last;
            }
        }

        # failed to match a namespace
        if (!defined($self->{_internal}->{version})) {
            croak "Malformed RSS: invalid version\n";
        }

        #if ($self->expand_ns_prefix('#default') =~ /\/1.0\//) {
        #    $self->{_internal}->{version} = '1.0';
        #} elsif ($self->expand_ns_prefix('#default') =~ /\/0.9\//) {
        #    $self->{_internal}->{version} = '0.9';
        #} else {
        #    croak "Malformed RSS: invalid version\n";
        #}

        # beginning of item element
    }
    elsif ($el eq 'item') {

        # deal with trouble makers who use mod_content :)

        my ($ns, $verdict) = _get_elem_namespace($self, $el);

        if ($verdict) {

            # Sanity check to make sure we don't have nested elements that
            # can confuse the parser.
            if (!defined($self->{_inside_item_elem})) {

                # increment item count
                $self->{num_items}++;
                $self->{_inside_item_elem} = $self->depth();
            }
        }

        # guid element is a permanent link unless isPermaLink attribute is set to false
    }
    elsif ($el eq 'guid') {
        $self->{'items'}->[$self->{num_items} - 1]->{'isPermaLink'} =
          !(exists($attribs{'isPermaLink'}) && ($attribs{'isPermaLink'} eq 'false'));

        # beginning of taxo li element in item element
        #'http://purl.org/rss/1.0/modules/taxonomy/' => 'taxo'
    }
    elsif (
        $self->within_element(
            $self->generate_ns_name("topics", 'http://purl.org/rss/1.0/modules/taxonomy/')
        )
        && $self->within_element($self->generate_ns_name("item", $namespace_map->{'rss10'}))
        && $self->current_element eq 'Bag'
        && $el                    eq 'li'
      )
    {

        #print "taxo: ", $attribs{'resource'},"\n";
        push(@{$self->{'items'}->[$self->{num_items} - 1]->{'taxo'}}, $attribs{'resource'});
        $self->{'modules'}->{'http://purl.org/rss/1.0/modules/taxonomy/'} = 'taxo';

        # beginning of taxo li in channel element
    }
    elsif (
        $self->within_element(
            $self->generate_ns_name("topics", 'http://purl.org/rss/1.0/modules/taxonomy/')
        )
        && $self->within_element($self->generate_ns_name("channel", $namespace_map->{'rss10'}))
        && $self->current_element eq 'Bag'
        && $el                    eq 'li'
      )
    {
        push(@{$self->{'channel'}->{'taxo'}}, $attribs{'resource'});
        $self->{'modules'}->{'http://purl.org/rss/1.0/modules/taxonomy/'} = 'taxo';
    }

    # beginning of a channel element that stores its info in rdf:resource
    elsif ( $self->namespace($el)
        and exists($rdf_resource_fields{$self->namespace($el)})
        and exists($rdf_resource_fields{$self->namespace($el)}{$el})
        and $self->current_element eq 'channel')
    {
        my $ns = $self->namespace($el);

        # Commented out by shlomif - the RSS namespaces are not present
        # in the %rdf_resource_fields so this condition always evaluates
        # to false.
        # if ( $ns eq $self->{rss_namespace} ) {
        #     $self->{channel}->{$el} = $attribs{resource};
        # }
        # else

        {
            $self->{channel}->{$ns}->{$el} = $attribs{resource};

            # add short cut
            #
            if (exists($self->{modules}->{$ns})) {
                $ns = $self->{modules}->{$ns};
                $self->{channel}->{$ns}->{$el} = $attribs{resource};
            }
        }
    }

    # beginning of an item element that stores its info in rdf:resource
    elsif ( $self->namespace($el)
        and exists($rdf_resource_fields{$self->namespace($el)})
        and exists($rdf_resource_fields{$self->namespace($el)}{$el})
        and $self->current_element eq 'item')
    {
        my $ns = $self->namespace($el);

        # Commented out by shlomif - the RSS namespaces are not present
        # in the %rdf_resource_fields so this condition always evaluates
        # to false.
        # if ( $ns eq $self->{rss_namespace} ) {
        #   $self->{'items'}->[$self->{num_items}-1]->{ $el } = $attribs{resource};
        # }
        # else
        {
            $self->{'items'}->[$self->{num_items} - 1]->{$ns}->{$el} = $attribs{resource};

            # add short cut
            #
            if (exists($self->{modules}->{$ns})) {
                $ns = $self->{modules}->{$ns};
                $self->{'items'}->[$self->{num_items} - 1]->{$ns}->{$el} = $attribs{resource};
            }
        }
    }
    elsif ($empty_ok_elements{$el} and $self->current_element eq 'item') {
        $self->{items}->[$self->{num_items} - 1]->{$el} = \%attribs;
    }
}

sub _handle_end {
    my ($self, $el) = @_;

    if (defined($self->{_inside_item_elem})
        && $self->{_inside_item_elem} == $self->depth())
    {
        delete($self->{_inside_item_elem});
    }
}

sub _auto_add_modules {
    my $self = shift;

    for my $ns (keys %{$self->{namespaces}}) {

        # skip default namespaces
        next
          if $ns eq "rdf"
          || $ns eq "#default"
          || exists $self->{modules}{$self->{namespaces}{$ns}};
        $self->add_module(prefix => $ns, uri => $self->{namespaces}{$ns});
    }

    $self;
}

sub parse {
    my $self = shift;
    $self->_initialize((%$self));

    # Workaround to make sure that if we were defined with version => "2.0"
    # then we can still parse 1.0 and 0.9.x feeds correctly.
    if ($self->{version} eq "2.0") {
        $self->{modules} = +{%{$self->_get_default_modules()}, %{$self->{modules}}};
    }

    $self->SUPER::parse(shift);
    $self->_auto_add_modules if $AUTO_ADD;
    $self->{version} = $self->{_internal}->{version};
}

sub parsefile {
    my $self = shift;
    $self->_initialize((%$self));

    # Workaround to make sure that if we were defined with version => "2.0"
    # then we can still parse 1.0 and 0.9.x feeds correctly.
    if ($self->{version} eq "2.0") {
        $self->{modules} = +{%{$self->_get_default_modules()}, %{$self->{modules}}};
    }

    $self->SUPER::parsefile(shift);
    $self->_auto_add_modules if $AUTO_ADD;
    $self->{version} = $self->{_internal}->{version};
}

sub save {
    my ($self, $file) = @_;
    open(OUT, ">:encoding($self->{encoding})", "$file")
      or croak "Cannot open file $file for write: $!";
    print OUT $self->as_string;
    close OUT;
}

sub strict {
    my ($self, $value) = @_;
    $self->{'strict'} = $value;
}

sub _handle_accessor {
    my $self = shift;
    my $name = shift;

    my $type = ref($self);

    croak "Unregistered entity: Can't access $name field in object of class $type"
      unless (exists $self->{$name});

    # return reference to RSS structure
    if (@_ == 1) {
        return $self->{$name}->{$_[0]};

        # we're going to set values here
    }
    elsif (@_ > 1) {
        my %hash = @_;
        my $_REQ;

        # make sure we have required elements and correct lengths
        if ($self->{'strict'}) {
            ($self->{version} eq '0.9')
              ? ($_REQ = $_REQ_v0_9)
              : ($_REQ = $_REQ_v0_9_1);
        }

        # store data in object
        foreach my $key (keys(%hash)) {
            if ($self->{'strict'}) {
                my $req_element = $_REQ->{$name}->{$key};
                confess "$key cannot exceed " . $req_element->[1] . " characters in length"
                  if defined $req_element->[1] && length($hash{$key}) > $req_element->[1];
            }
            $self->{$name}->{$key} = $hash{$key};
        }

        # return value
        return $self->{$name};

        # otherwise, just return a reference to the whole thing
    }
    else {
        return $self->{$name};
    }

    # make sure we have all required elements
    #foreach my $key (keys(%{$_REQ->{$name}})) {
    #my $element = $_REQ->{$name}->{$key};
    #croak "$key is required in $name"
    #if ($element->[0] == 1) && (!defined($hash{$key}));
    #croak "$key cannot exceed ".$element->[1]." characters in length"
    #unless length($hash{$key}) <= $element->[1];
    #}
}

sub channel {
    my $self = shift;

    return $self->_handle_accessor("channel", @_);
}

sub image {
    my $self = shift;

    return $self->_handle_accessor("image", @_);
}

sub textinput {
    my $self = shift;

    return $self->_handle_accessor("textinput", @_);
}

sub skipDays {
    my $self = shift;

    return $self->_handle_accessor("skipDays", @_);
}

sub skipHours {
    my $self = shift;

    return $self->_handle_accessor("skipHours", @_);
}

sub _encode {
    my ($self, $text) = @_;

    if (!defined($text)) {
        confess "\$text is undefined in XML::RSS::_encode(). We don't know how " . "to handle it!";
    }

    return $text unless $self->{'encode_output'};

    my $encoded_text = '';

    while ($text =~ s/(.*?)(\<\!\[CDATA\[.*?\]\]\>)//s) {

        # we use &named; entities here because it's HTML
        $encoded_text .= encode_entities($1) . $2;
    }

    # we use numeric entities here because it's XML
    $encoded_text .= encode_entities_numeric($text);

    return $encoded_text;
}

1;
__END__

=head1 NAME

XML::RSS - creates and updates RSS files

=head1 SYNOPSIS

 # create an RSS 1.0 file (http://purl.org/rss/1.0/)
 use XML::RSS;
 my $rss = new XML::RSS (version => '1.0');
 $rss->channel(
   title        => "freshmeat.net",
   link         => "http://freshmeat.net",
   description  => "the one-stop-shop for all your Linux software needs",
   dc => {
     date       => '2000-08-23T07:00+00:00',
     subject    => "Linux Software",
     creator    => 'scoop@freshmeat.net',
     publisher  => 'scoop@freshmeat.net',
     rights     => 'Copyright 1999, Freshmeat.net',
     language   => 'en-us',
   },
   syn => {
     updatePeriod     => "hourly",
     updateFrequency  => "1",
     updateBase       => "1901-01-01T00:00+00:00",
   },
   taxo => [
     'http://dmoz.org/Computers/Internet',
     'http://dmoz.org/Computers/PC'
   ]
 );

 $rss->image(
   title  => "freshmeat.net",
   url    => "http://freshmeat.net/images/fm.mini.jpg",
   link   => "http://freshmeat.net",
   dc => {
     creator  => "G. Raphics (graphics at freshmeat.net)",
   },
 );

 $rss->add_item(
   title       => "GTKeyboard 0.85",
   link        => "http://freshmeat.net/news/1999/06/21/930003829.html",
   description => "GTKeyboard is a graphical keyboard that ...",
   dc => {
     subject  => "X11/Utilities",
     creator  => "David Allen (s2mdalle at titan.vcu.edu)",
   },
   taxo => [
     'http://dmoz.org/Computers/Internet',
     'http://dmoz.org/Computers/PC'
   ]
 );

 $rss->textinput(
   title        => "quick finder",
   description  => "Use the text input below to search freshmeat",
   name         => "query",
   link         => "http://core.freshmeat.net/search.php3",
 );

 # Optionally mixing in elements of a non-standard module/namespace

 $rss->add_module(prefix=>'my', uri=>'http://purl.org/my/rss/module/');

 $rss->add_item(
   title       => "xIrc 2.4pre2",
   link        => "http://freshmeat.net/projects/xirc/",
   description => "xIrc is an X11-based IRC client which ...",
   my => {
     rating    => "A+",
     category  => "X11/IRC",
   },
 );

  $rss->add_item (title=>$title, link=>$link, slash=>{ topic=>$topic });

 # create an RSS 2.0 file
 use XML::RSS;
 my $rss = new XML::RSS (version => '2.0');
 $rss->channel(title          => 'freshmeat.net',
               link           => 'http://freshmeat.net',
               language       => 'en',
               description    => 'the one-stop-shop for all your Linux software needs',
               rating         => '(PICS-1.1 "http://www.classify.org/safesurf/" 1 r (SS~~000 1))',
               copyright      => 'Copyright 1999, Freshmeat.net',
               pubDate        => 'Thu, 23 Aug 1999 07:00:00 GMT',
               lastBuildDate  => 'Thu, 23 Aug 1999 16:20:26 GMT',
               docs           => 'http://www.blahblah.org/fm.cdf',
               managingEditor => 'scoop@freshmeat.net',
               webMaster      => 'scoop@freshmeat.net'
               );

 $rss->image(title       => 'freshmeat.net',
             url         => 'http://freshmeat.net/images/fm.mini.jpg',
             link        => 'http://freshmeat.net',
             width       => 88,
             height      => 31,
             description => 'This is the Freshmeat image stupid'
             );

 $rss->add_item(title => "GTKeyboard 0.85",
        # creates a guid field with permaLink=true
        permaLink  => "http://freshmeat.net/news/1999/06/21/930003829.html",
        # alternately creates a guid field with permaLink=false
        # guid     => "gtkeyboard-0.85"
        enclosure   => { url=>$url, type=>"application/x-bittorrent" },
        description => 'blah blah'
);
 
 $rss->textinput(title => "quick finder",
                 description => "Use the text input below to search freshmeat",
                 name  => "query",
                 link  => "http://core.freshmeat.net/search.php3"
                 );

 # create an RSS 0.9 file
 use XML::RSS;
 my $rss = new XML::RSS (version => '0.9');
 $rss->channel(title => "freshmeat.net",
               link  => "http://freshmeat.net",
               description => "the one-stop-shop for all your Linux software needs",
               );

 $rss->image(title => "freshmeat.net",
             url   => "http://freshmeat.net/images/fm.mini.jpg",
             link  => "http://freshmeat.net"
             );

 $rss->add_item(title => "GTKeyboard 0.85",
                link  => "http://freshmeat.net/news/1999/06/21/930003829.html"
                );

 $rss->textinput(title => "quick finder",
                 description => "Use the text input below to search freshmeat",
                 name  => "query",
                 link  => "http://core.freshmeat.net/search.php3"
                 );

 # print the RSS as a string
 print $rss->as_string;

 # or save it to a file
 $rss->save("fm.rdf");

 # insert an item into an RSS file and removes the oldest item if
 # there are already 15 items
 my $rss = new XML::RSS;
 $rss->parsefile("fm.rdf");
 pop(@{$rss->{'items'}}) if (@{$rss->{'items'}} == 15);
 $rss->add_item(title => "MpegTV Player (mtv) 1.0.9.7",
                link  => "http://freshmeat.net/news/1999/06/21/930003958.html",
                mode  => 'insert'
                );

 # parse a string instead of a file
 $rss->parse($string);

 # print the title and link of each RSS item
 foreach my $item (@{$rss->{'items'}}) {
     print "title: $item->{'title'}\n";
     print "link: $item->{'link'}\n\n";
 }

 # output the RSS 0.9 or 0.91 file as RSS 1.0
 $rss->{output} = '1.0';
 print $rss->as_string;

=head1 DESCRIPTION

This module provides a basic framework for creating and maintaining
RDF Site Summary (RSS) files. This distribution also contains many
examples that allow you to generate HTML from an RSS, convert between
0.9, 0.91, and 1.0 version, and other nifty things.
This might be helpful if you want to include news feeds on your Web
site from sources like Slashot and Freshmeat or if you want to syndicate
your own content.

XML::RSS currently supports 0.9, 0.91, and 1.0 versions of RSS.
See http://my.netscape.com/publish/help/mnn20/quickstart.html
for information on RSS 0.91. See http://my.netscape.com/publish/help/
for RSS 0.9. See http://purl.org/rss/1.0/ for RSS 1.0.

RSS was originally developed by Netscape as the format for
Netscape Netcenter channels, however, many Web sites have since
adopted it as a simple syndication format. With the advent of RSS 1.0,
users are now able to syndication many different kinds of content
including news headlines, threaded measages, products catalogs, etc.

=head1 METHODS

=over 4

=item new XML::RSS (version=>$version, encoding=>$encoding,
output=>$output, stylesheet=>$stylesheet_url)

Constructor for XML::RSS. It returns a reference to an XML::RSS object.
You may also pass the RSS version and the XML encoding to use. The default
B<version> is 1.0. The default B<encoding> is UTF-8. You may also specify
the B<output> format regarless of the input version. This comes in handy
when you want to convert RSS between versions. The XML::RSS modules
will convert between any of the formats.  If you set <encode_output> XML::RSS
will make sure to encode any entities in generated RSS.  This is now on by
default.

You can also pass an optional URL to an XSL stylesheet that can be used to
output an C<<< <?xsl-stylesheet ... ?> >>> meta-tag in the header that will
allow some browsers to render the RSS file as HTML.

=item add_item (title=>$title, link=>$link, description=>$desc, mode=>$mode)

Adds an item to the XML::RSS object. B<mode> and B<description> are optional.
The default B<mode>
is append, which adds the item to the end of the list. To insert an item, set the mode
to B<insert>.

The items are stored in the array @{$obj->{'items'}} where
B<$obj> is a reference to an XML::RSS object.

=item as_string;

Returns a string containing the RSS for the XML::RSS object.  This
method will also encode special characters along the way.

=item channel (title=>$title, link=>$link, description=>$desc, language=>$language, rating=>$rating, copyright=>$copyright, pubDate=>$pubDate, lastBuildDate=>$lastBuild, docs=>$docs, managingEditor=>$editor, webMaster=>$webMaster)

Channel information is required in RSS. The B<title> cannot
be more the 40 characters, the B<link> 500, and the B<description>
500 when outputting RSS 0.9. B<title>, B<link>, and B<description>,
are required for RSS 1.0. B<language> is required for RSS 0.91.
The other parameters are optional for RSS 0.91 and 1.0.

To retreive the values of the channel, pass the name of the value
(title, link, or description) as the first and only argument
like so:

$title = channel('title');

=item image (title=>$title, url=>$url, link=>$link, width=>$width, height=>$height, description=>$desc)

Adding an image is not required. B<url> is the URL of the
image, B<link> is the URL the image is linked to. B<title>, B<url>,
and B<link> parameters are required if you are going to
use an image in your RSS file. The remaining image elements are used
in RSS 0.91 or optionally imported into RSS 1.0 via the rss091 namespace.

The method for retrieving the values for the image is the same as it
is for B<channel()>.

=item parse ($string)

Parses an RDF Site Summary which is passed into B<parse()> as the first parameter.

See the add_module() method for instructions on automatically adding
modules as a string is parsed.

=item parsefile ($file)

Same as B<parse()> except it parses a file rather than a string.

See the add_module() method for instructions on automatically adding
modules as a string is parsed.

=item save ($file)

Saves the RSS to a specified file.

=item skipDays (day => $day)

Populates the skipDays element with the day $day.

=item skipHours (hour => $hour)

Populates the skipHours element, with the hour $hour.

=item strict ($boolean)

If it's set to 1, it will adhere to the lengths as specified
by Netscape Netcenter requirements. It's set to 0 by default.
Use it if the RSS file you're generating is for Netcenter.
strict will only work for RSS 0.9 and 0.91. Do not use it for
RSS 1.0.

=item textinput (title=>$title, description=>$desc, name=>$name, link=>$link);

This RSS element is also optional. Using it allows users to submit a Query
to a program on a Web server via an HTML form. B<name> is the HTML form name
and B<link> is the URL to the program. Content is submitted using the GET
method.

Access to the B<textinput> values is the the same as B<channel()> and
B<image()>.

=item add_module(prefix=>$prefix, uri=>$uri)

Adds a module namespace declaration to the XML::RSS object, allowing you
to add modularity outside of the the standard RSS 1.0 modules.  At present,
the standard modules Dublin Core (dc) and Syndication (syn) are predefined
for your convenience. The Taxonomy (taxo) module is also internally supported.

The modules are stored in the hash %{$obj->{'modules'}} where
B<$obj> is a reference to an XML::RSS object.

If you want to automatically add modules that the parser finds in
namespaces, set the $XML::RSS::AUTO_ADD variable to a true value.  By
default the value is false. (N.B. AUTO_ADD only updates the
%{$obj->{'modules'}} hash.  It does not provide the other benefits
of using add_module.)

=back

=head2 RSS 1.0 MODULES

XML-Namespace-based modularization affords RSS 1.0 compartmentalized
extensibility.  The only modules that ship "in the box" with RSS 1.0
are Dublin Core (http://purl.org/rss/1.0/modules/dc/), Syndication
(http://purl.org/rss/1.0/modules/syndication/), and Taxonomy
(http://purl.org/rss/1.0/modules/taxonomy/).  Consult the appropriate
module's documentation for further information.

Adding items from these modules in XML::RSS is as simple as adding other
attributes such as title, link, and description.  The only difference
is the compartmentalization of their key/value paris in a second-level
hash.

  $rss->add_item (title=>$title, link=>$link, dc=>{ subject=>$subject, creator=>$creator });

For elements of the Dublin Core module, use the key 'dc'.  For elements
of the Syndication module, 'syn'.  For elements of the Taxonomy module,
'taxo'. These are the prefixes used in the RSS XML document itself.
They are associated with appropriate URI-based namespaces:

  syn:  http://purl.org/rss/1.0/modules/syndication/
  dc:   http://purl.org/dc/elements/1.1/
  taxo: http://purl.org/rss/1.0/modules/taxonomy/

Dublin Core elements may occur in channel, image, item(s), and textinput
-- albeit uncomming to find them under image and textinput.  Syndication
elements are limited to the channel element. Taxonomy elements can occur
in the channel or item elements.

Access to module elements after parsing an RSS 1.0 document using
XML::RSS is via either the prefix or namespace URI for your convenience.

  print $rss->{items}->[0]->{dc}->{subject};

  or

  print $rss->{items}->[0]->{'http://purl.org/dc/elements/1.1/'}->{subject};

XML::RSS also has support for "non-standard" RSS 1.0 modularization at
the channel, image, item, and textinput levels.  Parsing an RSS document
grabs any elements of other namespaces which might appear.  XML::RSS
also allows the inclusion of arbitrary namespaces and associated elements
when building  RSS documents.

For example, to add elements of a made-up "My" module, first declare the
namespace by associating a prefix with a URI:

  $rss->add_module(prefix=>'my', uri=>'http://purl.org/my/rss/module/');

Then proceed as usual:

  $rss->add_item (title=>$title, link=>$link, my=>{ rating=>$rating });

Non-standard namespaces are not, however, currently accessible via a simple
prefix; access them via their namespace URL like so:

  print $rss->{items}->[0]->{'http://purl.org/my/rss/module/'}->{rating};

XML::RSS will continue to provide built-in support for standard RSS 1.0
modules as they appear.

=head1 Non-API Methods

=head2 $rss->as_rss_0_9()

B<WARNING>: this function is not an API function and should not be called
directly. It is kept as is for backwards compatibility with legacy code. Use
the following code instead:

    $rss->{output} = "0.9";
    my $text = $rss->as_string();

This function renders the data in the object as an RSS version 0.9 feed,
and returns the resultant XML as text.

=head2 $rss->as_rss_0_9_1()

B<WARNING>: this function is not an API function and should not be called
directly. It is kept as is for backwards compatibility with legacy code. Use
the following code instead:

    $rss->{output} = "0.91";
    my $text = $rss->as_string();

This function renders the data in the object as an RSS version 0.91 feed,
and returns the resultant XML as text.

=head2 $rss->as_rss_1_0()

B<WARNING>: this function is not an API function and should not be called
directly. It is kept as is for backwards compatibility with legacy code. Use
the following code instead:

    $rss->{output} = "1.0";
    my $text = $rss->as_string();

This function renders the data in the object as an RSS version 1.0 feed,
and returns the resultant XML as text.

=head2 $rss->as_rss_2_0()

B<WARNING>: this function is not an API function and should not be called
directly. It is kept as is for backwards compatibility with legacy code. Use
the following code instead:

    $rss->{output} = "2.0";
    my $text = $rss->as_string();

This function renders the data in the object as an RSS version 2.0 feed,
and returns the resultant XML as text.

=head2 $rss->handle_char()

Needed for XML::Parser. Don't use this directly.

=head2 $rss->handle_dec()

Needed for XML::Parser. Don't use this directly.

=head2 $rss->handle_start()

Needed for XML::Parser. Don't use this directly.

=head1 BUGS

Please use rt.cpan.org for tracking bugs.  The list of current open
bugs is at
    L<http://rt.cpan.org/Dist/Display.html?Queue=XML-RSS>.

To report a new bug, go to
    L<http://rt.cpan.org/Ticket/Create.html?Queue=XML-RSS>

Please include a failing test in your bug report.  I'd much rather
have a well written test with the bug report than a patch.

When you create diffs (for tests or patches), please use the C<-u>
parameter to diff.

=head1 SOURCE AVAILABILITY

The source is available from the perl.org Subversion server:

L<http://svn.perl.org/modules/XML-RSS/>


=head1 AUTHOR

    Original code: Jonathan Eisenzopf <eisen@pobox.com>
    Further changes: Rael Dornfest <rael@oreilly.com>

    Currently: Ask Bjoern Hansen <ask@develooper.com> 


=head1 COPYRIGHT

Copyright (c) 2001 Jonathan Eisenzopf <eisen@pobox.com> and Rael
Dornfest <rael@oreilly.com>, Copyright (C) 2006 Ask Bjoern Hansen
<ask@develooper.com>.

XML::RSS is free software. You can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 CREDITS

 Wojciech Zwiefka <wojtekz@cnt.pl>
 Chris Nandor <pudge@pobox.com>
 Jim Hebert <jim@cosource.com>
 Randal Schwartz <merlyn@stonehenge.com>
 rjp@browser.org
 Kellan Elliott-McCrea <kellan@protest.net>
 Rafe Colburn <rafe@rafe.us>
 Adam Trickett <adam.trickett@btinternet.com>
 Aaron Straup Cope <asc@vineyard.net>
 Ian Davis <iand@internetalchemy.org>
 rayg@varchars.com
 Shlomi Fish <shlomif@iglu.org.il>

=head1 SEE ALSO

perl(1), XML::Parser(3).

=cut
