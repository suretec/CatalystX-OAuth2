package CatalystX::OAuth2::ClientPersistor;
use Moose::Role;

# ABSTRACT: Work-around for persisting oauth2-authenticated users safely

requires qw(for_session);

after for_session => sub {
  my ( $self, $c, $user ) = @_;
  if ( $user->Moose::Util::does_role('CatalystX::OAuth2::ClientContainer') ) {
    $user->clear_oauth2;
  } else {
    $user->oauth2(undef) if $user->can('oauth2');
  }
};

1;
