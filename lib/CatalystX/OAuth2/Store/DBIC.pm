package CatalystX::OAuth2::Store::DBIC;
use Moose;
use Moose::Util::TypeConstraints;

# ABSTRACT: An interface to a DBIC-based OAuth2 store

with 'CatalystX::OAuth2::Store';

has app => ( is => 'ro', required => 1 );
has client_model => (
  isa      => 'Str',
  is       => 'ro',
  required => 1
);
has _client_model => (
  isa        => 'DBIx::Class::ResultSet',
  is         => 'ro',
  lazy_build => 1
);
has endpoint_field => ( isa => 'Str', is => 'ro', default => 'endpoint' );
has refresh_relation =>
  ( isa => 'Str', is => 'ro', default => 'refresh_tokens' );
has token_relation => ( isa => 'Str', is => 'ro', default => 'tokens' );
has code_relation  => ( isa => 'Str', is => 'ro', default => 'codes' );
has code_activation_field =>
  ( isa => 'Str', is => 'ro', default => 'is_active' );

sub _build__client_model {
  my ($self) = @_;
  return $self->app->model( $self->client_model );
}

sub find_client {
  my ( $self, $id ) = @_;
  $self->_client_model->find($id);
}

sub client_endpoint {
  my ( $self, $id ) = @_;
  my $client = $self->find_client($id)
    or return;
  return $client->get_column( $self->endpoint_field );
}

sub _code_rs {
  my ( $self, $id ) = @_;
  return $self->_client_model->related_resultset( $self->code_relation )
    unless defined($id);
  my $client = $self->find_client($id)
    or return;
  return $client->related_resultset( $self->code_relation );
}

sub create_client_code {
  my ( $self, $id ) = @_;
  $self->_code_rs($id)->create( {} );
}

sub find_client_code {
  my ( $self, $code, $id ) = @_;
  return $id
    ? $self->_code_rs->find($code)
    : $self->_code_rs($id)->find($code);
}

sub activate_client_code {
  my ( $self, $id, $code ) = @_;
  my $code_row = $self->find_client_code( $id, $code )
    or return;
  $code_row->update( { $self->code_activation_field => 1 } );
}

sub deactivate_client_code {
  my ( $self, $id, $code ) = @_;
  my $code_row = $self->find_client_code( $id, $code )
    or return;
  $code_row->update( { $self->code_activation_field => 0 } );
}

sub client_code_is_active {
  my ( $self, $id ) = @_;
  my $client = $self->find_client($id)
    or return;
  return $client->get_column( $self->code_activation_field );
}

sub create_access_token {
  my ( $self, $code ) = @_;
  my $code_row = $self->find_client_code($code)
    or return;
  return $code_row->related_resultset( $self->token_relation )->create( {} );
}

sub create_access_token_from_refresh {
  my ( $self, $refresh ) = @_;
  my $refresh_row =
    $self->_client_model->related_resultset( $self->refresh_relation )
    ->find($refresh)
    or return;
  my $code_row =
    $refresh_row->client->codes->search( { is_active => 1 } )->first
    or return;
  my $token;
  $code_row->result_source->storage->txn_do(
    sub {
      $token =
        $code_row->related_resultset( $self->token_relation )->create( {} );
      $refresh_row->update( { is_active => 0, access_token => $token } );
    }
  );
  return $token;
}

sub find_code_from_refresh {
  my ( $self, $refresh ) = @_;
  my $refresh_row =
    $self->_client_model->related_resultset( $self->refresh_relation )
    ->find($refresh)
    or return;
  return $refresh_row->client->codes->search( { is_active => 1 } )->first;
}

sub verify_client_secret {
  my ( $self, $client_id, $access_secret ) = @_;
  my $client = $self->find_client($client_id);
  return $client->client_secret eq $access_secret;
}

sub verify_client_token {
  my ( $self, $client_id, $access_token ) = @_;
  my $client = $self->find_client($client_id);
  return 0 unless defined $access_token;
  return 1
    if $client->related_resultset( $self->code_relation )
      ->related_resultset( $self->token_relation )->find($access_token);
  return 0;
}

1;
