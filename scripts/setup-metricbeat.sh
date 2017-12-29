#!/bin/bash

set -euo pipefail

CLUSTERS='es01:9200 es02:9201'
for NODE in `echo ${CLUSTERS}`; do
  # Wait for Elasticsearch to start up before doing anything.
  until curl -k -s -s -uelastic:${ELASTIC_PASSWORD} "https://${NODE}" -o /dev/null; do
      sleep 1
      echo "waiting for ${NODE}"
  done

  # Set the default template to have no replicas.
  until curl -XPUT -s -uelastic:${ELASTIC_PASSWORD} -k "https://${NODE}/_template/top_level" -o /dev/null -H 'Content-Type: application/json' -d'
  {"index_patterns":["*"],"settings":{"number_of_shards":1,"number_of_replicas":0}}
  '; do
    sleep 1;
  done

  # Wait for kibana to start before using it to setup metricbeat dashboards.
  until curl -s "http://kibana:5601" -o /dev/null; do
    sleep 1;
  done

  metricbeat setup -E setup.kibana.host=kibana \
                   -E output.elasticsearch.hosts=${NODE} \
                   -E output.elasticsearch.protocol=https \
                   -E output.elasticsearch.username=elastic \
                   -E output.elasticsearch.password=${ELASTIC_PASSWORD} \
                   -E output.elasticsearch.ssl.certificate_authorities=/usr/share/elasticsearch/config/x-pack/certificates/ca/ca.crt


  # Set all the system indices to 0 replicas.
  until curl -XPUT -s -uelastic:${ELASTIC_PASSWORD} -k "https://${NODE}/_all/_settings" -o /dev/null -H 'Content-Type: application/json' -d'
  {
      "index" : {
          "number_of_replicas" : 0
      }
  }
  '; do
    sleep 1;
  done
done

# Setup the second cluster as cross cluster seed.
until curl -XPUT -s -uelastic:${ELASTIC_PASSWORD} -k "https://es01:9200/_cluster/settings" -o /dev/null -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "search": {
      "remote": {
        "cluster_east": {
          "seeds": [
            "es02:9300"
          ]
        }
      }
    }
  }
}
'; do
  sleep 1;
done
>&2 echo "Both clusters up"
