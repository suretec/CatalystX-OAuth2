use strictures 1;
use Test::More;

use HTTP::Request::Common;
use lib 't/lib';
use CatalystX::Test::MockContext;

my $mock = mock_context('MyApp');

{
  my $uri = URI->new('/token');
  $uri->query_form(
    { grant_type   => 'authorization_code',
      redirect_uri => '/client/foo',
      code         => 'foocode'
    }
  );
  my $c = $mock->( GET $uri );
  $c->dispatch;
  my $res = $c->res;
  my $redirect = $c->req->oauth2->next_action_uri( $c->controller, $c );
  is_deeply(
    { $redirect->query_form },
    { access_token => 'footoken',
      token_type   => 'bearer',
      expires_in   => 3600
    }
  );
  is( $res->location, $redirect );
}

done_testing();
