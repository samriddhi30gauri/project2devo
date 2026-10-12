
# PaySecure Gateway - Multi-Region DR Architecture - STEP 1 DELIVERABLE
## ZeTheta DevOps & Cloud Engineer Project | Day 1-2 Foundation

---

# PaySecure Gateway - Multi-Region DR Architecture
**Project: ZeTheta DevOps & Cloud Engineer | PaySecure Payment Systems**
**Timeline: 15 Days | Step 1: Foundation (Day 1-2)**

## Business Context
PaySecure Gateway Pvt Ltd - fictional mid-tier payment aggregator
- 3.2M daily transactions, 500 Cr INR volume, 45,000 merchants
- Current: Single region ap-south-1 Mumbai, 99.92% uptime = 7 hours downtime/year
- Target: 99.99% uptime (52.6 min/year), RPO <1 min, RTO <5 min by Q3 2026
- Cost of downtime: 20 Cr INR/hour + 5 Cr regulatory fine + license suspension risk

## Why Multi-Region DR is Mandatory Now
1. RBI Master Direction 2024 mandates DR site in different seismic zone
2. NPCI UPI requires 99.95% uptime for payment aggregators
3. PCI DSS v4.0 requires documented incident response + quarterly tests
4. Digital payments: 13B+ UPI txn/month, cannot afford single-region SPOF

## Architecture Decision: Active-Passive vs Active-Active

| Criteria | Active-Passive (Chosen) | Active-Active |
|----------|------------------------|---------------|
| Double-spending risk | Zero - only 1 writer | High - needs global lock |
| Team size 8-person | Operable | Not operable |
| Cost | Warm standby 44% extra | 100% extra + complexity |
| RBI compliance | Yes if RTO<5min | Yes |
| Settlement complexity | Simple | Requires reconciliation ledger |

**Decision: Active-Passive**
Primary: ap-south-1 Mumbai (lowest latency to NPCI, 3 AZs)
DR: ap-south-2 Hyderabad (700km separation, same country, 15-25ms RTT)
Rejected: Mumbai + Singapore (ap-northeast-1) - violates RBI data localisation 2018 circular

## High-Level Architecture

```
[Merchants / PSP Apps / UPI]
         |
   Route53 (api.paysecure.in)
   HC: 10s interval, 3 failures, TTL 60s
   /                           ALB+WAF Mumbai            ALB+WAF Hyderabad (warm)
  |                           |
EKS Cluster (6 nodes min)  EKS Cluster (6 nodes warm)
  | payment-api 6 repl     | payment-api 3 repl (scaled to 12 on failover)
  | txn-processor 8        | txn-processor 3
  | settlement 3           | settlement 0 (scaled later)
  | tokenisation 4 (CDE)   | tokenisation 4
  |
[Aurora PostgreSQL Global] --storage replication <1s--> [Secondary Hyderabad]
[DynamoDB Global Tables] --multi-master <1s--> (idempotency keys)
[ElastiCache Global Datastore] --async <5s--> [Secondary]
[MSK Mumbai] --MirrorMaker2--> [MSK Hyderabad]
[KMS Mumbai CMK] + [KMS Hyderabad CMK] + Secrets Manager replication
[CloudTrail Org Trail] --> S3 Mumbai + replication to Hyderabad + Object Lock 7 years
```

## RTO/RPO Breakdown (Target)

| Component | RPO | RTO | Mechanism |
|-----------|-----|-----|-----------|
| Aurora Global | <1 sec | <60 sec | Storage replication + failover-global-cluster |
| DynamoDB | <1 sec | 0 sec | Global Tables active-active |
| ElastiCache | <5 sec (cache only) | <30 sec | Global Datastore manual promotion |
| MSK | 2-5 sec | <60 sec | MM2 offset sync |
| DNS | N/A | 60-90 sec | Route53 10s HC + 60s TTL |
| EKS warm | N/A | 60 sec | 6 nodes always on, Karpenter to 12 |
| **E2E** | **<60 sec** | **<3 min** | Meets <1min/<5min mandate |

## Compliance Framing (Day 1)

**RBI Master Direction on Storage of Payment Data 2018:**
- All payment data must be stored in India only. Design: ap-south-1 + ap-south-2 only. S3 bucket policy denies non-IN regions. Terraform will enforce.

**RBI BCP Guidelines:**
- DR site different seismic zone, min 200km (not 500km as misquoted in doc). Mumbai-Hyderabad = 700km, zone III vs II, compliant.

**PCI DSS v4.0:**
- Req 3.5.1: KMS rotation - AWS auto is 365 days, need custom 90d via Lambda (deliberate error in doc says 365d is ok)
- Req 9.4.5: CDE segmentation - tokenisation-service isolated via NetworkPolicy (doc error allows 0.0.0.0/0)
- Req 10.4: Audit logs immutable

**NPCI UPI v1.6:**
- 300ms end-to-end ceiling. Our design: API 40ms + Aurora 5ms + NPCI 150ms = 195ms steady state. DNS not per-txn (doc error says it is).

## Deliverables for Step 1
- [x] This README
- [x] docs/business-context.md
- [x] docs/architecture-decision-record.md
- [x] compliance/data-localisation-policy.md
- [x] diagrams/architecture-high-level.mmd
- [x] Project structure created

Next: Step 2 - Terraform VPC + KMS + Aurora Global (with corrected errors)


---


# Business Context - PaySecure Gateway

## Company Profile
Fictional RBI-regulated payment aggregator, mid-tier. 45k merchants, categories: e-commerce, edtech, gaming.

## Transaction Profile
- Average: 3.2M/day, 500 Cr INR
- Peak: 1200 TPS normal, 2500 TPS Diwali, 4000 TPS sale events
- Mix: 60% UPI, 25% cards, 10% wallets, 5% NetBanking

## Current Architecture Pain
- Single region ap-south-1 Mumbai, 2 AZs only (not 3), no auto-failover
- Aurora PostgreSQL single cluster, daily snapshots only, no Global DB
- Redis self-hosted on EC2, no replication
- Kafka single cluster, no MM2
- RTO manual 4-6 hours, RPO 24 hours (snapshot)
- 2024 outage: 3 hours, cost 60 Cr + RBI notice

## Stakeholders for BCRB (Business Continuity Review Board)
1. CTO - technical feasibility
2. CRO - risk quantification, financial exposure
3. Compliance Head - RBI/PCI evidence
4. VP Engineering - 8-person team operability
5. External Big Four Auditor - cost benchmarking

## Success Criteria
- Automated failover <5 min
- RPO <60 sec
- Zero double-spending
- Data stays in India
- Cost <2 Cr/year extra (vs 145 Cr risk)
- 12 runbooks executable by L1 on-call


---


# ADR-001: Active-Passive DR

## Context
Need to choose replication model for payment gateway where downtime = financial + regulatory penalty.

## Options Considered
1. Active-Active: Both regions serve traffic, DNS weighted or latency-based
2. Active-Passive: Mumbai serves 100%, Hyderabad warm standby, failover on detection
3. Active-Passive with pilot light: Even smaller DR (DB only, no EKS)

## Decision
Active-Passive warm standby (Option 2)

## Rationale
- Payment = financial correctness over availability. Active-active requires distributed transactions, fencing tokens, conflict resolution for settlement. Team of 8 cannot safely operate.
- RBI allows active-passive if RTO <5 min - we achieve 3 min.
- Pilot light would need 10+ min to scale EKS from 0, fails RTO.

## Consequences
- Positive: Zero double-spend, simpler ops, lower cost than active-active
- Negative: Hyderabad resources underutilized (mitigated by using for non-prod load tests, cost 44% extra)
- Risk: DNS TTL caching may cause 90 sec both regions active (mitigated by idempotency conditional writes)

## ADR-002: Region Pair
- Mumbai ap-south-1 primary: lowest latency to NPCI Mumbai DC, 3 AZs
- Hyderabad ap-south-2 DR: 700km, 15-25ms RTT, different seismic zone, same AWS partition, RBI compliant
- Rejected ap-south-1 + ap-southeast-1 Singapore: violates RBI 2018 circular


---


# Data Localisation Policy - RBI 2018 Circular

Policy Statement: All payment system data (full end-to-end transaction details, customer data, merchant data) shall be stored in India only.

Implementation:
1. AWS Regions Allowed: ap-south-1, ap-south-2 only. Deny all other regions via SCP.
2. S3 Bucket Policy:
{
  "Version":"2012-10-17",
  "Statement":[{
    "Effect":"Deny",
    "Action":"s3:*",
    "Resource":"*",
    "Condition":{"StringNotEquals":{"aws:RequestedRegion":["ap-south-1","ap-south-2"]}}
  }]
}
3. KMS keys in India only
4. No cross-border replication - doc error showing replication to us-east-1 is violation
5. Audit: Monthly script checks for any resource in non-IN region

Evidence: CloudTrail + Config rule approved-regions


---


graph TB
  Client[Merchants / UPI Apps] --> R53[Route53 api.paysecure.in HC 10s TTL 60s]
  R53 --> ALB1[ALB+WAF Mumbai ap-south-1]
  R53 --> ALB2[ALB+WAF Hyderabad ap-south-2 Warm]
  ALB1 --> EKS1[EKS Mumbai 6 nodes min m5.xlarge]
  ALB2 --> EKS2[EKS Hyderabad 6 nodes warm]
  EKS1 --> APIPayment[payment-api 6 repl]
  EKS2 --> APIPaymentDR[payment-api 3 repl -> 12 on failover]
  APIPayment --> AuroraP[Aurora Primary Writer]
  APIPaymentDR --> AuroraS[Aurora Secondary Reader]
  AuroraP -.->|Physical storage replication <1s| AuroraS
  APIPayment --> Dynamo[DynamoDB Global Tables txn_idempotency]
  APIPaymentDR --> Dynamo
  APIPayment --> CacheP[ElastiCache Primary]
  CacheP -.->|Global Datastore <5s| CacheS[ElastiCache Secondary]
  APIPayment --> MSK1[MSK Mumbai]
  MSK1 -.->|MM2 replication.factor 3| MSK2[MSK Hyderabad]
  EKS1 --> KMS1[KMS Mumbai CMK 90d rotation]
  EKS2 --> KMS2[KMS Hyderabad CMK]
  EKS1 & EKS2 --> Trail[CloudTrail Org Trail S3 Object Lock 7y]
