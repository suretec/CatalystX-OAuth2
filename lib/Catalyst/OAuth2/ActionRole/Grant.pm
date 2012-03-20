package Catalyst::OAuth2::ActionRole::Grant;
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

after execute => sub {
  my($self, $controller, $c) = @_;
  my $uri = $c->req->oauth2->next_action_uri($controller, $c);
  $c->res->redirect($uri);
};

1;
