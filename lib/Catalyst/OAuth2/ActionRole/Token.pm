package Catalyst::OAuth2::ActionRole::Token;
use Moose::Role;
use JSON::Any;

with 'Catalyst::OAuth2::ActionRole::RequestInjector';

my $json = JSON::Any->new;

after execute => sub {
  my($self, $controller, $c) = @_;
  $c->res->body($json->objToJson($c->req->oauth2->query_parameters));
};

1;
