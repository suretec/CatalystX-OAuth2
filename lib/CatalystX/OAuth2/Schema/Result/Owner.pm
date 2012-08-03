package CatalystX::OAuth2::Schema::Result::Owner;
use parent 'DBIx::Class';

# ABSTRACT: A table for registering resource owners

__PACKAGE__->load_components(qw(Core));
__PACKAGE__->table('owner');
__PACKAGE__->add_columns(
  id => { data_type => 'int', is_auto_increment => 1 }, );
__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many( tokens => 'CatalystX::OAuth2::Schema::Result::Token' =>
    { 'foreign.owner_id' => 'self.id' } );

1;
