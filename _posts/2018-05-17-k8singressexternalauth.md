# Overview
I should note that the [official documentation](https://github.com/kubernetes/ingress-nginx) explains things much better than I could.

The NGINX Ingress Controller functions as a Kubernetes-aware reverse-proxy.

Kubernetes allows you to create a resource called "ingress", which is effectively a mapping of a domain + path to a Kubernetes service + port.

You can also tell Kubernetes to secure a particular domain + path with HTTPS and/or one of a few generic methods of authentication.

Below are a few of the benefits that can be easily achieved using the NGINX Ingress Controller.


## Example Ingress Resource
Here is an example of an Ingress resource that secures a path using External Auth and TLS:
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx-test
  annotations:
    # An example service that only accepts "user:passwd" as valid credentials
    nginx.ingress.kubernetes.io/auth-url: "https://httpbin.org/basic-auth/user/passwd"
spec:
  tls:
    - hosts:
      - foo.bar.com
      # This assumes tls-secret exists and the SSL 
      # certificate contains a CN for foo.bar.com
      secretName: tls-secret
  rules:
    - host: foo.bar.com
      http:
        paths:
        - path: /
          backend:
            # This assumes http-svc exists and routes to healthy endpoints
            serviceName: http-svc
            servicePort: 80
```

# TLS Termination
First and foremost, applying TLS termination to all of your services is usually a pain.

With the Ingress Controller, we simply import a single set of certs into a Kubernetes Secret, and point our ingress annotations at that secret to enable TLS! 

No more needing to worry about having a separate, special TLS cert for each of your services - just apply a single TLS cert to your rules and let the Ingress Controller do the rest!

If you have real certs, you can use those instead. If not, you can generate a self-signed cert to encrypt your traffic, but this does nothing to prove your authority to manage the domain:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/C=US/ST=IL/L=Champaign/O=UIUC/OU=NCSA/CN=foo.bar.com"
```

This will output a .cert and a .key file. Now, you just need to create a secret containing the key and the cert:

```bash
kubectl create secret tls tls-secret --key tls.key --cert tls.crt
```

Now that you've got a "tls-secret", you can reference this in your ingress rule to enable HTTPS:
```yaml
spec:
  tls:
    - hosts:
      - foo.bar.com
      # This assumes tls-secret exists and the SSL
      # certificate contains a CN for foo.bar.com
      secretName: tls-secret
```

Full Example: https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/tls-termination

## Multi-Domain / Wildcard Certificates
There is no difference in configuring multi-domain or wildcard certificates for TLS termination using the Ingress Controller.

You do, however, still need to make sure that your certificate is generic enough to cover all of the domains that you'd like the secure with HTTPS.

For example: A certificate for "xxx.zzz.com" would not be valid for host "yyy.zzz.com" - either a multi-domain certificate containing both entries or a wildcard certificate for "*.zzz.com" would be necessary to secure both subdomains.

## LetsEcrypt + kube-lego
Sick of renewing your certs manually? Try LetsEncrypt!

[kube-lego](https://github.com/jetstack/kube-lego) is a project that is attempting to integrate Kubernetes Ingress with the automated, hands-off beauty of LetsEcrypt.

We have previously had some success in setting this up, or another similar project, to automate TLS cert creation and renewal.

# External Auth
Authentication using the NGINX Ingress Controller has made great strides recently, with support being added for [bitly's oauth2_proxy](https://github.com/bitly/oauth2_proxy).

You can specify one of several authentication classes of authentication to secure ingress to your application:

* Basic Auth - create a username and password that the user will be prompted for when attempting to access this ingress domain/path
* Client Certificates - create a TLS cert that can be used to automatically authenticate you into service that you have access to 
* External Auth - set an "auth" annotation to determine whether user is authenticated, set "sign_in" annotation to determine where they should be routed in order to authenticate them
* Basic Auth: https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/auth/basic

Client Certificate Auth: https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/auth/client-certs

External Auth: https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/auth/external-auth

External Auth via OAuth2: https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/auth/oauth-external-auth

## TLS is Required!
It is important to note that not a single one of these methods is secure without also securing TLS for your application.

Without TLS, requests are sent in plaintext, including your authorization information (such as Basic Auth, certificates, or OAuth2 tokens).

This is likely true even during the authorization chain, when you are passing credentials or certificates back and forth.

## Customizing Headers / Error Pages / etc
Every application needs a cute 404 page, doesn't it?

You can edit the ConfigMap to specify which HTTP error messages (e.g. 404, 501, 503, etc) should serve custom templates.

You can also adjust which headers are passed to your upstream servers by adjusting the ConfigMap, along with many other configuration options.

Custom Errors Example: https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/customization/custom-errors

Custom Headers Example: https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/customization/custom-headers

# More Examples
A list of many more examples can be found here: https://github.com/kubernetes/ingress-nginx/blob/master/docs/examples/index.md
