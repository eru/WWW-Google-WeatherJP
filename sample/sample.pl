use warnings;
use strict;
use WWW::Google::WeatherJP;
use Encode;

my $weather = WWW::Google::WeatherJP->new();
$weather->get("水戸");
if($weather->success) {
	print encode('utf-8', $weather->place) . "\n";
	print encode('utf-8', $weather->now) . "\n";
	print encode('utf-8', $weather->today) . "\n";
	print encode('utf-8', $weather->tomorrow) . "\n";
	print encode('utf-8', $weather->next_tomorrow) . "\n";
} else {
	print "failed\n";
}
