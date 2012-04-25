package Catalyst::OAuth2::ClientPersistor;
use Moose::Role;

requires qw(for_session);

after for_session => sub {
  my ( $self, $c, $user ) = @_;
  if ( $user->Moose::Util::does_role('Catalyst::OAuth2::ClientContainer') ) {
    $user->clear_oauth2;
  } else {
    $user->oauth2(undef) if $user->can('oauth2');
  }
};

1;
