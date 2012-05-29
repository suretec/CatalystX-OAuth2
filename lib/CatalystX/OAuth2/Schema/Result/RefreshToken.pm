package CatalystX::OAuth2::Schema::Result::RefreshToken;
use parent 'DBIx::Class';

__PACKAGE__->load_components(qw(Core));
__PACKAGE__->table('refresh_token');
__PACKAGE__->add_columns(
  client_id => { is_nullable => 0 },
  id => { data_type => 'int', is_auto_increment => 1, is_nullable => 0 },
  is_active       => { is_nullable => 0, default_value => 0 },
  access_token_id => { is_nullable => 1, default_value => undef }
);
__PACKAGE__->set_primary_key(qw(id));
__PACKAGE__->belongs_to(
  access_token => 'CatalystX::OAuth2::Schema::Result::Token' =>
    { 'foreign.id' => 'self.access_token_id' } );

__PACKAGE__->belongs_to(
  client => 'CatalystX::OAuth2::Schema::Result::Client' =>
    { 'foreign.id' => 'self.client_id' } );

sub as_string { shift->id }

1;
