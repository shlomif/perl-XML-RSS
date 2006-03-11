# $Id: pod.t,v 1.2 2003/02/20 17:12:46 kellan Exp $

BEGIN {
	use File::Find;
	@files = ();
	find(sub { push @files, $File::Find::name if $_ =~ m/\.pm$/;}, 
		('blib/lib') 
	);
}

use Test::More;

eval "require Test::Pod";
if ($@) {
	plan skip_all => "Test::Pod is missing";	
}
else {
	tests => scalar @files;
}

foreach my $file ( @files ) {
	pod_ok( $file );
}

