package Catalyst::ActionRole::OAuth2::RequestAuth;
use Moose::Role;

with 'Catalyst::OAuth2::ActionRole::Grant';
#before execute => sub {};

1;
