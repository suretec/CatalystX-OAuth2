package CatalystX::OAuth2::Schema::Result::Client;
use parent 'DBIx::Class';

# ABSTRACT: A table for registering clients

__PACKAGE__->load_components(qw(Core));
__PACKAGE__->table('client');
__PACKAGE__->add_columns(
    id            => { data_type => 'int',  is_auto_increment => 1 },
    endpoint      => { data_type => 'text', is_nullable       => 0 },
    client_secret => { data_type => 'text', is_nullable       => 1 }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many( codes => 'CatalystX::OAuth2::Schema::Result::Code' =>
      { 'foreign.client_id' => 'self.id' } );
__PACKAGE__->has_many(
    refresh_tokens => 'CatalystX::OAuth2::Schema::Result::RefreshToken' =>
      { 'foreign.client_id' => 'self.id' } );

1;
