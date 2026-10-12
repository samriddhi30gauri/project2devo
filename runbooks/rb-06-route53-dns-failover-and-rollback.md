# RB-06: Route53 Failover
Primary failover is automatic via health check. Manual override:
aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file://failover-to-dr.json
Where failover-to-dr.json sets primary to secondary.
Check: dig api.paysecure.in +short should return Hyderabad ALB IP
TTL 60s: clients may cache 60-120s, warn merchants.
Rollback: After RCA and primary healthy 30min, flip back:
aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file://failback-to-primary.json
Use Route53 ARC for controlled failback: aws route53-recovery-control-config
