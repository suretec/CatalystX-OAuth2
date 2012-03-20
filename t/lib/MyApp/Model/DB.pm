package MyApp::Model::DB;
use Moose;

BEGIN { extends 'Catalyst::Model' }

package MyApp::Model::DB::OAuth2::Client;
use Moose;

BEGIN { extends 'Catalyst::Model' }

with 'Catalyst::OAuth2::ClientStore';

sub find {
  my($self, $id) = @_;
  return Test::Client->new(id => $id);
}
sub find_code { Test::Code->new }
sub find_refresh_token { Test::Code->new }

package Test::Client;
use Moose;

has id => (is => 'ro', required => 1);

sub endpoint {
  my($self) = @_;
  return URI->new('/client/' . $self->id);
}

sub create_code { Test::Code->new }
sub find_code { Test::Code->new }

package Test::Code;
use Moose;

sub as_string { 'foocode' }

sub create_token { Test::Token->new }
sub find_token { Test::Token->new }
sub scope { 'foo bar' }

package Test::Token;
use Moose;

sub type { 'bearer' }
sub expires_in { 3600 }
sub as_string { 'footoken' }
sub scope { 'foo bar' }

1;
