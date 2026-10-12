# PaySecure Gateway - Multi-Region Disaster Recovery Architecture
**Active-Passive | Mumbai ap-south-1 → Hyderabad ap-south-2 | RPO <60s RTO <5min | 99.99%**

## Overview
PaySecure processes 3.2M txn/day (500 Cr INR) for 45k merchants. Current: single region Mumbai 99.92% uptime (7h downtime/year). Mandate: RBI Master Direction, NPCI 99.95% uptime, PCI DSS v4.0. Target: 99.99% (52.6 min/year), RPO <1min RTO <5min.

## Architecture Decision
Active-Passive warm standby chosen over Active-Active to prevent double-spending with 8-person team. Mumbai primary, Hyderabad DR (700km, 15-25ms RTT, different seismic zone). Rejected Singapore (violates RBI data localisation 2018).

## Repo Structure
- docs/ - architecture, replication, compliance, BCRB Q&A, cost, deliberate-errors-found.md
- terraform/modules/ - vpc, kms (90d fix), aurora-global (physical replication), dynamodb-global, elasticache-global, msk, route53-failover (10s HC), eks
- k8s/base/ - deployment, hpa with prometheus-adapter, pdb, networkpolicy (corrected CDE segmentation)
- runbooks/ - 12 production runbooks RB-01 to RB-12
- scripts/lambda/failover-orchestrator/ - automated failover with double-check to avoid flapping
- compliance/ - data localisation policy + drill template
- diagrams/

## Key Fixes for Deliberate Errors (see docs/deliberate-errors-found.md)
1. Aurora Global uses physical storage replication not logical
2. DynamoDB idempotency requires conditional writes not LWW
3. ElastiCache Global promotion is manual not automatic
4. Route53 HC 10s not 30s for RTO<5min
5. KMS auto rotation 365d, need custom 90d Lambda for PCI DSS v4.0 Req 3.6.4
6. MSK replication.factor 3 not 1
7. HPA needs prometheus-adapter
8. RBI DR distance is 200km+ different zone not 500km mandatory
9. NetworkPolicy must not allow 0.0.0.0/0 to tokenisation-service
10. S3 replication must stay in India, not us-east-1 (RBI violation)
11. DNS TTL not part of per-txn 300ms UPI budget
12. RPO/RTO mandate is <1min/<5min not <15min/<1hr

## Quick Start
terraform init
terraform plan -var-file=environments/prod/terraform.tfvars
kubectl apply -f k8s/base/
./scripts/health-check/health_check.sh

## Compliance
RBI localisation, PCI DSS v4.0, NPCI UPI 300ms, IT Act 43A mapped in docs/compliance-mapping.md

## Author
ZeTheta Internship - DevOps & Cloud Engineer Track
