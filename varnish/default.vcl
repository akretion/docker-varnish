#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and https://www.varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

import header;
import cookie;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "172.30.0.252";
    .port = "3000";
}

sub vcl_recv {
    if (req.url ~ "^/locomotive") {
         return(pass);
    }
    if (req.http.Cookie && (req.method == "GET" || req.method == "HEAD")) {
        cookie.parse(req.http.Cookie);

        # cart, customer are special cookie that change depending of the
        # value of the store.cart and store.customer
        # role, locale, currency impact the rendered of the page
        # We need to pass them into the header in order to be able to have
        # a cached version of the page that depend of this special cookie
        # it will be better to have something dynamic that inject all cookie
        # in the header so the Vary can be used without varnish customisation
        if (cookie.get("cart")) {
            set req.http.Cart = cookie.get("cart");
        }
        if (cookie.get("customer")) {
            set req.http.Customer = cookie.get("customer");
        }
        if (cookie.get("role")) {
            set req.http.Role = cookie.get("role");
        }
        if (cookie.get("locale")) {
            set req.http.Locale = cookie.get("locale");
        }
        if (cookie.get("currency")) {
            set req.http.Currency = cookie.get("currency");
        }
        if (cookie.get("cookies_manager")) {
            set req.http.Cookies_manager = cookie.get("cookies_manager");
        }
        return(hash);
    }
}


sub vcl_backend_response {
    set beresp.do_esi = true;
    if (beresp.ttl <= 0s || beresp.http.Cache-Control ~ "no-cache|no-store|private") {
        # Mark as "Hit-For-Pass" for the next 30 minutes
        set beresp.ttl = 1800s;
        set beresp.uncacheable = true;
    } else {
        if (beresp.http.Set-Cookie) {
            # never cache cookie that depend of the customer
            header.remove(beresp.http.Set-Cookie, "rack.session=");
            header.remove(beresp.http.Set-Cookie, "_session_id=");
            header.remove(beresp.http.Set-Cookie, "_role=");
        }
    }
    return (deliver);
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.
    if (obj.hits > 0) {
      set resp.http.X-Cache = "HIT";
    } else {
      set resp.http.X-Cache = "MISS";
    }
}
