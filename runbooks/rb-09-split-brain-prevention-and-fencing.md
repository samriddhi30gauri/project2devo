# RB-09: Split-Brain Prevention
Split-brain risk: network partition, both regions accept writes 60-90s.
Fencing:
- DynamoDB conditional writes prevent duplicate idempotency keys
- Aurora secondary is read-only until promoted (SG blocks writes)
- MSK producers use transactional.id with region prefix, fencing token from DynamoDB
- Route53 health check + double-check Lambda avoids flapping
Exposure quant: 1200 TPS *90s=108k txns, financial exposure 27 Cr if no fencing, 0 with fencing
Detection: CloudWatch metric BothRegionsActive alarm if Route53 primary and secondary both receive traffic (via ALB logs)
