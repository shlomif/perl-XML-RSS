use ExtUtils::MakeMaker;
@extras = ();

push(@extras,
     CAPI => 'TRUE')
    if ($PERL_VERSION >= 5.005 and $OSNAME eq 'MSWin32'
        and $Config{archname} =~ /-object\b/i);

push(@extras,
     ABSTRACT_FROM => 'RSS.pm',
     AUTHOR        => 'Jonathan Eisenzopf <eisen@pobox.com>')
    if ($ExtUtils::MakeMaker::Version >= 5.4301);
     
WriteMakefile(
    NAME	=> 'XML::RSS',
    dist	=> {COMPRESS => 'gzip', SUFFIX => '.gz'},
    VERSION_FROM => 'RSS.pm', # finds $VERSION,
    PREREQ_PM => { XML::Parser => '2.23' },
    @extras
);
