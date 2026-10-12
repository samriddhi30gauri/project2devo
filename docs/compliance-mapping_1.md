# Compliance Mapping RBI / PCI DSS v4.0 / NPCI / IT Act

## RBI Master Direction Storage of Payment Data 2018 + BCP 2020/2024
- Data localisation: ap-south-1 + ap-south-2 only, S3 SCP deny non-IN, KMS India only, no us-east-1 replication (doc error fixed)
- DR separation: 700km Mumbai-Hyderabad different seismic zone III vs II, RBI recommends 200km+ not 500km mandatory (doc error fixed)
- Quarterly drills: RB-12 + CloudTrail evidence
- RTO/RPO: RPO 60s RTO 5min tested monthly FIS

## PCI DSS v4.0
- 3.5.1 KMS rotation 90 days: AWS auto 365d insufficient, custom Lambda rotation (doc error says 365d ok)
- 4.2.1 TLS 1.3 transit, AES-256 at rest
- 9.4.5 CDE segmentation: NetworkPolicy only payment-api -> tokenisation:8443, not 0.0.0.0/0 (doc error fixed)
- 10.4 Audit logging immutable CloudTrail + Object Lock 7y
- 11.5 WAF GuardDuty SecurityHub
- 12.10 Incident response runbooks PagerDuty

## NPCI UPI v1.6
- 300ms ceiling: API 40ms + DB 5ms + NPCI 150ms =195ms steady state, DNS resolved once per connection keep-alive not per txn (doc error fixed that added DNS to budget)
- 99.95% uptime: design 99.99% exceeds
- Idempotency DynamoDB conditional

## IT Act 43A SPDI Rules
- Reasonable security AES-256 IRSA ISO27001
