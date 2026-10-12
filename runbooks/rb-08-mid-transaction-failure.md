# RB-08 Mid-Transaction Failure
Client retry same idempotency_key header X-Idempotency-Key, DR returns existing status via DynamoDB conditional, settlement replays from transactional_outbox table SELECT * WHERE idempotency_key, psql check payments table


---
### Reference Diagram: Figure 2 RPO/RTO Timeline
![Figure 2](../../demo/image_20261012_114941.png)
