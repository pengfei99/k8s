# Test kafka cluster 



```bash
# Get bash shell of a kafka pod
kubectl exec --stdin --tty pengfei-kafka-0 -- /bin/bash


# Go to the kafka bin dir
cd /opt/bitnami/kafka/bin


# create a topic
## note the replication factor must <= the number of the kafka pods
sh kafka-topics.sh --create --zookeeper pengfei-solr-zookeeper:2181 --replication-factor 3 --partitions 1 --topic test-topic

# checkt the status of the topic
sh kafka-topics.sh --describe --zookeeper pengfei-solr-zookeeper:2181 --topic test-topic

# port forward
kubectl port-forward --namespace user-pengfei svc/pengfei-solr-zookeeper-headless 2181:2181

sh kafka-topics.sh --describe --zookeeper localhost:2181 --topic test-topic
```