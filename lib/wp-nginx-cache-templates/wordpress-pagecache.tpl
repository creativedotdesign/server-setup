fastcgi_cache_key "$scheme$request_method$host$request_uri";
add_header X-Cache $upstream_cache_status;

fastcgi_cache_path %home%/%user%/web/%domain%/cache levels=1:2 keys_zone=%domain%:100m inactive=60m;

server {
    listen      %ip%:%web_port%;
    server_name %domain_idn% %alias_idn%;
    root        %docroot%;
    index       index.php index.html index.htm;
    access_log  /var/log/nginx/domains/%domain%.log combined;
    access_log  /var/log/nginx/domains/%domain%.bytes bytes;
    error_log   /var/log/nginx/domains/%domain%.error.log error;
    
    set $skip_cache 0;

    # POST requests and urls with a query string should always go to PHP
    if ($request_method = POST) {
        set $skip_cache 1;
    }

    if ($query_string != "") {
        set $skip_cache 1;
    }   

    # Don’t cache uris containing the following segments
    if ($request_uri ~* "/wp-admin/|/xmlrpc.php|wp-.*.php|/feed/|index.php|sitemap(_index)?.xml") {
        set $skip_cache 1;
    }   

    # Don’t use the cache for logged in users or recent commenters
    if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
        set $skip_cache 1;
    }
    
    # Skip cache on WooCommerce pages
    if ($request_uri ~* "/store.*|/cart.*|/my-account.*|/checkout.*|/addons.*") {
        set $skip_cache 1;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location / {
        try_files $uri $uri/ /index.php?$args;

        location ~* ^.+\.(jpeg|jpg|png|gif|bmp|ico|svg|css|js)$ {
            expires     max;
        }

        location ~ [^/]\.php(/|$) {
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            if (!-f $document_root$fastcgi_script_name) {
                return  404;
            }
            
            fastcgi_cache_bypass $skip_cache;
            fastcgi_no_cache $skip_cache;
            fastcgi_cache %domain%;
            fastcgi_cache_valid 60m;

            fastcgi_pass    %backend_lsnr%;
            fastcgi_index   index.php;
            include         /etc/nginx/fastcgi_params;
        }
    }
    
    location ~ /purge(/.*) {
        fastcgi_cache_purge %domain% "$scheme$request_method$host$1";
    }

    error_page  403 /error/404.html;
    error_page  404 /error/404.html;
    error_page  500 502 503 504 /error/50x.html;

    location /error/ {
        alias   %home%/%user%/web/%domain%/document_errors/;
    }

    location ~* "/\.(htaccess|htpasswd)$" {
        deny    all;
        return  404;
    }

    location /vstats/ {
        alias   %home%/%user%/web/%domain%/stats/;
        include %home%/%user%/web/%domain%/stats/auth.conf*;
    }

    include     /etc/nginx/conf.d/phpmyadmin.inc*;
    include     /etc/nginx/conf.d/phppgadmin.inc*;
    include     /etc/nginx/conf.d/webmail.inc*;

    include     %home%/%user%/conf/web/nginx.%domain_idn%.conf*;
}