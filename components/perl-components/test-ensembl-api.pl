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
    print fh $entry_ac.",".$isoform->{isoform}.",".$isoform->{sequence}.",NO_NP_ENSG\n";
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

    $found_enst = 0;
    $enst_found = 0;

    $found_ensp = 0;
    $ensp_found = 0;
    $ensp_sequence_found = 0;

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
        if($isoform->{ENST} eq $enst) {
          $found_enst = 1;
          $enst_found = $enst;
          if ($isoform->{ENSP} eq $ensp) {
            $mapped_isoforms = $mapped_isoforms + 1;
            $found_mapping = 1;

            $found_ensp = 1;
            $ensp_found = $ensp;
            $ensp_sequence_found = $ensp_seq;
            next;
          } else {
            print fh $entry_ac.",".$isoform->{isoform}.",".$isoform->{sequence}.",".$ensg.",".$enst."\n";
            print "NP ENSP ".$isoform->{ENSP}." doesn't match with ENSMBL ENSP ".$ensp."\n";
          }
        } else {
          print "ENST ".$enst ." doesn't match with isform ENST ". $isoform->{ENST}."\n";
        }

        foreach my $translation  ( @{ $transcript->get_all_alternative_translations() } ) {
          #print $translation->stable_id(), "\n";
          #print $translation->seq(), "\n";

          my $ensp_a = $translation->stable_id();
          my $ensp_a_seq = $translation->seq();

          if($isoform->{ENST} == $enst ) {
            $found_enst = 1;
            $enst_found = $enst;

            if($isoform->{ENSP} == $ensp_a) {
              $mapped_isoforms = $mapped_isoforms + 1;
              $found_mapping = 1;

              $found_ensp = 1;
              $ensp_found = $ensp_a;
              $ensp_sequence_found = $ensp_a_seq;
              next;
            }
          }
        }
      } else {
        #print $transcript->stable_id(), " is non-coding\n";
      }
    }

    if($found_enst == 1) { # ENST found
      if($found_ensp == 1) { # ENSP found
        print fh $entry_ac.",".$isoform->{isoform}.",".$isoform->{sequence}.",".$ensg.",".$enst_found.",".$ensp_found,",".$ensp_sequence_found."\n";
        print "ENSP ".$ensp_found. " matched for transcript ". $enst_found, "\n";
      } else { # ENST found but ENSP
        print fh $entry_ac.",".$isoform->{isoform}.",".$isoform->{sequence}.",".$ensg.",".$enst_found.",NO_ENSMBL_ENSP\n";
        print "No ENSP matched for transcript ". $enst_found, "\n";
      }
    } else { # No ENST found
      print fh $entry_ac.",".$isoform->{isoform}.",".$isoform->{sequence}.",".$ensg.",NO_ENSEMBL_ENST,,,\n";
      print "No ENST found for isoform ".$isoform->{isoform} ."\n";
    }

    if(!$found_mapping) {
      if($isoform->{ENST}) {
        $non_mapped_isoforms = $non_mapped_isoforms + 1;
        print "No mapping found for isoform ".$isoform->{isoform}. "from ensembl but found from nextrprot ".$isoform->{ENST}. "\n";
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
