package Catalyst::OAuth2::ClientContainer;
use Moose::Role;

# ABSTRACT: A role for providing an oauth2 client object to an arbitrary class

has oauth2 => (
  isa      => 'Catalyst::OAuth2::Client',
  is       => 'rw',
  clearer  => 'clear_oauth2'
);

1;
