package CatalystX::OAuth2::Grant;
use Moose::Role;

with 'CatalystX::OAuth2';

# ABSTRACT: A role for building oauth2 grant objects

requires 'next_action_uri';

has response_type => ( is => 'ro', required  => 1 );
has client_id     => ( is => 'ro', required  => 1 );
has scope         => ( is => 'ro', predicate => 'has_scope' );
has state         => ( is => 'ro', predicate => 'has_state' );

around _params => sub {
  my $orig = shift;
  return $orig->(@_), qw(response_type scope state client_id)
};

1;
