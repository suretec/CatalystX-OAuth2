package CatalystX::OAuth2::Schema::Result::Code;
use parent 'DBIx::Class';

__PACKAGE__->load_components(qw(Core));
__PACKAGE__->table('code');
__PACKAGE__->add_columns(
  client_id => { is_nullable => 0 },
  id => { data_type => 'int', is_auto_increment => 1, is_nullable => 0 },
  is_active => { is_nullable => 0, default_value => 1 }
);
__PACKAGE__->set_primary_key(qw(id));
__PACKAGE__->belongs_to(
  client => 'CatalystX::OAuth2::Schema::Result::Client' =>
    { 'foreign.id' => 'self.client_id' } );
__PACKAGE__->has_many( tokens => 'CatalystX::OAuth2::Schema::Result::Token' =>
    { 'foreign.code_id' => 'self.id' } );

sub as_string { shift->id }

1;
