package Catalyst::OAuth2::Store;
use Moose::Role;

requires qw(
  find_client
  client_endpoint
  create_client_code
  client_code_is_active
  activate_client_code
  deactivate_client_code
  create_access_token
  find_client_code
  verify_access_secret
  verify_client_token
);

1;
