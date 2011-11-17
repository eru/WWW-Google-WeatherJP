package WWW::Google::WeatherJP;
use strict;
use warnings;
use base qw/Class::Accessor::Fast/;
use WWW::Machanize;
use Web::Scraper;
use URI;

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw/mech error/);

sub new {
	my $self = shift->SUPER::new();
	
	$self->mech(
		do {
			my $mech = WWW::Mechanize->new(agent => "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:9.0) Gecko/20100101 Firefox/9.0");

			$mech;
		}
	);

	$self;
}

sub weather {
	my ($self, $query) = @_;

	my $url = URI->new('http://www.google.co.jp/search');
	$url->query_form(q => "天気 $query"
					 hl => 'ja');

	$self->mech->get($url);
	if($self->mech->success) {
		return $self->parse_html($self->mech->content);
	} else {
		$self->error('Page fetching failed: ' . $self->mech->res->status_line);
		return;
	}
}

sub parse_html {
	my ($self, $html) = @_;

	my $scraper = scraper {
		process 'table.obcontainer h3.r', place => ['TEXT', sub {s/\s+//o; s/.{5}$//o;}];
		process 'table.obcontainer td[style="font-size:140%;white-space:nowrap;vertical-align:top;padding-right:15px;font-weight:bold"]', temp => ['TEXT', sub {s/.{2}$//o;}];
		process 'table.obcontainer td[style="vertical-align:top"]', 'dow[]' => 'TEXT';
		process 'table.obcontainer td img', 'forecast[]' => '@title';
		process 'table.obcontainer td[style="white-space:nowrap;padding-right:15px;color:#666"]', 'weather[]' => 'TEXT';
		process 'table.obcontainer td[style="white-space:nowrap;padding-right:15px;vertical-align:top;color:#666"]', humidity  => 'TEXT';
		process 'table.obcontainer td[style="text-align:right;white-space:nowrap;padding-left:5px;padding-right:2px;vertical-align:top;color:#f00"]', 'high[]'  => ['TEXT', sub {s/.$//o;}];
		process 'table.obcontainer td[style="text-align:left;white-space:nowrap;padding-left:2px;padding-right:5px;vertical-align:top;color:#00f"]', 'low[]' => ['TEXT', sub {s/.$//o;}];
	};
	my $result = $scraper->scrape($html);

	if($result->{weather}) {
		return $result->{weather};
	} else {
		return ;
	}
}

1;
__END__

=head1 NAME

WWW::Google::WeatherJP -

=head1 SYNOPSIS

  use WWW::Google::WeatherJP;

  my $weather = WWW::Google::WeatherJP->new();

  print 

=head1 DESCRIPTION

WWW::Google::WeatherJP is

=head1 AUTHOR

eru.tndl E<lt>eru.tndl@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
