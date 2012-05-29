package CatalystX::OAuth2::Request;
use Moose::Role;

# ABSTRACT: A role for building oauth2-capable request objects

has oauth2 => (isa => 'CatalystX::OAuth2', is => 'ro', required => 1);

1;
