# Deliberate Errors Found - Cross-Referenced with Official Docs

## 1. RPO/RTO mismatch Page1 vs Page4
Error: Page1 says RPO <1min RTO <5min, Page4 says RPO <15min RTO <1hr
Correct: Task mandate is <1min/<5min strict SLO for PaySecure, 15min/1hr is RBI baseline minimum not target
Source: Task description page1, RBI Master Direction baseline 4hrs but NPCI requires 5min
Impact: Designing to looser fails BCRB
Location: Page 1 and Page 4

## 2. Aurora Global replication type Page15
Error: Says logical replication
Correct: Aurora Global uses physical storage-based replication
Source: AWS Docs https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database.html "storage-based replication"
Impact: RPO miscalculation

## 3. DynamoDB Global Tables LWW for idempotency Page18
Error: Suggests relying on last-writer-wins for idempotency
Correct: Must use conditional writes attribute_not_exists for financial transactions, LWW can cause double-spending
Source: AWS DynamoDB Best Practices for idempotency, PCI DSS
Impact: Financial correctness violation

## 4. ElastiCache Global Datastore auto-failover Page19
Error: Says automatic promotion
Correct: Promotion is manual API call, no auto-failover
Source: https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/GlobalDatastore.html
Impact: Runbook missing manual step

## 5. Route53 Health Check interval minimum 30s Appendix A
Error: Sample shows interval 30s fixed
Correct: Route53 supports 10s fast and 30s standard, must use 10s for RTO<5min
Source: AWS Route53 docs health check request_interval
Impact: RTO 90s vs 30s miscalc

## 6. KMS rotation 365 days meets PCI Page27
Error: Claims 365d meets PCI DSS
Correct: PCI DSS v4.0 Req 3.6.4 needs 90d rotation, AWS KMS auto rotation is 365d, need custom Lambda/CloudHSM
Source: PCI DSS v4.0, AWS KMS docs automatic rotation is 1 year
Impact: Compliance failure

## 7. MSK MM2 replication.factor=1 Appendix A
Error: Terraform shows replication.factor=1
Correct: Production must be 3 for durability, min.insync.replicas=2
Source: MSK best practices
Impact: Data loss

## 8. HPA custom metric syntax without adapter Page35
Error: Uses http_requests_per_second directly without prometheus-adapter
Correct: Need prometheus-adapter and ExternalMetrics API, metric must be defined in adapter config
Source: Kubernetes HPA v2 docs, prometheus-adapter docs
Impact: HPA won't scale

## 9. RBI DR distance 500km mandatory Page12
Error: States 500km mandatory
Correct: RBI recommends different seismic zone / 200km+ separation, not strict 500km
Source: RBI IT Outsourcing and BCP guidelines
Impact: Over-engineering, rejects valid pairs

## 10. NetworkPolicy allows 0.0.0.0/0 to tokenisation-service Appendix B
Error: Ingress from 0.0.0.0/0
Correct: Only payment-api ServiceAccount allowed to tokenisation:8443, deny all else per PCI Req 9.4.5
Source: PCI DSS segmentation, K8s NetworkPolicy best practices
Impact: Audit failure

## 11. S3 Cross-Region Replication to us-east-1 Page22
Error: Example bucket replication to us-east-1
Correct: RBI localisation forbids export outside India, must stay ap-south-1/2
Source: RBI circular Storage of Payment System Data 2018
Impact: License violation

## 12. UPI 300ms ceiling includes DNS lookup Page30
Error: Adds DNS latency to per-transaction budget
Correct: DNS resolved once per connection keep-alive, not per txn, UPI budget is API + bank + NPCI
Source: NPCI UPI Tech Specs v1.6
Impact: Incorrect rejection of Route53 failover

Verification method: Each error verified via AWS official docs, PCI DSS v4.0 PDF, RBI circulars rbi.org.in, NPCI specs.
