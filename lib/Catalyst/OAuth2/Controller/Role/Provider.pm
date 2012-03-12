package Catalyst::OAuth2::Controller::Role::Provider;
use Moose::Role;
use MooseX::SetOnce;
use Moose::Util;

has $_ => (
  isa       => 'Catalyst::Action',
  is        => 'rw',
  traits    => [qw(SetOnce)],
  predicate => "_has_$_"
) for qw(_request_auth_action _get_auth_token_via_auth_grant_action);

around create_action => sub {
  my $orig   = shift;
  my $self   = shift;
  my $action = $self->$orig(@_);
  if (
    Moose::Util::does_role(
      $action, 'Catalyst::ActionRole::OAuth2::RequestAuth'
    ))
  {
    $self->_request_auth_action($action);
  } elsif (
    Moose::Util::does_role(
      $action, 'Catalyst::ActionRole::OAuth2::GrantAuth'
    ))
  {
    $self->_get_auth_token_via_auth_grant_action($action);
  }

  return $action;
};

sub check_provider_actions {
  my ($self) = @_;
  return $self->_has__request_auth_action
    && $self->_has__get_auth_token_via_auth_grant_action;
}

1;
