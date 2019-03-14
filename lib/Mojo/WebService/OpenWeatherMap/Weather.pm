package Mojo::WebService::OpenWeatherMap::Weather;
use Mojo::Base -base;

use Mojo::WebService::OpenWeatherMap::Conditions;

our $VERSION = 'v0.1.0';

has [qw(source timestamp city city_id longitude latitude country sunrise sunset conditions
        temp temp_min temp_max pressure pressure_sea_level pressure_ground_level
        humidity wind_speed wind_dir clouds rain rain_window snow snow_window)];

sub from_source {
  my ($self, $source) = @_;
  $self->timestamp($source->{dt});
  $self->city($source->{name});
  $self->city_id($source->{id});
  if (defined $source->{coord}) {
    $self->longitude($source->{coord}{lon});
    $self->latitude($source->{coord}{lat});
  }
  if (defined $source->{sys}) {
    $self->country($source->{sys}{country});
    $self->sunrise($source->{sys}{sunrise});
    $self->sunset($source->{sys}{sunset});
  }
  if (defined $source->{weather}) {
    $self->conditions([map { Mojo::WebService::OpenWeatherMap::Conditions->new->from_source($_) } @{$source->{weather}}]);
  }
  if (defined $source->{main}) {
    $self->temp($source->{main}{temp});
    $self->pressure($source->{main}{pressure});
    $self->pressure_sea_level($source->{main}{sea_level});
    $self->pressure_ground_level($source->{main}{grnd_level});
    $self->humidity($source->{main}{humidity});
    $self->temp_min($source->{main}{temp_min});
    $self->temp_max($source->{main}{temp_max});
  }
  if (defined $source->{wind}) {
    $self->wind_speed($source->{wind}{speed});
    $self->wind_dir($source->{wind}{deg});
  }
  if (defined $source->{clouds}) {
    $self->clouds($source->{clouds}{all});
  }
  if (defined $source->{rain}) {
    my $key = (sort keys %{$source->{rain}})[0];
    if (defined $key) {
      $self->rain($source->{rain}{$key});
      $self->rain_window($key);
    }
  }
  if (defined $source->{snow}) {
    my $key = (sort keys %{$source->{snow}})[0];
    if (defined $key) {
      $self->snow($source->{snow}{$key});
      $self->snow_window($key);
    }
  }
  $self->source($source);
  return $self;
}

1;

=encoding UTF-8

=head1 NAME

Mojo::WebService::OpenWeatherMap::Weather - Weather data

=head1 SYNOPSIS

  use Mojo::WebService::OpenWeatherMap;
  my $owm = Mojo::WebService::OpenWeatherMap->new(api_key => $api_key);
  my $weather = $owm->get_weather(city => 'London', country => 'UK');

  my $city = $weather->city;
  my $country = $weather->country;
  my $temp = $weather->temp;
  my $conditions = join ', ', map { $_->description } @{$weather->conditions};
  say "Current weather for $city, $country: $conditions (${temp}°C)";

=head1 DESCRIPTION

L<Mojo::WebService::OpenWeatherMap::Weather> is an object representing current
weather data from L<OpenWeatherMap|https://openweathermap.org>, used by
L<Mojo::WebService::OpenWeatherMap>. See
L<https://openweathermap.org/current> for more information.

=head1 ATTRIBUTES

=head2 source

  my $hashref = $weather->source;

Source data hashref from OpenWeatherMap API.

=head2 timestamp

  my $timestamp = $weather->timestamp;

Time of data calculation as a Unix epoch timestamp.

=head2 city

  my $city = $weather->city;

City name.

=head2 city_id

  my $city_id = $weather->city_id;

City ID.

=head2 longitude

  my $longitude = $weather->longitude;

Longitude of city.

=head2 latitude

  my $latitude = $weather->latitude;

=head2 country

  my $country = $weather->country;

ISO 3166 country code.

=head2 sunrise

  my $sunrise = $weather->sunrise;

Time of sunrise as a Unix epoch timestamp.

=head2 sunset

  my $sunset = $weather->sunset;

Time of sunset as a Unix epoch timestamp.

=head2 conditions

  my $conditions_aref = $weather->conditions;

Array reference of current weather conditions as
L<Mojo::WebService::OpenWeatherMap::Conditions> objects.

=head2 temp

  my $temp = $weather->temp;

Current temperature. Units are according to
L<Mojo::WebService::OpenWeatherMap/"units">: K (undefined), °C (metric), °F
(imperial).

=head2 temp_min

  my $temp_min = $weather->temp_min;

Current minimum temperature, may be specified for larger cities. Units are
according to L<Mojo::WebService::OpenWeatherMap/"units">: K (undefined), °C
(metric), °F (imperial).

=head2 temp_max

  my $temp_max = $weather->temp_max;

Current maximum temperature, may be specified for larger cities. Units are
according to L<Mojo::WebService::OpenWeatherMap/"units">: K (undefined), °C
(metric), °F (imperial).

=head2 pressure

  my $pressure = $weather->pressure;

Current atmospheric pressure in hPa.

=head2 pressure_sea_level

  my $pressure = $weather->pressure_sea_level;

Current atmospheric pressure at sea level in hPa.

=head2 pressure_ground_level

  my $pressure = $weather->pressure_ground_level;

Current atmospheric pressure at ground level in hPa.

=head2 humidity

  my $humidity = $weather->humidity;

Current humidity in %.

=head2 wind_speed

  my $wind_speed = $weather->wind_speed;

Current wind speed. Units are according to
L<Mojo::WebService::OpenWeatherMap/"units">: meters/second (undefined or
metric), miles/hour (imperial).

=head2 wind_dir

  my $wind_dir = $weather->wind_dir;

Current wind direction in meteorological degrees.

=head2 clouds

  my $clouds = $weather->clouds;

Current cloudiness in %.

=head2 rain

  my $rain = $weather->rain;

Rain volume in mm for the last L</"rain_window"> duration.

=head2 rain_window

  my $rain_window = $weather->rain_window;

Duration over which L</"rain"> volume was measured. Generally C<1h> for
precipitation data from weather stations, and C<3h> for model data.

=head2 snow

  my $snow = $weather->snow;

Snow volume in mm for the last L</"snow_window"> duration.

=head2 snow_window

  my $snow_window = $weather->snow_window;

Duration over which L</"snow"> volume was measured. Generally C<1h> for
precipitation data from weather stations, and C<3h> for model data.

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
