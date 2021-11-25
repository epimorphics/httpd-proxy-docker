# httpd proxy

An apache httpd server set up to be usable as a proxy for data/presentation tiers

Builds on bitname httpd base image but enables the auth module:

   * mod_auth_openidc

Also includes the following modules:

   * mod_proxy
   * mod_proxy_ajp
   * mod_proxy_httpd
   * mod_rewrite

## Configuration

Files mounted under `/vhosts` are copied to the configuration image and included in the httpd startup.

Root document directory is `/app` so static resources can be mounted here.

Runs as a non-root user on port 8080 so vhost files must match that port.

See: [bitnami-docker-apache](https://github.com/bitnami/bitnami-docker-apache) for full configuration details.

## Example for a data tier proxy

    docker run --network=dnet --name=proxy -p 80:8080 -v $PWD/conf:/vhosts epimorphics/httpd-proxy-oauth:latest

Where the `./conf` directory contains a vhost file such as:

```
<VirtualHost *:8080>	
    ProxyPreserveHost       On
    ProxyPass /landregistry/query             http://fuseki:3030/landregistry/query    max=7 retry=0
    ProxyPass /landregistry-stdreports/query  http://fuseki:3030/landregistry_to/query max=2 retry=0
    ProxyPass /ping                           http://fuseki:3030/$/ping
</VirtualHost> 

```

Assumes docker user-defined bridge network called `dnet` and fuseki iamge running with name `fuseki`.
