package MyApp::Schema::Token;
use parent 'DBIx::Class';

__PACKAGE__->load_components(qw(Core));
__PACKAGE__->table('token');
__PACKAGE__->add_columns(
  id      => { data_type => 'int', is_auto_increment => 1 },
  code_id => { data_type => 'int', is_nullable       => 0 },
);
__PACKAGE__->set_primary_key(qw(id));
__PACKAGE__->belongs_to(
  code => 'MyApp::Schema::Code' => { 'foreign.id' => 'self.code_id' } );
__PACKAGE__->might_have( refresh_token => 'MyApp::Schema::RefreshToken' =>
    { 'foreign.access_token_id' => 'self.id' } );

sub as_string  { shift->id }
sub type       {'bearer'}
sub expires_in {3600}

package MyApp::Schema::RefreshToken;
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
__PACKAGE__->belongs_to( access_token => 'MyApp::Schema::Token' =>
    { 'foreign.id' => 'self.access_token_id' } );

sub as_string { shift->id }

__PACKAGE__->belongs_to(
  client => 'MyApp::Schema::Client' => { 'foreign.id' => 'self.client_id' } );

package MyApp::Schema::Client;
use parent 'DBIx::Class';

__PACKAGE__->load_components(qw(Core));
__PACKAGE__->table('client');
__PACKAGE__->add_columns(
  id            => { data_type => 'int', is_auto_increment => 1 },
  endpoint      => { data_type => 'str', is_nullable       => 0 },
  access_secret => { data_type => 'str', is_nullable       => 1 }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(
  codes => 'MyApp::Schema::Code' => { 'foreign.client_id' => 'self.id' } );
__PACKAGE__->has_many( refresh_tokens => 'MyApp::Schema::RefreshToken' =>
    { 'foreign.client_id' => 'self.id' } );

package MyApp::Schema::Code;
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
  client => 'MyApp::Schema::Client' => { 'foreign.id' => 'self.client_id' } );
__PACKAGE__->has_many(
  tokens => 'MyApp::Schema::Token' => { 'foreign.code_id' => 'self.id' } );

sub as_string { shift->id }

package MyApp::Schema;
use parent 'DBIx::Class::Schema';

__PACKAGE__->load_classes(qw(Client Code Token RefreshToken));

package MyApp::Model::DB;
use Moose;

BEGIN { extends 'Catalyst::Model::DBIC::Schema' }

__PACKAGE__->config(
  schema_class => 'MyApp::Schema',
  connect_info => [ 'dbi:SQLite:dbname=:memory:', '', '' ]
);

around COMPONENT => sub {
  my $orig  = shift;
  my $class = shift;
  my $self  = $class->$orig(@_);
  $self->schema->deploy;
  $self->schema->resultset('Client')
    ->create( { endpoint => '/foo', access_secret => 'foosecret' } );
  return $self;
};

1;
