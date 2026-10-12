# RB-05: MSK MM2 Lag
Alarm: MirrorMaker2ReplicationLatency >10s
Steps:
1. Check MM2 replicator status: aws kafkaconnect describe-replicator --replicator-arn <arn>
2. Check broker health: aws kafka describe-cluster --cluster-arn <arn>
3. If broker down: MSK auto-replaces, wait
4. If MM2 lag due to producer spike: scale replicator tasks via `aws kafkaconnect update-replicator`
5. If region failure: consumers in DR switch to DR cluster via env KAFKA_BROKERS=paysecure-hyderabad:9092, they will start from translated offsets
6. Reconciliation: run scripts/kafka_replay.py to replay last 5 min from Mumbai binlog after recovery
Config: replication.factor=3 min.insync.replicas=2 enable.idempotence=true
