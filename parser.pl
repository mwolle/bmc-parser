#!/usr/bin/perl -w

#use strict;
use feature ":5.10";
use XML::Simple;
use Text::CSV;
use Data::Dumper;
use DBI;


# CONFIG
my $outputfolder="output";
#print Dumper($_);

# functions
#
sub get_content {
	my $content="";
	foreach (@_) {
		if(ref($_->{p}) eq 'ARRAY'){
			foreach (@{$_->{p}}) {
				if( defined $_->{content} ) {
					foreach (@{$_->{content}}) {
						$content=$content." ".$_;
					}
				} else {
					$content=$content." ".$_;
				}
			}
		} else {
				#print Dumper($_);
				if( defined $_->{sec} ) {
					if(ref($_->{sec}) eq 'ARRAY'){
						foreach (@{$_->{sec}}) {
							$content=$content.get_content($_);
						}
					} else {
						$content=$content.get_content($_->{sec});
					}
				} else {
					if( defined $_->{p}->{content} ) {
						foreach (@{$_->{p}->{content}}) {
							$content=$content." ".$_;
						}
					} else {
						$content=$content." ".$_->{p};
					}
				}
		}
	}

	return $content;

}


if ( @ARGV > 0 ) {
	  push @files, $ARGV[0];
} else {
	@files = <*.xml>;
}
foreach $xml (@files) {
	my @array;
 	$filename=$xml;
        print "parsing xml: " . $filename . "\n";
        $xml = XMLin($xml,suppressempty => 1);
# documenttitle
        $title=$xml->{ui};
#        print "\n FILENAME: " . $filename;
#        print "\n DOCUMENTID: " . $title;
# content
 	if(ref($xml->{bdy}->{sec}) eq 'ARRAY'){
		$i=0;
                foreach (@{$xml->{bdy}->{sec}}) {
			
			$content_title=$_->{st}->{p};
			$array[$i][0] = $filename;
			$array[$i][1] = $title;
			$array[$i][2] = $content_title;
			$array[$i][3] = get_content($_);
			$i++;


                }
        } else {
		$content_title="No title";
			$array[0][0] = $filename;
			$array[0][1] = $title;
			$array[0][2] = $content_title;
			$array[0][3] = get_content($xml->{bdy}->{sec});
        }
	$fullfilename=$outputfolder."/".$filename.".csv";
	my $csv = Text::CSV->new ( { binary => 1, eol => "\n" } )  # should set binary attribute.
             or die "Cannot use CSV: ".Text::CSV->error_diag ();
	open(my $fh, '>', $fullfilename) or die "Could not open file '$fullfilename' $!";
	foreach $row (@array) {
		$csv->print ($fh, $row);
	}
	close $fh;
}



