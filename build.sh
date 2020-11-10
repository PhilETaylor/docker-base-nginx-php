#docker build . --tag registry.myjoomla.com/base-nginx-php:latest --no-cache --rm=false 
docker build . --tag registry.digitalocean.com/mysites/base-nginx-php:php8 --no-cache --rm=false 
# docker push registry.myjoomla.com/base-nginx-php:latest