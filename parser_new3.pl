#!/usr/bin/perl -w

#use strict;
use feature ":5.10";
use XML::Simple;
use Text::CSV;
use Data::Dumper;
use DBI;


# CONFIG
my $outputfolder="output";
my $wordfilename="word_all_blub";
my $globalfilename="output_all_blub";
my $startingDocCount="59670";
my $filesplit=2000;

my $globalcount=$startingDocCount;
my @allword;
my @words;
my $l;
my $j;
my $filecounter;
my $start_word;
my $start_chapter;
my $counter;
my @array;

# functions
#
sub cleanLines{

    my $text = shift;

    $text =~ s/\R/ /g; #replace \r with space
    $text =~ s/\r/ /g; #replace \r with space
    $text =~ s/\n/ /g; #replace \n with space
    $text =~ s/  / /g; #replace double-spaces with single space

    return $text;
}

sub get_content {

	my $content="";
	my $suppressline="";
	foreach (@_) {
			foreach (@{$_->{p}}) {
				if( defined $_->{content} ) {
					$suppressline=0;
					foreach (@{$_->{content}}) {
						$content=$content." ".$_;
						$suppressline=1;
					}
					if( $suppressline == 0 ) {
						$content=$_->{content};
					}
				} else {
					$content=$content." ".$_;
				}
			}
			foreach (@{$_->{sec}}) {
				$content=$content." ".get_content($_);
			}
	}
	return $content;

}
sub save_files {

	$fullfilename=$outputfolder."/".$globalfilename.$filecounter.".csv";
	my $csv = Text::CSV->new ( { binary => 1, eol => "\n" } )  # should set binary attribute.
	     or die "Cannot use CSV: ".Text::CSV->error_diag ();
	open(my $fh, '>', $fullfilename) or die "Could not open file '$fullfilename' $!";
	foreach $row (@array) {
		$csv->print ($fh, $row);
	}
	close $fh;

	$fullfilename=$outputfolder."/".$wordfilename.$filecounter.".csv";
	$csv = Text::CSV->new ( { binary => 1, eol => "\n" } )  # should set binary attribute.
	or die "Cannot use CSV: ".Text::CSV->error_diag ();
	open($fh, '>', $fullfilename) or die "Could not open file '$fullfilename' $!";
	foreach $row (@allword) {
		$csv->print ($fh, $row);
		}
	close $fh;

}

if ( @ARGV > 0 ) {
	  push @files, $ARGV[0];
} else {
	@files = <*.xml>;
}
$filecounter=0;
$counter=0;
$l=0;
foreach $xml (@files) {
 	$filename=$xml;
        print "parsing xml: " . $filename . "\n";
        $xml = XMLin($xml,suppressempty => 1,forcearray => 1);
	

# documenttitle
	foreach (@{$xml->{ui}}){
		$title = $_;
	}
# content
        foreach (@{$xml->{bdy}}) {
		$start_chapter=0;
                foreach (@{$_->{sec}}) {
                        $chapter="No Title";
                        foreach (@{$_->{st}}) {
                                foreach (@{$_->{p}}) {
                                        $chapter=$_;
                                }
                        }

			$array[$counter][0] = $globalcount;
			$array[$counter][1] = $filename;
			$array[$counter][2] = $title;
			$array[$counter][3] = $chapter;
			$array[$counter][4] = $start_chapter;
			$array[$counter][6] = cleanLines(get_content($_));
			$array[$counter][5] = $array[$counter][4] + length( $array[$counter][6] );
			$start_chapter += length( $array[$counter][6] );
			$start_chapter++;

			@words = split / /, $array[$counter][6];
			$j = 0;
			$start_word = 0;
			foreach $word (@words) {
				$j++;
				$allword[$l][0] = $globalcount;
				$allword[$l][1] = $j;
				$allword[$l][2] = $chapter;
				$allword[$l][3] = $word;
				$allword[$l][5] = $start_word;
				$start_word += length( $word );
				$start_word++;
				$word =~ s/[^a-zA-Z0-9]//g;
				$allword[$l][4] = $word;
				$allword[$l][6] = $allword[$l][5] + length( $word );
				$l++;
			}
			$counter++;
                }
	}
	if( $counter >= $filesplit ){
		save_files( );
		$filecounter++;
		$counter=0;
		@allword=();
		@array=();	
		$l=0;
	}
	$globalcount++;
}
if( defined $array[0][6] ) {
save_files( );
}

