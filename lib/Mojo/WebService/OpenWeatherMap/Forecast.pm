package Mojo::WebService::OpenWeatherMap::Forecast;
use Mojo::Base -base;

use Mojo::WebService::OpenWeatherMap::ForecastEntry;

our $VERSION = 'v0.1.0';

has [qw(source city city_id longitude latitude country entries)];

sub from_source {
  my ($self, $source) = @_;
  if (defined $source->{city}) {
    $self->city($source->{city}{name});
    $self->city_id($source->{city}{id});
    if (defined $source->{city}{coord}) {
      $self->longitude($source->{city}{coord}{lon});
      $self->latitude($source->{city}{coord}{lat});
    }
    $self->country($source->{city}{country});
  }
  if (defined $source->{list}) {
    $self->entries([map { Mojo::WebService::OpenWeatherMap::ForecastEntry->new->from_source($_) } @{$source->{list}}]);
  }
  $self->source($source);
  return $self;
}

1;

=encoding UTF-8

=head1 NAME

Mojo::WebService::OpenWeatherMap::Forecast - Forecast data

=head1 SYNOPSIS

  use Mojo::WebService::OpenWeatherMap;
  my $owm = Mojo::WebService::OpenWeatherMap->new(api_key => $api_key);
  my $forecast = $owm->get_forecast_5d(city => 'London', country => 'UK');

  my $city = $forecast->city;
  my $country = $forecast->country;
  my $temps = join ', ', map { $_->temp . '°C' } @{$forecast->entries};
  say "Temperature forecast for $city, $country: $temps";

=head1 DESCRIPTION

L<Mojo::WebService::OpenWeatherMap::Forecast> is an object representing weather
forecast data from L<OpenWeatherMap|https://openweathermap.org>, used by
L<Mojo::WebService::OpenWeatherMap>. See
L<https://openweathermap.org/forecast5> and
L<https://openweathermap.org/forecast16> for more information.

=head1 ATTRIBUTES

=head2 source

  my $hashref = $forecast->source;

Source data hashref from OpenWeatherMap API.

=head2 city

  my $city = $forecast->city;

City name.

=head2 city_id

  my $city_id = $forecast->city_id;

City ID.

=head2 longitude

  my $longitude = $forecast->longitude;

Longitude of city.

=head2 latitude

  my $latitude = $forecast->latitude;

Latitude of city.

=head2 country

  my $country = $forecast->country;

ISO 3166 country code.

=head2 entries

  my $forecast_aref = $forecast->entries;

Array reference of forecast time entries as
L<Mojo::WebService::OpenWeatherMap::ForecastEntry> objects.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2019 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

L<Mojo::WebService::OpenWeatherMap>
