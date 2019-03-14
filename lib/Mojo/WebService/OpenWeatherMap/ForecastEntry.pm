package Mojo::WebService::OpenWeatherMap::ForecastEntry;
use Mojo::Base -base;

use Mojo::WebService::OpenWeatherMap::Conditions;

our $VERSION = 'v0.1.0';

has [qw(source timestamp conditions
        temp temp_min temp_max temp_morning temp_evening temp_night
        pressure pressure_sea_level pressure_ground_level
        humidity clouds wind_speed wind_dir rain snow)];

sub from_source {
  my ($self, $source) = @_;
  $self->timestamp($source->{dt});
  if (defined $source->{weather}) {
    $self->conditions([map { Mojo::WebService::OpenWeatherMap::Conditions->new->from_source($_) } @{$source->{weather}}]);
  }
  if (defined $source->{main}) {
    $self->temp($source->{main}{temp});
    $self->temp_min($source->{main}{temp_min});
    $self->temp_max($source->{main}{temp_max});
    $self->pressure($source->{main}{pressure});
    $self->pressure_sea_level($source->{main}{sea_level});
    $self->pressure_ground_level($source->{main}{grnd_level});
    $self->humidity($source->{main}{humidity});
  } else {
    $self->pressure($source->{pressure});
    $self->humidity($source->{humidity});
  }
  if (defined $source->{temp}) {
    $self->temp($source->{temp}{day});
    $self->temp_min($source->{temp}{min});
    $self->temp_max($source->{temp}{max});
    $self->temp_morning($source->{temp}{morn});
    $self->temp_evening($source->{temp}{eve});
    $self->temp_night($source->{temp}{night});
  }
  if (defined $source->{clouds}) {
    if (ref $source->{clouds} eq 'HASH') {
      $self->clouds($source->{clouds}{all});
    } else {
      $self->clouds($source->{clouds});
    }
  }
  if (defined $source->{wind}) {
    $self->wind_speed($source->{wind}{speed});
    $self->wind_dir($source->{wind}{deg});
  } else {
    $self->wind_speed($source->{speed});
    $self->wind_dir($source->{deg});
  }
  if (defined $source->{rain}) {
    $self->rain($source->{rain}{'3h'});
  }
  if (defined $source->{snow}) {
    $self->snow($source->{snow}{'3h'});
  }
  $self->source($source);
  return $self;
}

1;

=encoding UTF-8

=head1 NAME

Mojo::WebService::OpenWeatherMap::ForecastEntry - Forecast entry

=head1 SYNOPSIS

  use Mojo::WebService::OpenWeatherMap;
  my $owm = Mojo::WebService::OpenWeatherMap->new(api_key => $api_key);
  my $forecast = $owm->get_forecast_5d(city => 'London', country => 'UK');

  foreach my $entry (@{$forecast->entries}) {
    my $time = localtime $entry->timestamp;
    my $temp = $entry->temp;
    say "$time: ${temp}°C";
  }

=head1 DESCRIPTION

L<Mojo::WebService::OpenWeatherMap::ForecastEntry> is an object representing
weather forecast data for a particular time or day from
L<OpenWeatherMap|https://openweathermap.org>, used by
L<Mojo::WebService::OpenWeatherMap>. See
L<https://openweathermap.org/forecast5> and
L<https://openweathermap.org/forecast16> for more information.

=head1 ATTRIBUTES

=head2 source

  my $hashref = $entry->source;

Source data hashref from OpenWeatherMap API.

=head2 timestamp

  my $timestamp = $entry->timestamp;

Time of forecast entry as a Unix epoch timestamp.

=head2 conditions

  my $conditions_aref = $entry->conditions;

Array reference of forecast weather conditions as
L<Mojo::WebService::OpenWeatherMap::Conditions> objects.

=head2 temp

  my $temp = $entry->temp;

Temperature for the time (5 day/3 hour forecast) or day (16 day/daily
forecast). Units are according to L<Mojo::WebService::OpenWeatherMap/"units">:
K (undefined), °C (metric), °F (imperial).

=head2 temp_min

  my $temp_min = $entry->temp_min;

Minimum temperature, may be specified for larger cities (5 day/3 hour
forecast), or the minimum temperature for the day (16 day/daily forecast).
Units are according to L<Mojo::WebService::OpenWeatherMap/"units">: K
(undefined), °C (metric), °F (imperial).

=head2 temp_max

  my $temp_max = $entry->temp_max;

Maximum temperature, may be specified for larger cities (5 day/3 hour
forecast), or the maximum temperature for the day (16 day/daily forecast).
Units are according to L<Mojo::WebService::OpenWeatherMap/"units">: K
(undefined), °C (metric), °F (imperial).

=head2 temp_morning

  my $temp = $entry->temp_morning;

Morning temperature for the day (16 day/daily forecast only). Units are
according to L<Mojo::WebService::OpenWeatherMap/"units">: K (undefined), °C
(metric), °F (imperial).

=head2 temp_evening

  my $temp = $entry->temp_evening;

Evening temperature for the day (16 day/daily forecast only). Units are
according to L<Mojo::WebService::OpenWeatherMap/"units">: K (undefined), °C
(metric), °F (imperial).

=head2 temp_night

  my $temp = $entry->temp_night;

Night temperature for the day (16 day/daily forecast only). Units are according
to L<Mojo::WebService::OpenWeatherMap/"units">: K (undefined), °C (metric), °F
(imperial).

=head2 pressure

  my $pressure = $entry->pressure;

Atmospheric pressure in hPa.

=head2 pressure_sea_level

  my $pressure = $entry->pressure_sea_level;

Atmospheric pressure at sea level in hPa (5 day/3 hour forecast only).

=head2 pressure_ground_level

  my $pressure = $entry->pressure_ground_level;

Atmospheric pressure at ground level in hPa (5 day/3 hour forecast only).

=head2 humidity

  my $humidity = $entry->humidity;

Humidity in %.

=head2 wind_speed

  my $wind_speed = $entry->wind_speed;

Wind speed. Units are according to L<Mojo::WebService::OpenWeatherMap/"units">:
meters/second (undefined or metric), miles/hour (imperial).

=head2 wind_dir

  my $wind_dir = $entry->wind_dir;

Wind direction in meteorological degrees.

=head2 clouds

  my $clouds = $entry->clouds;

Cloudiness in %.

=head2 rain

  my $rain = $entry->rain;

Rain volume in mm for the 3 hour window (5 day/3 hour forecast only).

=head2 snow

  my $snow = $entry->snow;

Snow volume in mm for the 3 hour window (5 day/3 hour forecast only).

=head1 METHODS

=head2 from_source

  $entry = $entry->from_source($hashref);

Populate attributes from hashref of OpenWeatherMap API source data.

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
