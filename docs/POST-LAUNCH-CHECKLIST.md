# Post-Launch Checklist


#### DNS and Subdomain Rerouting

Ensure that all internal and external DNS records are setup pointing/aliased to the correct locations.
For subdomains that should resolve to the subdomain-less root, ensure that the proper rule is written 
in the NGINX config:

```nginx
# /etc/nginx/sites-available/$DOMAIN_NAME

server {
  # Actual server config
}

server {
  server_name www.$DOMAIN_NAME *.$DOMAIN_NAME;
  rewrite ^/(.*)$ http://$DOMAIN_NAME/$1 permanent;
}
```


#### Certbot

Every site must have an SSL certificate. With tech like LetsEncrypt, we have no excuse to not secure our
sites, especially sites that have form submissions regardless of whether it is sensitive data or not.

```bash
sudo certbot --nginx -d $DOMAIN_NAME
```

__All sites should be setup to automatically redirect to the secure version of the site.__


#### PageSpeed Insights

It would be desireable to achieve the maximum possible score when run through Google's PageSpeed Insights.
The ideal would be to have a score of at least 80/100; any red score should be considered unnacceptable. 
We can ammend our issues by following the suggestions given under the sub-sections shown on the page. Since 
PageSpeed Insights is widely used, there are also plenty of articles and blog posts that explain how to 
execute the steps necessary to achieve our desired score.

[Google PageSpeed Insights](https://developers.google.com/speed/pagespeed/insights/)
