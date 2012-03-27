package Catalyst::OAuth2::Controller::Role::Provider;
use Moose::Role;
use MooseX::SetOnce;
use Moose::Util;
use Class::Load;

has $_ => (
  isa       => 'Catalyst::Action',
  is        => 'rw',
  traits    => [qw(SetOnce)],
  predicate => "_has_$_"
) for qw(_request_auth_action _get_auth_token_via_auth_grant_action);

has store => (
  does     => 'Catalyst::OAuth2::Store',
  is       => 'ro',
  required => 1
);

around BUILDARGS => sub {
  my $orig = shift;
  my $self = shift;
  my $args = $self->$orig(@_);
  return $args unless @_ == 2;
  my ($app) = @_;
  for ( $args->{store} ) {
    last unless defined and ref eq 'HASH';
    my $class = delete $_->{class};
    $class = "Catalyst::OAuth2::Store::$class" unless $class =~ /^\+/;
    my ( $is_success, $error ) = Class::Load::try_load_class($class);
    die qq{Couldn't load OAuth2 store '$class': $error} unless $is_success;
    $args->{store} = $class->new( %$_, app => $app );
  }
  return $args;
};

around create_action => sub {
  my $orig   = shift;
  my $self   = shift;
  my $action = $self->$orig(@_);
  if (
    Moose::Util::does_role(
      $action, 'Catalyst::ActionRole::OAuth2::RequestAuth'
    )
    )
  {
    $self->_request_auth_action($action);
  } elsif (
    Moose::Util::does_role(
      $action, 'Catalyst::ActionRole::OAuth2::GrantAuth'
    )
    )
  {
    $self->_get_auth_token_via_auth_grant_action($action);
  }

  return $action;
};

sub check_provider_actions {
  my ($self) = @_;
  die
    q{You need at least an auth action and a grant action for this controller to work}
    unless $self->_has__request_auth_action
      && $self->_has__get_auth_token_via_auth_grant_action;
}

after register_actions => sub {
  shift->check_provider_actions;
};

1;
