package AuthServer;
use Moose;

BEGIN { extends 'Catalyst' }

sub user        { __PACKAGE__->model('DB::Client')->first }
sub user_exists {1}

__PACKAGE__->setup;

1;
