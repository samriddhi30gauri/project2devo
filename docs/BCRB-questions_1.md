# BCRB 10 Challenge Questions

Q1 CTO: What happens to transaction mid-flight when Mumbai dies at T+150ms?
A: Client retries same idempotency key, DynamoDB Global already has key (written T+20ms), DR returns existing status, no double debit. Aurora txn may not commit - settlement replays from Kafka outbox.

Q2 CRO: Quantify split-brain financial exposure?
A: Worst 90s both regions active (DNS TTL 60s + HC 30s) 1200 TPS *90s=108k txns *2500 INR=27 Cr exposure if no fencing, 0 with DynamoDB conditional writes.

Q3 Compliance Head: Cardholder data residency during failover?
A: PAN tokenised via CloudHSM India, Aurora only token, KMS Hyderabad, no cross-border.

Q4 VP Eng: Can 8-person team operate?
A: Yes active-passive + IaC + managed services + runbooks, on-call 1 primary.

Q5 Auditor: DNS TTL impact real RTO?
A: P95 90s Route53 +60s TTL +30s ALB dereg=180s still <5min. Use ARC for faster.

Q6 CTO: Kafka partition loss?
A: MM2 acks=all min.insync=2 0 loss single broker, region loss 2-5s reconciled via Lambda replay.

Q7 CRO: Settlement discrepancy?
A: Idempotent ledger + pause 2min + checkpoint DynamoDB + daily NPCI reconciliation.

Q8 Compliance: Audit trail continuity?
A: CloudTrail org trail S3 Mumbai + replication Hyderabad Object Lock 7y.

Q9 VP Eng: Cost sustainability?
A: $16.5k/mo vs $8.5k single, 90x ROI vs 145 Cr risk, warm standby.

Q10 Auditor: Chaos testing?
A: Monthly FIS kill AZ/region/Aurora/MSK, recorded RB-12.
