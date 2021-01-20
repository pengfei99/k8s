# Add security in solr
After installing solr, you will notice, it comes with 0 security. So you need to enable the security by yourself. Because without it, you can't use rest api 
to add configsets


1. To enable solr authentication and authorization plugin. 
https://lucene.apache.org/solr/guide/6_6/authentication-and-authorization-plugins.html

2. To use basic auth plugin.
https://lucene.apache.org/solr/guide/6_6/basic-authentication-plugin.html#basic-authentication-plugin

3. To understand the acl of security.json
https://lucidworks.com/post/securing-solr-tips-tricks-and-other-things-you-really-need-to-know/ 


## Add a configset to solr
kubectl port-forward --namespace user-pengfei svc/pengfei-solr-headless 8983:8983

``` bash
# upload atlas solr configset
zip config.zip /apache-atlas-2.1.0-SNAPSHOT/conf/solr/*

curl -X POST -u solr:pwd --header 'Content-Type:text/xml' -d @config.zip 'http://solr.kub.sspcloud.fr/solr/admin/configs?action=CREATE&name=vertex_index'
curl -X POST -u solr:pwd --header 'Content-Type:text/xml' -d @config.zip 'http://solr.kub.sspcloud.fr/solr/admin/configs?action=CREATE&name=edge_index'
curl -X POST -u solr:pwd --header 'Content-Type:text/xml' -d @config.zip 'http://solr.kub.sspcloud.fr/solr/admin/configs?action=CREATE&name=fulltext_index'

# list existing configset
curl -X GET -u solr:kpZHPwJWokqawv39ycHM --header 'Content-Type:text/xml' 'http://solr.kub.sspcloud.fr/api/cluster/configs?omitHeader=true'
```