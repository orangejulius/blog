---
layout: post
title: "HTTPS on Nginx: From Zero to A+ (Part 2) - Configuration, Ciphersuites, and Performance"
comments: true
---
When we left off after [part 1](/blog/https-on-nginx-from-zero-to-a-plus-part-1/),
we had a server with a valid, signed certificate running, but it was using the
default Nginx configuration, which leaves quite a bit to be desired.

Now we'll significantly tweak the Nginx configuration to improve both the
security and performance.

Of course the real benefit here is enhanced security, but we also get an A+
rating on the SSL Labs report.
![A+ score on juliansimioni.com](/images/nginx-https/website-aplus.png)

<!-- more -->
## Disable SSLv3
By default Nginx still enables SSLv3{% fn %}, which has been vulnerable to the
[POODLE](https://community.qualys.com/blogs/securitylabs/2014/10/15/ssl-3-is-dead-killed-by-the-poodle-attack) attack
since October 2014. The [only browser](http://en.wikipedia.org/wiki/Transport_Layer_Security#Web_browsers)
that doesn't support newer protocols out of the box is IE6, and even it can be
configured to use TLSv1, so there's no reason to support SSLv3 anymore.

SSL Labs rightly limits your server's SSL score to C if SSLv3 is enabled, so
this is the first thing to change.

```nginx
# support only known-secure cryptographic protocols
# SSLv3 is broken by POODLE as of October 2014
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
```

## Send the Entire Certificate Chain
Browsers use root certificates from Certificate Authorities to determine which
server certificates (such as the one from your website) should be trusted, but
there's almost always an intermediate certificate. To be sure your server's
certificate is valid, browsers need to know about this intermediate certificate.

Of course, browsers can find and download these intermediate certificates, but
this slows down the process of connecting to your website, and makes the whole
process more complicated giving attackers more surface area to exploit.

<figure>
  <img src="/images/nginx-https/incomplete-certificate-chain.png" alt="An Incomplete Certificate chain">
  <figcaption>An incomplete certificate chain</figcaption>
</figure>

It's much better to simply configure Nginx to send this intermediate certificate
along when users first connect. In fact, your SSL score is capped at a B if you
don't.

Your Certificate Authority probably provided you with links to download your
intermediate certificate, so once you've found it, put it somewhere safe on your
server, and tell Nginx about it like this{% fn %}:

```nginx
# send intermediate certificate during new sessions
ssl_trusted_certificate /etc/nginx/ssl/startssl/sub.class1.server.ca.pem;
```

## Ciphersuite Configuration
The SSL/TLS protocols actually don't provide any encryption by themselves.
Instead, they simply allow a server and client to agree on and start
communicating via a channel that could have one of any number of
encryption schemes.

Your server and a client will use SSL/TLS to agree on a combination of four
things: key exchange algorithm (how to safely share encryption keys between the
server and client), authentication (to make sure only the intended
sender/recipient are communicating), encryption algorithm (actually encoding the
messages so no one else can read them), and message digest algorithm (to make
sure the message was not tampered with or corrupted).

There are many of each of these algorithms, all with varying features,
performance, cryptographic strength, and browser support. Many of the algorithms
have known weaknesses that make them unsuitable for use today. Using the latest
version of a browser is usually enough to protect an individual user against
vulnerable ciphersuites. Unfortunately, a lot of older browsers are still
configured to use insecure settings.

The goal of cipher suite configuration is to ensure compatibility with as many
browsers as possible, without compromising security or, to a lesser
extent, performance.

This will be done by setting a configuration string that OpenSSL understands in
our Nginx configuration. To keep thing simple here's the relevant configuration
lines:

```nginx
# make the server choose the best cipher instead of the browser                                                                                                                        
# PFS is frequently compromised without this                                                                                                                                           
ssl_prefer_server_ciphers on; 

# support only believed secure ciphersuites using the following priority:
# 1.) prefer PFS enabled ciphers
# 2.) prefer AES128 over AES256 for speed (AES128 has completely adequate security for now)
# 3.) Support DES3 for IE8 support
#
# disable the following ciphersuites completely
# 1.) null ciphers
# 2.) ciphers with low security
# 3.) fixed ECDH cipher (does not allow for PFS)
# 4.) known vulnerable cypers (MD5, RC4, etc)
# 5.) little-used ciphers (Camellia, Seed)
ssl_ciphers 'kEECDH+ECDSA+AES128 kEECDH+ECDSA+AES256 kEECDH+AES128 kEECDH+AES256 kEDH+AES128 kEDH+AES256 DES-CBC3-SHA +SHA !aNULL !eNULL !LOW !kECDH !DSS !MD5 !EXP !PSK !SRP !CAMELLIA !SEED'; 
```

Now I'll explain the rationale that went into crafting it.

### Make the server choose the ciphersuite
Many browsers, especially old ones, will make poor ciphersuite choices on their
own. The first directive ensures your server will choose from the list of
ciphersuites supported by both the browser and server.

### Disable null and low security ciphersuites
Strangely, it's possible for SSL/TLS to actually use no encryption if configured
improperly.  Fortunately it is easy to disable this ability, as well as force
OpenSSL to disable any cipher suites of known low security, which is a
reasonable starting point.

### Disable insecure algorithms
Some algorithms have known or suspected vulnerabilities, and we can disable or
limit their use where appropriate. The following algorithms in particular should
be disabled:

#### MD5: completely broken, still common

The [MD5](https://en.wikipedia.org/wiki/MD5) hashing algorithm is commonly used
but has had known weaknesses since 1996, only 4 years after it was introduced.
Today, MD5 is famously vulnerable to collisions, especially with GPUs. It simply
isn't safe to use any more.

#### RC4: former poster child, recently tarnished

The [RC4](https://en.wikipedia.org/wiki/RC4) cypher is also commonly used, and
[until recently](https://blog.cloudflare.com/killing-rc4/) was widely
recommended.  However, information revealed by no less than Edward Snowden
himself has [suggested](http://www.theregister.co.uk/2013/09/06/nsa_cryptobreaking_bullrun_analysis/)
that it's possible the NSA has the ability to break RC4.

Combined with research showing theoretical vulnerabilities in RC4, the possibility
that there are working attacks against RC4 in the wild is too plausible to
ignore. Microsoft has issued a [security advisory to disable
RC4](http://blogs.technet.com/b/srd/archive/2013/11/12/security-advisory-2868725-recommendation-to-disable-rc4.aspx),
and the IETF is
[drafting a memo to require clients and servers never use RC4](https://tools.ietf.org/html/draft-ietf-tls-prohibiting-rc4-01).

#### SHA1: rapidly approaching affordable attacks

In [part 1](/blog/https-on-nginx-from-zero-to-a-plus-part-1/) we generated a
certificate request using [SHA256](http://en.wikipedia.org/wiki/SHA-2)
instead of [SHA1](http://en.wikipedia.org/wiki/SHA-1).  For the same reasons, we
also have to disable ciphersuites that use SHA1 as the hashing algorithm.

### Disable little-used ciphers
These are not common, and disabling them just simplifies things and reduces the
surface area for attacks.

### Optimize for performance where appropriate
Despite some algorithms occasionally being found vulnerable, modern browsers
actually support a comprehensive suite of extremely powerful security tools. All
four algorithms specified by NIST [Suite B cryptography](https://www.nsa.gov/ia/programs/suiteb_cryptography/index.shtml)
for use protecting NSA TOP SECRET documents, including AES and SHA2, are
currently supported by a good portion of the browsers in use today.

Many security experts consider that using the longest key lengths currently
supported does not have any
[measurable impact on security](http://www.mail-archive.com/dev-tech-crypto@lists.mozilla.org/msg11247.html),
and simply reduces performance{% fn %}.

A common configuration that takes this into account is to support these most
secure variants, but prefer more reasonable key lengths. For example, the
configuration above supports both the  `ECDHE-ECDSA-AES256-SHA384` and
`ECDHE-ECDSA-AES128-SHA256` ciphersuites, but prefers the shorter variant. Both
provide excellent security with no known attacks. This makes the default for
most users secure and reasonably performant, but allows users to demand the most
secure ciphersuites if they so desire.

### Support perfect forward secrecy whenever possible
[Perfect forward secrecy](https://en.wikipedia.org/wiki/Forward_secrecy) allows
a secure connection to use encryption keys that are custom generated for that
specific session. The security advantage this provides is incredible: **even if
the private key for a server is compromised, none of the messages sent to that
server in the past can be decoded**.

Furthermore, even if an attacker manages to successfully compromise a session
key used by your server, they only gain access to a single session. This
increases the cost, and decreases the reward, of attacking communication with
your server.

A great recent example of this is Heartbleed: with perfect forward
secrecy, the Heartbleed vulnerability can only expose
[individual sessions](
https://twitter.com/ivanristic/status/453280081897467905). You'd still have to
update your server's private key, but almost all user data would be safe.

Most reasonably modern browsers, with the notable exception of IE8, support key
exchange algorithms with perfect forward secrecy.

## Enable HSTS
Many concepts in security involve correctly implementing a specific, precise
procedure like a cryptographic algorithm to achieve a mathematically proven
level of security.
[HSTS](http://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) is not one of them.

Enabling HSTS simply tells browsers not to make any plain text requests to a
server _ever again_. 

In theory, this provides no benefits over a server properly configured to
require a valid HTTPS connection for all resources, at all times. In practice,
**HSTS protects against a huge number of configuration errors that are easy to
make**.

It's also easy to implement: all that is required is for the server to send a
valid HSTS header with each HTTP request, and the browser will do the rest.

```nginx
# enable HSTS including subdomains
add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains;'
```
This tells browsers to avoid plain HTTP requests to your server and all
subdomains for one year. It's perfectly reasonable to remove the
`includeSubdomains` clause if not all your subdomains are ready for HTTPS.

Note that by enabling HSTS, you are essentially promising to browsers that your
server will correctly respond to HTTPS requests until the header expires. This
means its probably **not something that should be enabled on day one of an HTTPS
roll out**.

Once you're convinced that enabling HTTPS going forward is possible, you can
also [submit your site](https://hstspreload.appspot.com/) for HSTS Preload,
allowing the latest versions of popular browsers to ship already knowing your
server expects only HTTPS requests. This is incredible: **browsers will not have
to make even one HTTP request to your server when initially connecting**.

By the way, HSTS is the final step towards that A+ rating!

## Improve Performance
There are a few more configuration changes that should be made to improve
performance. As far as I know these either have no detrimental impact on
security, or actually help improve it.

### Set up OCSP Stapling
Before a browser will connect to a server using HTTPS, it has to check if the
certificate the server is using is still valid. An upgrade or
response to an attack could cause a certificate to be revoked, and its important
to know about it.

Without further action on your part, every browser connecting to your server
will have to pause when first connecting to ask an OCSP server for the latest
revocation information for. OCSP stapling allows your server to do this ahead of
time. The OCSP responses are signed by your Certification Authority, so browsers
will be able to trust them, even if they come directly from your server.

This also cuts down on traffic to OCSP servers (a nice thing for you to do), and
protects your server against unexpected interruptions because of
downtime or denial of service attacks against your OCSP server.

## Support SSL Session Caching

## Resources and Thanks


- - -
{% footnotes %}
  {% fnbody %}
    The Nginx blog has an <a href="http://nginx.com/blog/nginx-poodle-ssl/">article about POODLE</a>,
    suggesting that everyone using Nginx disable SSLv3, so hopefully the default
    will change soon.
  {% endfnbody %}

  {% fnbody %}
    Many tutorials, like Eric Mill's <a href="https://konklone.com/post/switch-to-https-now-for-free#generating-the-certificate">Switch to HTTPS Now, For free</a>
    suggest performing something equivalent by concatenating the root certificate,
    intermediate certificate, and your server's certificate together into one
    file. This works just fine, but I prefer keeping the files separate for
    clarity. Use whichever method works better for you.
  {% endfnbody %}

  {% fnbody %}
    For the same reasons, I don't believe it makes sense to use certificates
    with 4096-bit keys, 4096-bit <a href="http://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange">Diffie-Hellman key exhange</a>
    parameters, or similar changes. You can actually improve subscores of your
    SSL score using them, but it will come at a performance cost.
  {% endfnbody %}
{% endfootnotes %}
