# Business Context
Fictional RBI-regulated payment aggregator mid-tier 45k merchants e-commerce edtech gaming.
3.2M/day 500 Cr volume, peak 1200 TPS normal 2500 Diwali 4000 sale, mix 60% UPI 25% cards 10% wallets 5% NetBanking.
Current pain: single region ap-south-1 2 AZs no auto-failover Aurora single cluster daily snapshots Redis EC2 no replication Kafka single RTO 4-6h manual RPO 24h. 2024 outage 3h cost 60 Cr + RBI notice.
Stakeholders BCRB: CTO feasibility, CRO risk quantification, Compliance Head evidence, VP Eng 8-person operability, Big Four Auditor cost.
Success: automated failover <5min RPO <60s zero double-spend data stays India cost <2 Cr extra vs 145 Cr risk 12 runbooks L1 executable.
