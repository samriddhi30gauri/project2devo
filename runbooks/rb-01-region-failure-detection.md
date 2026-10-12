# RB-01 Region Failure Detection
Steps: PagerDuty ack, run health_check.sh, check health.aws.amazon.com, declare disaster in #incident-paysecure, invoke failover Lambda aws lambda invoke --function-name paysecure-failover-orchestrator --region ap-south-2, Timebox 2 min declare 5 min invoke


---
### Reference Diagram: Figure 2 RPO/RTO Timeline
![Figure 2](../../demo/image_20261012_114941.png)
