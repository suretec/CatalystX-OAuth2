package ClientApp::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config( namespace => '' );

sub auth : Local Args(0) {
  my ( $self, $c ) = @_;
  $c->res->body('auth ok') if $c->authenticate();
}

sub lead : Local Args(0) {
  my ( $self, $c ) = @_;
  $c->res->body('ok');
}

sub gold : Local Args(0) {
  my ( $self, $c ) = @_;
  my $ua = $c->get_auth_realm('default')->credential->ua;

  my $req = HTTP::Request->new( GET => 'http://resourceserver/gold' );
  my $token = '';
  $token = $c->user->token if $c->user_exists;
  $req->header( Authorization => 'Bearer ' . $token );
  my $res = $ua->request($req);

  $c->res->body( $res->content );
}

1;
