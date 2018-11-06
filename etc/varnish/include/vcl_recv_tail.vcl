  # This is the default cookie session handling, specifics should be mounted over this file

  # Remove all cookies that Drupal does not need to know about. ANY remaining
  # cookie will cause the request to pass-through to web server. For the most part
  # we always set the NO_CACHE cookie after any POST request, disabling the
  # Varnish cache temporarily. The session cookie allows all authenticated users
  # to pass through as long as they are logged in.
  if (req.http.Cookie) {

    # simple saml remove cookies else attempting to login goes into a loop
    # https://www.drupal.org/node/2651192
    if (req.http.Cookie ~ "NO_CACHE") {
      return (pass);
    }

    # for rules that should cause bypass outside of the logic below
    include "include/bypass-rules.vcl";

    # Append a semi-colon to the front of the cookie string.
    set req.http.Cookie = ";" + req.http.Cookie;

    # logged in, going to login functionality or not fulcrum user cachable
    if (
      req.http.Cookie ~ ";\s*S?SESS[a-z0-9]+\s*="
    ) {
      # Remove all spaces and semi-colons from the beginning and end of the cookie string.
      set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");
      return (pass);
    } else {
      unset req.http.Cookie;
    }
  }