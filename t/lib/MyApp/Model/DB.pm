package MyApp::Model::DB;
use Moose;

BEGIN { extends 'Catalyst::Model' }

package MyApp::Model::DB::OAuth2::Client;
use Moose;

BEGIN { extends 'Catalyst::Model' }

sub find {
  my($self, $id) = @_;
  return Test::Client->new(id => $id);
}

package Test::Client;
use Moose;

has id => (is => 'ro', required => 1);

sub endpoint {
  my($self) = @_;
  return URI->new('/client/' . $self->id);
}

1;
