package MyApp;
use Moose;

BEGIN { extends 'Catalyst' }

__PACKAGE__->setup();

sub user { __PACKAGE__->model('DB::Client')->first }
sub user_exists { 1 }

1;
