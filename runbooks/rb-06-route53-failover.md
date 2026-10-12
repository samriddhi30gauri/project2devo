# RB-06 Route53 Failover
Automatic via health check 10s. Manual: aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file://failover-to-dr.json, dig api.paysecure.in should return Hyderabad ALB, TTL 60s warning, rollback via ARC
