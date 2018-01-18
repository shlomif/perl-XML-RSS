use 5.006;

use ExtUtils::MakeMaker;
@extras = ();

push(@extras,
     CAPI => 'TRUE')
  if ($PERL_VERSION >= 5.005 and $OSNAME eq 'MSWin32'
      and $Config{archname} =~ /-object\b/i);

push(@extras,
     ABSTRACT_FROM => 'lib/XML/RSS.pm',
     AUTHOR        => ' Ask Bjoern Hansen <ask@develooper.com>')
    if ($ExtUtils::MakeMaker::Version >= 5.4301);

if ($ExtUtils::MakeMaker::Version >= 6.36)
{
    push(@extras,
        LICENSE => "perl",
    );
}

WriteMakefile(
              'NAME'         => 'XML::RSS',
              'VERSION_FROM' => 'lib/XML/RSS.pm', # finds $VERSION,
              'PREREQ_PM'    => {
                                 'Test::More'       => '0',
                                 'XML::Parser'      => '2.23',
                                 'HTML::Entities'   => 0,
                                 'DateTime' => 0,
                                 'DateTime::Format::Mail' => 0,
                                 'DateTime::Format::W3CDTF' => 0,
                                },
              'clean'        => { FILES => 'XML-RSS-* t/generated/*.xml' },
              'PL_FILES' => {},
              @extras
);
