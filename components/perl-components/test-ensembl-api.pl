my $filename = $ARGV[0];
my $outputfile = $ARGV[1];
print "Processing ".$filename."\n";

use lib qw(..);
use JSON qw( );


my $json_text = do {
  open(my $json_fh, "<:encoding(UTF-8)", $filename)
      or die("Can't open \$filename\": $!\n");
  local $/;
  <$json_fh>
};

my $json = JSON->new;
my @data = @{$json->decode($json_text)};

my $host = 'bernard.isb-sib.ch';
my $port = 3306;
my $user = 'ensembl';
my $pass = 'Juve.2013';

use Bio::EnsEMBL::Registry;
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => $host,
    -port => $port,
    -user => $user,
    -pass => $pass
);

# File to write
open (fh, ">", "/app/scripts/data/".$outputfile);

$entries = 0;
$isoforms = 0;
$mapped_isoforms = 0;
$non_mapped_isoforms = 0;
for my $entry ( @data ) {
  $entries = $entries + 1;
  my $entry_ac = $entry->{entry};
  my $ensg = $entry->{ENSG};

  print "-----------------\n";
  print "Processing entry ".$entry->{entry}." with ENSG ".$ensg, "\n";
  if($ensg eq "") {
    print "No ENSG found for entry\n";
    next;
  }

  my $adaptor = $registry->get_adaptor( "human", "core", "Gene");
  my $gene = $adaptor->fetch_by_stable_id($ensg);

  if($gene eq "") {
    print "No Gene found for ENSG ".$ensg, "\n";
    next;
  }

  print "Found gene ".$gene->external_name(), "\n";

  if (@{$entry->{isoforms}} == 0) {
      print "No mapping isoforms for entry ".$entry, "\n";
  }

  for my $isoform (@{$entry->{isoforms}}) {
    print "Isoform --".$isoform->{isoform}, "\n";
    $found_mapping = 0;
    $isoforms = $isoforms + 1;
    foreach my $transcript ( @{ $gene->get_all_Transcripts() } ) {
      if ( $transcript->translation() ) {
        #print  $transcript->stable_id(),  "\n";
        #print $transcript->translation()->stable_id(), "\n";
        #print $transcript->translate()->seq(),         "\n";

        my $enst = $transcript->stable_id();
        my $ensp = $transcript->translation()->stable_id();
        my $ensp_seq = $transcript->translate()->seq();

        # Check if the isoform's ENSP/ENST matches
        if($isoform->{ENST} eq $enst && $isoform->{ENSP} eq $ensp) {
          print fh $entry_ac.",".$ensg.",".$enst.",".$ensp,",".$ensp_seq.",".$isoform->{isoform}.",".$isoform->{sequence},"\n";
          print "ENSP ".$ensp. " matched for transcript ". $enst, "\n";
          $mapped_isoforms = $mapped_isoforms + 1;
          $found_mapping = 1;
          next;
        }

        foreach my $translation  ( @{ $transcript->get_all_alternative_translations() } ) {
          #print $translation->stable_id(), "\n";
          #print $translation->seq(), "\n";

          my $ensp_a = $translation->stable_id();
          my $ensp_a_seq = $translation->seq();

          if($isoform->{ENST} == $enst_a && $isoform->{ENSP} == $ensp) {
            print fh $entry_ac.",".$ensg.",".$enst.",".$ensp_a,",".$ensp_a_seq.",".$isoform->{isoform}.",".$isoform->{sequence},"\n";
            print "ENSP ".$ensp. "matched for alternative transcript ". $enst, "\n";
            $mapped_isoforms = $mapped_isoforms + 1;
            $found_mapping = 1;
            next;
          }
        }
      } else {
        #print $transcript->stable_id(), " is non-coding\n";
      }
    }

    if(!$found_mapping) {
      if($isoform->{ENST}) {
        $non_mapped_isoforms = $non_mapped_isoforms + 1;
        print "No mapping found for isoform ".$isoform->{isoform}. "from ensembl but found from nextrprot ".$isoform->{ENST}. " contradiction\n";
      } else {
        $non_mapped_isoforms = $non_mapped_isoforms + 1;
        print "No mapping found for isoform ".$isoform->{isoform},"\n";
      }
    }
    print "-----------------\n";
  }

}

print "Stats\n";
print "Entries ".$entries,"\n";
print "Isoforms ".$isoforms . " Mapped to ENSP ".$mapped_isoforms . " Non mapped ".$non_mapped_isoforms;

close($fh)
