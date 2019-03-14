package Mojo::WebService::OpenWeatherMap;
use Mojo::Base -base;

use Carp ();
use Mojo::URL;
use Mojo::UserAgent;
use Mojo::WebService::OpenWeatherMap::Weather;
use Mojo::WebService::OpenWeatherMap::Forecast;

our $VERSION = 'v0.1.0';

has 'api_key';
has 'ua' => sub { Mojo::UserAgent->new };
has 'lang' => 'en';
has 'units' => 'metric';

our $API_BASE_URL = 'https://api.openweathermap.org/data/2.5/';

sub get_weather {
  my $self = shift;
  my $tx = $self->ua->get($self->_get_weather_url(@_));
  Carp::croak _error($tx) if $tx->error;
  return $self->_get_weather_res($tx->res);
}

sub get_weather_p {
  my $self = shift;
  return $self->ua->get_p($self->_get_weather_url(@_))->then(sub {
    my ($tx) = @_;
    die _error($tx) if $tx->error;
    return $self->_get_weather_res($tx->res);
  });
}

sub _get_weather_url { shift->_location_url('weather', @_) }

sub _get_weather_res { Mojo::WebService::OpenWeatherMap::Weather->new->from_source($_[1]->json) }

sub get_forecast {
  my $self = shift;
  my $tx = $self->ua->get($self->_get_forecast_url(@_));
  Carp::croak _error($tx) if $tx->error;
  return $self->_get_forecast_res($tx->res);
}

sub get_forecast_p {
  my $self = shift;
  return $self->ua->get_p($self->_get_forecast_5d_url(@_))->then(sub {
    my ($tx) = @_;
    die _error($tx) if $tx->error;
    return $self->_get_forecast_5d_res($tx->res);
  });
}

sub _get_forecast_url { shift->_location_url('forecast', @_) }

sub _get_forecast_res { Mojo::WebService::OpenWeatherMap::Forecast->new->from_source($_[1]->json) }

sub get_forecast_daily {
  my $self = shift;
  my $tx = $self->ua->get($self->_get_forecast_daily_url(@_));
  Carp::croak _error($tx) if $tx->error;
  return $self->_get_forecast_daily_res($tx->res);
}

sub get_forecast_daily_p {
  my $self = shift;
  return $self->ua->get_p($self->_get_forecast_daily_url(@_))->then(sub {
    my ($tx) = @_;
    die _error($tx) if $tx->error;
    return $self->_get_forecast_daily_res($tx->res);
  });
}

sub _get_forecast_daily_url { shift->_location_url('forecast/daily', @_) }

sub _get_forecast_daily_res { Mojo::WebService::OpenWeatherMap::Forecast->new->from_source($_[1]->json) }

sub _base_url {
  my ($self) = @_;
  my ($api_key, $units, $lang) = ($self->api_key, $self->units, $self->lang);
  Carp::croak 'api_key required for get_weather' unless defined $api_key;
  my $url = Mojo::URL->new($API_BASE_URL)->query({APPID => $api_key});
  $url->query({units => $units}) if defined $units;
  $url->query({lang => $lang}) if defined $lang;
  return $url;
}

sub _location_args {
  my ($self, $url, %args) = @_;
  if (defined $args{city}) {
    my $q = defined $args{country} ? "$args{city},$args{country}" : $args{city};
    $url->query({q => $q});
  } elsif (defined $args{city_id}) {
    $url->query({id => $args{city_id}});
  } elsif (defined $args{latitude} or defined $args{longitude}) {
    $url->query({lat => $args{latitude}, lon => $args{longitude}});
  } elsif (defined $args{zip}) {
    my $zip = defined $args{country} ? "$args{zip},$args{country}" : $args{zip};
    $url->query({zip => $zip});
  }
  return $url;
}

sub _location_url {
  my ($self, $path, @args) = @_;
  return $self->_location_args($self->_base_url->path($path), @args);
}

sub _error {
  my ($tx) = @_;
  return undef unless my $err = $tx->error;
  my ($code, $msg) = @$err{'code','message'};
  return $msg unless defined $code;
  my $data = $tx->res->json;
  if (defined $data and ref $data eq 'HASH') {
    $code = $data->{cod} if defined $data->{cod} and $data->{cod} != 200;
    $msg = $data->{message} if defined $data->{message};
  }
  return "HTTP $code: $msg";
}

1;

=head1 NAME

Mojo::WebService::OpenWeatherMap - Simple OpenWeatherMap API client

=head1 SYNOPSIS

=head1 DESCRIPTION

L<Mojo::WebService::OpenWeatherMap> is a L<Mojo::UserAgent> based
L<OpenWeatherMap|https://openweathermap.org> API client that can perform
requests synchronously or asynchronously. An OpenWeatherMap
L<API key|https://openweathermap.org/guide> is required.

Each method has a blocking variant which returns results directly, and a
non-blocking C<_p> variant which returns a L<Mojo::Promise> that will resolve
with the results asynchronously. On connection or HTTP error, blocking API
queries will throw an exception, and non-blocking API queries will reject the
promise.

Note that this distribution implements only a subset of the OpenWeatherMap API
and is considered experimental, as I will update it to suit my needs.
Additional features may be added as requested.

=head1 ATTRIBUTES

=head2 api_key

  my $api_key = $owm->api_key;
  $owm        = $owm->api_key($api_key);

OpenWeatherMap L<API key|https://openweathermap.org/guide>.

=head2 ua

  my $ua = $owm->ua;
  $owm   = $owm->ua(Mojo::UserAgent->new);

HTTP user agent object to use for requests, defaults to a L<Mojo::UserAgent>
object.

=head2 lang

  my $lang = $owm->lang;
  $owm     = $owm->lang('es');

Language code to request for weather condition descriptions, defaults to C<en>.
See L<https://openweathermap.org/current#multi> for supported languages.

=head2 units

  my $units = $owm->units;
  $owm      = $owm->units('imperial');

Type of units for returned data, can be C<metric>, C<imperial>, or undefined.
Defaults to C<metric>. See L<https://openweathermap.org/weather-data> for units
returned in each configuration.

=head1 LOCATIONS

Locations can be specified in the following ways:

=over 4

=item city

Name of the city. C<country> can optionally be specified as an ISO-3166 country
code.

=item city_id

OpenWeatherMap city ID. City IDs are listed in
L<these archives|http://bulk.openweathermap.org/sample/>.

=item latitude, longitude

Geographical coordinates.

=item zip

Postal code. C<country> can optionally be specified as an ISO-3166 country
code, and defaults to US.

=back

=head1 METHODS

=head2 get_weather

=head2 get_weather_p

  my $weather = $owm->get_weather(city => $city);
  my $weather = $owm->get_weather(city => $city, country => $country);
  my $weather = $owm->get_weather(city_id => $city_id);
  my $weather = $owm->get_weather(latitude => $latitude, longitude => $longitude);
  my $weather = $owm->get_weather(zip => $zip);
  my $weather = $owm->get_weather(zip => $zip, country => $country);
  my $promise = $owm->get_weather_p(city => $city);

Retrieve the current weather for a location as a
L<Mojo::WebService::OpenWeatherMap::Weather> object.

=head2 get_forecast

=head2 get_forecast_p

  my $forecast = $owm->get_forecast(city => $city);
  my $forecast = $owm->get_forecast(city => $city, country => $country);
  my $forecast = $owm->get_forecast(city_id => $city_id);
  my $forecast = $owm->get_forecast(latitude => $latitude, longitude => $longitude);
  my $forecast = $owm->get_forecast(zip => $zip);
  my $forecast = $owm->get_forecast(zip => $zip, country => $country);
  my $promise  = $owm->get_forecast_p(city => $city);

Retrieve the five-day forecast (3 hour increments) for a location as a
L<Mojo::WebService::OpenWeatherMap::Forecast> object.

=head2 get_forecast_daily

=head2 get_forecast_daily_p

  my $forecast = $owm->get_forecast_daily(city => $city);
  my $forecast = $owm->get_forecast_daily(city => $city, country => $country);
  my $forecast = $owm->get_forecast_daily(city_id => $city_id);
  my $forecast = $owm->get_forecast_daily(latitude => $latitude, longitude => $longitude);
  my $forecast = $owm->get_forecast_daily(zip => $zip);
  my $forecast = $owm->get_forecast_daily(zip => $zip, country => $country);
  my $promise  = $owm->get_forecast_daily_p(city => $city);

Retrieve the 16-day daily forecast for a location as a
L<Mojo::WebService::OpenWeatherMap::Forecast> object. This API requires an
L<OpenWeatherMap subscription|https://openweathermap.org/price>.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2019 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

L<Weather::OpenWeatherMap>
