package Catalyst::OAuth2::ActionRole::RequestInjector;
use Moose::Role;
use Moose::Util;

use Catalyst::OAuth2::Request;

requires 'execute';
requires 'build_oauth2_request';

before execute => sub {
  my $self = shift;
  my ( $controller, $c ) = @_;
  my $req = $c->req;

  Moose::Util::ensure_all_roles( $req, 'Catalyst::OAuth2::Request',
    { rebless_params => { oauth2 => $self->build_oauth2_request(@_) } } );

};

1;
