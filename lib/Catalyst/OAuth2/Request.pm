package Catalyst::OAuth2::Request;
use Moose::Role;

has oauth2 => (isa => 'Catalyst::OAuth2', is => 'ro', required => 1);

1;
