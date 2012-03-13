package Catalyst::OAuth2::ActionRole::Grant;
use Moose::Role;
use Moose::Util;

use Catalyst::OAuth2;
use Catalyst::OAuth2::Request;

requires 'execute';

before execute => sub {
  my ( $self, $controller, $c ) = @_;
  my $req = $c->req;

  Moose::Util::ensure_all_roles( $req, 'Catalyst::OAuth2::Request',
    { rebless_params => { oauth2 => Catalyst::OAuth2->new } } );

};

1;
