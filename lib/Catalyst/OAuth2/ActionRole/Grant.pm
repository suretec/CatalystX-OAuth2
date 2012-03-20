package Catalyst::OAuth2::ActionRole::Grant;
use Moose::Role;

with 'Catalyst::OAuth2::ActionRole::RequestInjector';

after execute => sub {
  my($self, $controller, $c) = @_;
  my $uri = $c->req->oauth2->next_action_uri($controller, $c);
  $c->res->redirect($uri);
};

1;
