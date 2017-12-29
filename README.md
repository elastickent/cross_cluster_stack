# Summary

A demo system consisting of two one-node Elasticsearch clusters, Kibana and two Metricbeats. They are built using docker-compose and configured for cross-cluster search and multi-cluster monitoring.

## Install certificates

After cloning the repo, cd into the directory and run:

`docker-compose -f create-certs.yml up`

## Start up both clusters.

Now run:

`docker-compose up`

The Metricbeat dashboard loading process should take couple of minutes complete. 

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
