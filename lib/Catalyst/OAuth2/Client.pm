package Catalyst::OAuth2::Client;
use Moose;
use LWP::UserAgent;

our $UA;

has token => ( isa => 'Str', is => 'rw', required => 1 );

sub ua { $UA ||= LWP::UserAgent->new };
sub request { shift->ua->request(@_) }

before request => sub {
  my($self, $req) = @_;
  my $token = $self->token;
  $req->header( Authorization => 'Bearer ' . $token );
};

1;
