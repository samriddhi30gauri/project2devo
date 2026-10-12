# RB-01: Region Failure Detection and Declaration
**Severity: SEV1 | RTO clock starts**
Trigger: Route53 HC failed 3x10s + CloudWatch alarm Aurora/EKS down
Steps:
1. On-call acknowledges PagerDuty: `pd incident:acknowledge <id>`
2. Run health_check.sh (scripts/health-check/)
3. Double-check: `aws rds describe-global-clusters --region ap-south-1` fails, `aws eks describe-cluster --name paysecure-ap-south-1 --region ap-south-1` fails
4. Check https://health.aws.amazon.com for AWS regional outage
5. Declare disaster: post in #incident-paysecure, create doc in compliance/
6. Invoke failover Lambda: `aws lambda invoke --function-name paysecure-failover-orchestrator --region ap-south-2 out.json`
7. If Lambda fails, manual failover per RB-02,04,06
Timebox: 2 min to declare, 5 min to invoke.


---
### Reference Diagram: Figure 2 RPO/RTO Timeline
![Figure 2](../../demo/image_20261012_114941.png)
