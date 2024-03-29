#/usr/lib/perl
use strict;
use warnings;

use lib qw(..);

use JSON qw( );

my $filename = 'ensp-load';

my $json_text = do {
    open(my $json_fh, "<:encoding(UTF-8)", $filename)
        or die("Can't open \$filename\": $!\n");
    local $/;
    <$json_fh>
};

my $json = JSON->new;
my $data = $json->decode($json_text);

for ( @{$data->{data}} ) {
    print $_->{name}."\n";
}