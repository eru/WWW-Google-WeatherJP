package WWW::Google::WeatherJP;
use strict;
use warnings;
use utf8;
use base qw/Class::Accessor::Fast/;
use WWW::Mechanize;
use Web::Scraper;
use URI;
use Encode;
use DateTime;

our $VERSION = '1.0.1';

__PACKAGE__->mk_accessors(qw/mech error/);

sub new {
	my $self = shift->SUPER::new();
	
	$self->mech(
		do {
			my $mech = WWW::Mechanize->new(agent => "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:9.0) Gecko/20100101 Firefox/9.0");

			$mech;
		}
	);
	$self->{resp} = '';

	$self;
}

sub get {
	my ($self, $query) = @_;
	
	$self->{resp} = '';

	my $url = URI->new('http://www.google.co.jp/search');
	$url->query_form(q => '天気 ' . decode_utf8($query),
					 hl => 'ja');

	$self->mech->get($url);
	if($self->mech->success) {
		$self->parse_html($self->mech->content);
	}
}

sub parse_html {
	my ($self, $html) = @_;

	my $scraper = scraper {
		process 'table.obcontainer h3.r', place => ['TEXT', sub {s/\s+//o; s/の天気情報//o;}];
		process 'table.obcontainer td[style="font-size:140%;white-space:nowrap;vertical-align:top;padding-right:15px;font-weight:bold"]', temp => 'TEXT';
		process 'table.obcontainer td[style="vertical-align:top"]', 'dow[]' => 'TEXT';
		process 'table.obcontainer td img', 'forecast[]' => '@title';
		process 'table.obcontainer td[style="white-space:nowrap;padding-right:15px;color:#666"]', 'weather[]' => 'TEXT';
		process 'table.obcontainer td[style="white-space:nowrap;padding-right:15px;vertical-align:top;color:#666"]', humidity  => 'TEXT';
		process 'table.obcontainer td[style="text-align:right;white-space:nowrap;padding-left:5px;padding-right:2px;vertical-align:top;color:#f00"]', 'high[]'  => 'TEXT';
		process 'table.obcontainer td[style="text-align:left;white-space:nowrap;padding-left:2px;padding-right:5px;vertical-align:top;color:#00f"]', 'low[]' => 'TEXT';
	};
	my $result = $scraper->scrape($html);

	if(!$result->{place}) { return ; }
	if(!$result->{temp}) { return ; }
	if(!$result->{dow}[3]) { return ; }
	if(!$result->{forecast}[3]) { return ; }
	if(!$result->{weather}[1]) { return ; }
	if(!$result->{humidity}) { return ; }
	if(!$result->{high}[3]) { return ; }
	if(!$result->{low}[3]) { return ; }

	# 日付変更後一定時間前日の天気予報が表示されることへの対策
	my $tz = DateTime::TimeZone->new(name => 'local');
	my $dt = DateTime->now(time_zone => $tz);
	my @week = ('月', '火', '水', '木', '金', '土', '日');
	my $offset = 0;
	if($result->{dow}[1] =~ m/$week[$dt->day_of_week-1]/) {
		$offset = 1;
	}

	for(@{$self->{dow}}) {
		print $_, "a\n";
	}

	$self->{place} = $result->{place};
	$self->{now} = "$result->{weather}[0] $result->{temp} $result->{weather}[1] $result->{humidity}";
	$self->{today} = "$result->{forecast}[$offset] $result->{high}[$offset]C / $result->{low}[$offset]C";
	$self->{tomorrow} = "$result->{forecast}[$offset+1] $result->{high}[$offset+1]C / $result->{low}[$offset+1]C";
	$self->{next_tomorrow} = "$result->{forecast}[$offset+2] $result->{high}[$offset+2]C / $result->{low}[$offset+2]C";

	$self->{resp} = 1;
}

sub success {
	my $self = shift;

	return $self->{resp};
}

sub place {
	my $self = shift;

	if($self->{resp}) {
		return $self->{place}
	}
}

sub now {
	my $self = shift;

	if($self->{resp}) {
		return $self->{now};
	}
}

sub today {
	my $self = shift;

	if($self->{resp}) {
		return $self->{today};
	}
}

sub tomorrow {
	my $self = shift;

	if($self->{resp}) {
		return $self->{tomorrow};
	}
}

sub next_tomorrow {
	my $self = shift;

	if($self->{resp}) {
		return $self->{next_tomorrow};
	}
}

1;
__END__

=head1 NAME

WWW::Google::WeatherJP -

=head1 SYNOPSIS

  use WWW::Google::WeatherJP;

  my $weather = WWW::Google::WeatherJP->new();

  # call get with place name
  $weather->get("水戸");

  # if you can get weather success is 1
  # else success is ''
  if($weather->success) {
	  # weather place
	  $weather->place;

	  # now weather
	  $weather->now;

	  # today weather
	  $weather->today;

	  # tomorrow weather
	  $weather->tomorrow;

	  # next tomorrow weather
	  $weather->next_tomorrow;
  } else {
	  # get failed
  }

=head1 DESCRIPTION

WWW::Google::WeatherJP is

=head1 AUTHOR

eru.tndl E<lt>eru.tndl@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
