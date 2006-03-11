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

sub ExtUtils::MM_Any::test_via_harness {
    my($self, $perl, $tests) = @_;
    
    return qq|\t$perl "-MTest::Manifest" | .
      qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
        qq|'\$(INST_ARCHLIB)')"\n|;
}
     
WriteMakefile(
              'NAME'         => 'XML::RSS',
              'VERSION_FROM' => 'lib/XML/RSS.pm', # finds $VERSION,
              'PREREQ_PM'    => { 
                                 'Test::Manifest'   => '0.9',
                                 'Test::More'       => '0',
                                 'XML::Parser'      => '2.23', 
                                },
              'clean'        => { FILES => 'XML-RSS-* t/*-generated.xml' },
              @extras
);
