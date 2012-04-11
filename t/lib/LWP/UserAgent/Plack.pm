package LWP::UserAgent::Plack;

use strict;
use warnings;
use base qw(Test::WWW::Mechanize);
use HTTP::Response;
use HTTP::Message::PSGI;

sub app { shift->{app} }

sub new {
  my ( $class, %cnf ) = @_;
  my $new = $class->SUPER::new(%cnf);
  $new->{app} = $cnf{app};
  $new;
}

sub send_request {
  my ( $self, $req ) = @_;
  my $res = HTTP::Response->from_psgi( $self->app->( $req->to_psgi ) );
  $res->request($req);
  $res->header("Client-Date" => HTTP::Date::time2str(time));
  $self->run_handlers("response_done", $res);
  $res;
}

1;
