package AuthServer;
use Moose;

BEGIN { extends 'Catalyst' }

__PACKAGE__->setup(qw(Authentication));

sub user { __PACKAGE__->model('DB::Client')->first }
sub user_exists { 1 }

1;
