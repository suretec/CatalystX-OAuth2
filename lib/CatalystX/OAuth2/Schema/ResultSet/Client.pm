package CatalystX::OAuth2::Schema::ResultSet::Client;
use parent 'DBIx::Class::ResultSet';

sub find_refresh {
  shift->related_resultset('codes')->search( { is_active => 1 } )
    ->related_resultset('tokens')->related_resultset('to_refresh_token_map')
    ->related_resultset('refresh_token')->find(@_);
}

1;
