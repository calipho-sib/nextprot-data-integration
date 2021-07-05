$ensg = $ARGV[0];
print "$ensg\n";

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

my $adaptor = $registry->get_adaptor( "human", "core", "Gene");
my $gene = $adaptor->fetch_by_stable_id($ensg);
foreach my $transcript ( @{ $gene->get_all_Transcripts() } ) {
  if ( $transcript->translation() ) {
    print  $transcript->stable_id(),  "\n";
    print $transcript->translation()->stable_id(), "\n";
    print $transcript->translate()->seq(),         "\n";
    foreach my $translation  ( @{ $transcript->get_all_alternative_translations() } ) {
      print $translation->stable_id(), "\n";
      print $translation->seq(), "\n";
    }
  } else {
    print $transcript->stable_id(), " is non-coding\n";
  }
}
