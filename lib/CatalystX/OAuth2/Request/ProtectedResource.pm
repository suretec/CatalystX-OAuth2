package CatalystX::OAuth2::Request::ProtectedResource;
use Moose::Util::TypeConstraints;
use Moose;
with 'CatalystX::OAuth2';

# ABSTRACT: An oauth2 protected resource request implementation

has token =>
  ( isa => duck_type( [qw(as_string owner)] ), is => 'ro', required => 1 );

sub _build_query_parameters {{}}

1;
