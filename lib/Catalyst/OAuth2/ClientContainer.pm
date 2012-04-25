package Catalyst::OAuth2::ClientContainer;
use Moose::Role;

has oauth2 => (
  isa      => 'Catalyst::OAuth2::Client',
  is       => 'rw',
  clearer  => 'clear_oauth2'
);

1;
