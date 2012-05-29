package Catalyst::OAuth2::Client;
use Moose;
use LWP::UserAgent;

# ABSTRACT: An http client for requesting oauth2-protected resources using a token

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
