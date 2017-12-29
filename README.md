# cross_cluster_stack
A demo two cluster Elasticsearch, Kibana and Metricbeat docker-compose with cross-cluster search.

## Install
After cloning the repo, cd into the directory and run:

`docker-compose -f create-certs.yml up`

## Start both clusters.

`docker-compose up`

The provisioning and Metricbeat dashboard loading should take couple of minutes.

## Check out your new clusters.

Point a browser at http://localhost:5601 to see the results.

Username: elastic

Password: changeme

## Search across both clusters.

Navigate to the dev console and try out a cross cluster search.

```
GET cluster_east:*,*/_search?size=0 
{
  "aggs": {
    "total_disk": {
      "sum": {
        "field": "system.filesystem.available"
      }
    }
  }
}
```
