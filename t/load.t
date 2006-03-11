# $Id: load.t,v 1.2 2003/02/20 17:12:46 kellan Exp $
BEGIN {
	use File::Find;
	
	@files = ();
	find(sub { push @files, $File::Find::name if $_ =~ m/\.pm$/;}, 
		('blib/lib') 
	);
	
	@classes = map { my $x = $_;
		$x =~ s|^blib/lib/||;
		$x =~ s|/|::|g;
		$x =~ s|\.pm$||;
		$x;
		} @files;
	}

use Test::More tests => scalar @classes;
	
foreach my $class ( @classes ){
	print "bail out! $class did not compile" unless use_ok( $class );
}

