---
layout: post
title: "HTTPS on Nginx: From Zero to A+ (Part 1)"
date: "2015-02-01 18:26:02 +0100"
comments: true
categories: security
---
For well over a year now, my website has been using an extremely simple setup:
Nginx hosting static files from [Octopress](http://octopress.org). Compared to
my old setup (a heavy Apache install with tons of modules), it's a breeze to
setup and maintain.

When I made the switch, the consensus was that HTTPS was only needed in a few
sensitive places. A static site definitely wasn't one of them, so I never
bothered with it{% fn %}.

Well, a [lot has happened since then](http://en.wikipedia.org/wiki/Global_surveillance_disclosures_%282013%E2%80%93present%29)
and people are [changing their mind](http://blog.codinghorror.com/should-all-web-traffic-be-encrypted/).
Both the [EFF](https://www.eff.org/encrypt-the-web) and
[W3C](http://www.w3.org/blog/TAG/2015/01/23/securing-the-web/) have started
large campaigns to encourage developers to make encryption the default
everywhere, where previously the perception was there was no benefit.

Finally encouraged by [Eric Mill](https://konklone.com/)'s
fantastic _[Switch to HTTPS Now, For Free](https://konklone.com/post/switch-to-https-now-for-free)_,
I spent a good part of my holidays setting up HTTPS.

The basic setup is simple, but I also spent a lot of time researching what sort
of configuration changes can be made to increase security and performance. These
are my notes for setting up an HTTPS server that scores
[A+](https://www.ssllabs.com/ssltest/analyze.html?d=juliansimioni.com) on the
[Qualys SSL Report](https://www.ssllabs.com/ssltest/),
and costs zero dollars to implement{% fn %}.

![A+ score on juliansimioni.com](/images/nginx-https/website-aplus.png)

Besides the actual configuration, I've included background on what each change
means, and why the consensus says it's the best option.

This is part 1, which will cover initial setup and getting your SSL certificate.

Part 2 will cover further Nginx configuration and cyphersuite setup.

## Initial Setup: Use a Self-Signed Certificate
Simply enabling HTTPS requires very little: a server needs an encryption key and
a certificate file. Both of these can be generated quickly and easily on any
machine with OpenSSL installed.

While these self-signed certificates don't provide any true security{% fn %}
its worth the time to set one up up before moving onto a real certificate to get
a feel for the process and fix as many issues as possible early on.

There are [far](http://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl)
[too](https://www.openssl.org/docs/HOWTO/certificates.txt)
[many](https://devcenter.heroku.com/articles/ssl-certificate-self)
[tutorials](https://www.linode.com/docs/security/ssl/ssl-certificates-with-nginx)
[already](https://www.openssl.org/docs/HOWTO/certificates.txt)
on generating self-signed certs, so I won't go into a huge amount of detail
here. A simple command like the following will suffice:

```bash
mkdir /etc/nginx/ssl
cd /etc/nginx/ssl
openssl req -new -x509 -sha256 -newkey rsa:2048 -days 365 -nodes -out /etc/nginx/ssl/nginx.pem -keyout /etc/nginx/ssl/nginx.key
```

The Nginx configuration section for basic SSL{% fn %} is also straightforward. Just add
the following configuration to your nginx file:

```nginx
server {

      # [...]

      listen 443;
      ssl on; 
      ssl_certificate      /etc/nginx/ssl/nginx.pem;
      ssl_certificate_key  /etc/nginx/ssl/nginx.key;  

      # [...]
}
```
_(Both code snippets above adapted from the
[Linode certifficate guide](https://www.linode.com/docs/security/ssl/ssl-certificates-with-nginx), also linked above. It's one of the best)_

Now armed with a valid certificate, restarting Nginx should allow your website
to load over HTTPS, although it will probably greet you with a nasty warning
because the certificate is self-signed. It's time to do a few initial checks for
critical features before we dive in with a full certificate.

### Check for a Modern Version of OpenSSL
The [OpenSSL](https://www.openssl.org/) library is the almost ubiquitous SSL and
TLS library, and its used by nearly every web server, including Nginx. If your
version of OpenSSL is out of date, it might have one of
[any number](https://en.wikipedia.org/wiki/OpenSSL#Notable_vulnerabilities) of
security vulnerabilities.

The worst of these is, of course, [Heartbleed](http://heartbleed.com/), which
potentially allows leaking all sorts of data __including your webservers private
keys__. Heartbleed was first made public in April 2014, but many websites are
[still vulnerable](http://www.arnnet.com.au/article/564350/more-than-half-all-openssl-remain-vulnerable-heartbleed-cisco/).
Don't be one of them.

Check the OpenSSL website for the latest stable version, and then check yours
like this:

```bash
$ openssl version
OpenSSL 1.0.1k 8 Jan 2015
```

### Ensure You've Created a 2048-bit, SHA256-signed Certificate
Self signed certificates can be easily regenerated with no cost
or downtime, so its best to iron out certificate configuration issues now.
Revoking even a free StartSSL certificate [costs $25](https://www.startssl.com/?app=37),
so mistakes later on are more costly and time consuming.

The most important certificate configuration setting is the fingerprint hashing
algorithm.  Until recently, most certificates were signed using
[SHA1](grade-c-immediately-after-certificate-registration.png).  However,
[Google](http://blog.chromium.org/2014/09/gradually-sunsetting-sha-1.html),
[Microsoft](https://technet.microsoft.com/library/security/2880823), and
[security researchers](https://www.schneier.com/blog/archives/2012/10/when_will_we_se.html)
in general are now pushing hard to
deprecate SHA1 quickly: its becoming dangerously insecure as computing power
advances. In its place, new certificates should be signed using
[SHA256](http://en.wikipedia.org/wiki/SHA-2).

There are no known attacks against SHA1 yet, but both Chrome and
[Firefox](https://blog.mozilla.org/security/2014/09/23/phasing-out-certificates-with-sha-1-based-signature-algorithms/)
will soon show warnings or errors for certificates signed with SHA1, so creating
a new certificate today without using SHA256 is a big mistake.

Likewise, a 2048-bit RSA key size is currently
[optimal](https://www.rapidssl.com/2048-bit-certificate-compliance/){% fn %}. 1024-bit
certificates are _well_ into the realm where someone with a sufficiently
powerful computer network could
[break them](https://www.schneier.com/blog/archives/2010/01/768-bit_number.html).
Again, browsers are now actively discouraging their use: Mozilla has
[removed](https://blog.mozilla.org/security/2014/09/08/phasing-out-certificates-with-1024-bit-rsa-keys/)
1024-bit Certificate Authority keys from the list of trusted certificates
starting in Firefox 32, released in September 2014.

If you used the commands above to generate your self-signed certificate, it
should already use SHA256 and a 2048 bit RSA key, but the following commands can
be used to check:

```bash
openssl x509 -in /etc/nginx/ssl/nginx.pem -text -noout | grep "Signature\|Public-Key"
# Should give the following output:
#	Signature Algorithm: sha256WithRSAEncryption
# Public-Key: (2048 bit)
#	Signature Algorithm: sha256WithRSAEncryption
```
_(Adapted from
[this](serverfault.com/questions/325467/i-have-a-keypair-how-do-i-determine-the-key-length)
ServerFault Answer)_

If it shows `sha1WithRSAEncryption` or `(1024 bit)` instead, go back and
regenerate your certificate with the correct settings.

### Check for Mixed-Content Warnings
At this point, there's a very good chance some resources on your website, like
Javascript, CSS, or images, are still being loaded over HTTP, even when the
initial request is made over HTTPS. 

![Mixed content warning in Firefox](/images/nginx-https/mixed-content.png)
_An example of a mixed-content warning in Firefox_

It used to be considered enough to use HTTPS only for critical sections of a
website, such as a login page and form submissions, but no longer. Modern
browsers
[block](https://developer.mozilla.org/en-US/docs/Security/MixedContent/How_to_fix_website_with_mixed_content)
the more dangerous varieties of mixed contact (namely Javascript and CSS files).

This has a tremendous security benefit to users, because those files can
potentially be modified while in transit and cause
[serious harm](https://developer.mozilla.org/en-US/docs/Security/MixedContent#Mixed_active_content): sensitive user information can be stolen, or malware added to their system.

Fixing mixed-content warnings is very specific to your website's code, but
in principal it simply involves changing any links that start with `http://` to
`https://`. This includes links to any resources loaded from other servers. If
those servers don't support HTTPS yet, you have to get rid of the resource
entirely or host it yourself, if possible.

If you really need to support both HTTP and HTTPS,
[protocol-relative URLs](http://www.paulirish.com/2010/the-protocol-relative-url/)
can help, but are discouraged.

## Doing it For Real: Use a CA-signed Certificate

Now that these basic issues are tackled, it's time to create a certificate that
browsers will recognise as trusted. This can be a lengthy process for a couple
of reasons, so let's cover the prerequisites first. You'll need:

1. An account with a Certificate Authority.
2. Access to `webmaster@yourdomain.com`, `postmaster@yourdomain.com` or
   whichever email is listed in the SOA record of your domain's DNS entry.
3. A certificate request(CSR) file.

Step 1 is potentially a little more cumbersome than signing up for an average
website, which is understandable considering the security concerns, but should
be manageable. If you haven't chosen a certificate authority,
[StartSSL](https://www.startssl.com/) is excellent, and free. Paid options
include [Verisign](http://www.verisign.com/) and
[Comodo](https://www.comodo.com/).
Please [don't use GoDaddy](http://breakupwithgodaddy.com/).

Step 2 won't be covered here in detail as it's highly specific to your DNS
setup. If you don't already have this set up properly, it can take a few hours
for the DNS entries to take effect once you've made the change, so get started
now. 

However, if, like me, you are using [Fastmail](https://fastmail.com)
for email from your domain, then they have already set up everything for you. If
you _aren't_ using Fastmail, they are awesome and I can't recommend them enough.

Once you've completed steps 1 and 2, you can create the CSR.  This file details
what domain you want a certificate for, and any options. Some Certificate
Authorities will offer to "help" you by generating a private key and CSR for you
in the browser.  Decline their offer, since we've already generated a private
key, and we don't need that potential breach of security.

The following command will generate a nice CSR for you:
```bash
openssl req -new -sha256 -key /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/yourwebsite.com.csr
```

Paste that into the form for the CSR on your CA's webpage, and they will send
back a certificate. Keep it safe and store it on your server, somewhere like
`/etc/nginx/ssl/yourwebsite.com.crt`.

If you happen to be using StartSSL, Erik Mill's [tutorial](https://konklone.com/post/switch-to-https-now-for-free) which I linked to above walks through every step perfectly!

Initially, you can simply point Nginx at the new key and crt file from your CA
just like you did your self-signed cert and things should work{% fn %}. Congratulations! Your web server is now running TLS with a valid certificate.

If you were to run the SSL Labs test on your website right now, you'd probably
see something like this:

![freshly-minted-certificate-test](/images/nginx-https/grade-c-immediately-after-certificate-registration.png)

It's not bad, but the default Nginx settings only get you to a C grade - barely
passing. In the next part we'll look at what it takes to configure Nginx so that
you achieve an A+ rating. Stay tuned!

----------------------------------------------------
{% footnotes %}
  {% fnbody %}
My server didn't even respond to HTTPS, or anything on port 443, for this entire
time!
  {% endfnbody %}
  {% fnbody %}
Beyond the basic hosting costs, obviously.
  {% endfnbody %}
  {% fnbody %}
For truly secure communication, three things are needed: verification the
message came from who you thought it did (authentication), obfuscation of the
message contents so that no one but the intended recipient can read the message
(encryption), and a way to verify that the message was not changed while in
transit (message digest).  A self-signed certificate doesn't provide any
authentication, so it's mostly useless.

The Wikipedia page on <a href="http://en.wikipedia.org/wiki/Transport_Layer_Security">TLS</a>
provides an excellent overview of how this all works.
  {% endfnbody %}
  {% fnbody %}
 When I say SSL, I <a href="https://twitter.com/chriseng/status/560239317574905856">really mean</a>
 TLS. Both SSL and TLS share the same heritage. TLS is simply the name for newer
 versions. All versions of SSL are now out of date, but the name has stuck.
  {% endfnbody %}
  {% fnbody %}
4096 bit keys are, at this point, considered excessive except for Certificate
Authorities, so 2048 is the best size. Remember, a 2048 bit key is not twice as
secure as a 1024 bit key, it's
<a href="http://www.wolframalpha.com/input/?i=2%5E1024"> 2<sup>1024</sup></a> times as
secure! It is twice as slow however. 2048 bits is going to be enough for quite
some time, so 4096 bit keys just make the encryption process slower.
  {% endfnbody %}
  {% fnbody %}
Initially, you will probably get an OCSP error (looks like <a href
="/images/nginx-https/ocsp-error-after-certificate-creation.png">this</a>). This
will go away in a few hours. The Online Certificate Status Protocol (OCSP) is a
system for determining if a certificate has been revoked. Since your certificate
is brand new, there's no information in the system confirming your certificate
is still valid, and it will take a little while to get there. We'll learn more
about OCSP in the next post.
  {% endfnbody %}
{% endfootnotes %}
