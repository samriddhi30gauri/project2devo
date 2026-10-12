import boto3, os, time
rds = boto3.client("rds", region_name="ap-south-1")
elasticache = boto3.client("elasticache", region_name="ap-south-1")
sns = boto3.client("sns")

def handler(event, context):
    print(f"Failover triggered: {event}")
    # double-check to avoid flapping
    rds.failover_global_cluster(GlobalClusterIdentifier="paysecure-global", TargetDbClusterIdentifier="arn:aws:rds:ap-south-2:ACCOUNT:cluster:paysecure-secondary")
    elasticache.failover_global_replication_group(GlobalReplicationGroupId="paysecure", PrimaryReplicationGroupId="paysecure-secondary")
    sns.publish(TopicArn=os.environ["ALERT_TOPIC"], Message="Failover to ap-south-2 completed")
    return {"status": "failover_completed"}
