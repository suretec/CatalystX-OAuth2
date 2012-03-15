package Catalyst::ActionRole::OAuth2::RequestAuth;
use Moose::Role;
use Try::Tiny;
use URI;
use Catalyst::OAuth2::Request::RequestAuth;

with 'Catalyst::OAuth2::ActionRole::Grant';

=pod

   The client constructs the request URI by adding the following
   parameters to the query component of the authorization endpoint URI
   using the "application/x-www-form-urlencoded" format as defined by
   [W3C.REC-html401-19991224]:

   response_type
         REQUIRED.  Value MUST be set to "code".
   client_id
         REQUIRED.  The client identifier as described in Section 2.2.
   redirect_uri
         OPTIONAL.  As described in Section 3.1.2.
   scope
         OPTIONAL.  The scope of the access request as described by
         Section 3.3.
   state
         RECOMMENDED.  An opaque value used by the client to maintain
         state between the request and callback.  The authorization
         server includes this value when redirecting the user-agent back
         to the client.  The parameter SHOULD be used for preventing
         cross-site request forgery as described in Section 10.12.

   The client directs the resource owner to the constructed URI using an
   HTTP redirection response, or by other means available to it via the
   user-agent.

   For example, the client directs the user-agent to make the following
   HTTP request using TLS (extra line breaks are for display purposes
   only):


    GET /authorize?response_type=code&client_id=s6BhdRkqt3&state=xyz
        &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb HTTP/1.1
    Host: server.example.com


   The authorization server validates the request to ensure all required
   parameters are present and valid.  If the request is valid, the
   authorization server authenticates the resource owner and obtains an
   authorization decision (by asking the resource owner or by
   establishing approval via other means).

   When a decision is established, the authorization server directs the
   user-agent to the provided client redirection URI using an HTTP
   redirection response, or by other means available to it via the user-
   agent.

=cut

sub build_oauth2_request {
  my ( $self, $controller, $c ) = @_;

  my $store = $controller->client_store($c);
  try {
    my $req = Catalyst::OAuth2::Request::RequestAuth->new(
      %{ $c->req->query_parameters } );
    $req->client_store($store);
  }
  catch {

    # need to figure out a better way, but this will do for now
    $c->res->body('warning: response_type/client_id invalid or missing');

    $c->detach;
  };

}

after execute => sub {
  my ( $self, $controller, $c ) = @_;
  my $oauth2      = $c->req->oauth2;
  my $next_action = $controller->_get_auth_token_via_auth_grant_action;
  my $uri         = $c->uri_for( $next_action, $oauth2->query_parameters );
  $c->res->redirect($uri);
};

=pod

If the resource owner denies the access request or if the request
   fails for reasons other than a missing or invalid redirection URI,
   the authorization server informs the client by adding the following
   parameters to the query component of the redirection URI using the
   "application/x-www-form-urlencoded" format:

   error
         REQUIRED.  A single error code from the following:
         invalid_request
               The request is missing a required parameter, includes an
               invalid parameter value, or is otherwise malformed.
         unauthorized_client
               The client is not authorized to request an authorization
               code using this method.
         access_denied
               The resource owner or authorization server denied the
               request.
         unsupported_response_type
               The authorization server does not support obtaining an
               authorization code using this method.
         invalid_scope
               The requested scope is invalid, unknown, or malformed.
         server_error
               The authorization server encountered an unexpected
               condition which prevented it from fulfilling the request.
         temporarily_unavailable
               The authorization server is currently unable to handle
               the request due to a temporary overloading or maintenance
               of the server.
   error_description
         OPTIONAL.  A human-readable UTF-8 encoded text providing
         additional information, used to assist the client developer in
         understanding the error that occurred.
   error_uri
         OPTIONAL.  A URI identifying a human-readable web page with
         information about the error, used to provide the client
         developer with additional information about the error.
   state
         REQUIRED if a "state" parameter was present in the client
         authorization request.  The exact value received from the
         client.

   For example, the authorization server redirects the user-agent by
   sending the following HTTP response:


   HTTP/1.1 302 Found
   Location: https://client.example.com/cb?error=access_denied&state=xyz

=cut

1;
