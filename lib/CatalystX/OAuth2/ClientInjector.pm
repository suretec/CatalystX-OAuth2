package CatalystX::OAuth2::ClientInjector;
use Moose::Role;
use Scalar::Util     ();
use MooseX::NonMoose ();
use CatalystX::OAuth2::Client;

# ABSTRACT: A role for automatically providing an oauth2 client to authenticated user objects

requires qw(find_user restore_user persist_user);

around 'find_user' => sub {
  my $orig = shift;
  my $self = shift;
  my ( $authinfo, $c ) = @_;
  my $user = $self->$orig(@_);
  my $token = $authinfo->{token} or return;
  if($user) {
    $self->_apply_client_role( $user, $authinfo->{token} );
    return $user;
  } else {
    return;
  }
};

around 'restore_user' => sub {
  my $orig  = shift;
  my $self  = shift;
  my ($c)   = @_;
  my $user  = $self->$orig(@_);
  my $token = $self->restore_token($c);
  $self->_apply_client_role( $user, $token );
  return $user;
};

before persist_user => sub {
  my ( $self, $c, $user ) = @_;
  $self->persist_token( $c, $user );
};

sub restore_token {
  my ( $self, $c ) = @_;
  return ( $c->can('session') || sub { {} } )->($c)->{__oauth2}{token};
}

sub persist_token {
  my ( $self, $c, $user ) = @_;
  ( $c->can('session') || sub { {} } )->($c)->{__oauth2}{token} =
    $user->oauth2->token;
}

sub _apply_client_role {
  my ( $self, $user, $token ) = @_;
  my $oauth2 = $self->_build_oauth2_client($token);
  if ( UNIVERSAL::isa( 'Moose::Object', $user ) or !$user->can('oauth2') ) {
    Moose::Util::ensure_all_roles(
      $user,
      'CatalystX::OAuth2::ClientContainer',
      { rebless_params => { oauth2 => $oauth2 } }
    );
  } else {
    $user->oauth2($oauth2);
  }
}

sub _build_oauth2_client {
  my ( $self, $token ) = @_;
  return CatalystX::OAuth2::Client->new( token => $token );
}

1;
