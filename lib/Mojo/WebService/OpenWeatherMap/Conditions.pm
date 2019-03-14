package Mojo::WebService::OpenWeatherMap::Conditions;
use Mojo::Base -base;

use Mojo::URL;

our $VERSION = 'v0.1.0';

our $ICON_BASE_URL = 'https://openweathermap.org/img/w/';

has [qw(source category description icon_url)];

sub from_source {
  my ($self, $source) = @_;
  $self->category($source->{main});
  $self->description($source->{description});
  $self->icon_url(Mojo::URL->new($ICON_BASE_URL)->path("$source->{icon}.png")->to_string) if defined $source->{icon};
  $self->source($source);
  return $self;
}

1;

=head1 NAME

Mojo::WebService::OpenWeatherMap::Conditions - Weather conditions

=head1 SYNOPSIS

  use Mojo::WebService::OpenWeatherMap;
  my $owm = Mojo::WebService::OpenWeatherMap->new(api_key => $api_key);
  my $weather = $owm->get_weather(city => 'London', country => 'UK');

  say "Current conditions: " . join ', ', map { $_->description } @{$weather->conditions};

=head1 DESCRIPTION

L<Mojo::WebService::OpenWeatherMap::Conditions> is an object representing
weather conditions from L<OpenWeatherMap|https://openweathermap.org>, used by
L<Mojo::WebService::OpenWeatherMap>. See
L<https://openweathermap.org/current> for more information.

=head1 ATTRIBUTES

=head2 source

  my $hashref = $conditions->source;

Source data hashref from OpenWeatherMap API.

=head2 category

  my $category = $conditions->category;

Weather conditions category (Rain, Snow, Extreme, etc).

=head2 description

  my $description = $conditions->description;

Description of weather conditions.

=head2 icon_url

  my $url = $conditions->icon_url;

URL to OpenWeatherMap weather conditions icon.

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
