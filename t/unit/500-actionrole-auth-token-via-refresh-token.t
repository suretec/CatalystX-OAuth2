use strictures 1;
use Test::More;
use JSON::Any;
use HTTP::Request::Common;
use lib 't/lib';
use CatalystX::Test::MockContext;

my $json = JSON::Any->new;
my $mock = mock_context('AuthServer');

# my $refresh = AuthServer->model('DB::RefreshToken')->create(
#   { code                  => { client => { endpoint  => '/client/foo' } },
#     from_access_token_map => [        { access_token => {} } ]
#   }
# );
my $code =
  AuthServer->model('DB::Code')
  ->create( { client => { endpoint => '/client/foo' }, is_active => 1 } );
my $token = $code->tokens->create( {} );

my $refresh = $token->to_refresh_token_map->create(
  { code_id => $code->id, refresh_token => { code_id => $code->id } } );

$refresh = $refresh->refresh_token;

{
  my $uri = URI->new('/refresh');
  $uri->query_form(
    { grant_type    => 'refresh_token',
      refresh_token => $refresh->as_string,
      redirect_uri  => '/client/foo'
    }
  );
  my $c = $mock->( GET $uri );
  $c->dispatch;
  is_deeply( $c->error, [] );
  my $res = $c->res;
  my $obj = $json->jsonToObj( $res->body );
  $refresh->discard_changes;
  ok( defined( $refresh->to_access_token ) );
  ok( !$refresh->is_active );
  is_deeply(
    $obj,
    { access_token => $refresh->to_access_token->as_string,
      token_type   => 'bearer',
      expires_in   => 3600
    }
  );
  is( $res->status, 200 );
}

done_testing();
