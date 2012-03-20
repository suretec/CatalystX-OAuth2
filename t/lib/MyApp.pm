package MyApp;
use Moose;

BEGIN { extends 'Catalyst' }

__PACKAGE__->setup();

sub user_exists { 1 }

1;
