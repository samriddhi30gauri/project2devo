# RB-08: Mid-Transaction Failure
Scenario: User debited but response lost due to region failure.
Recovery:
1. Client SDK must retry with same idempotency_key (header X-Idempotency-Key)
2. DR payment-api: DynamoDB conditional write fails if key exists, returns existing transaction status (200 with txn id)
3. If Aurora txn not committed in primary but idempotency key exists, settlement-engine replays from Kafka outbox table: SELECT * FROM transactional_outbox WHERE idempotency_key='<key>'
4. Manual check: psql -c "SELECT * FROM payments WHERE idempotency_key='<key>'"
No double debit due to conditional write.


---
### Reference Diagram: Figure 2 RPO/RTO Timeline
![Figure 2](../../demo/image_20261012_114941.png)
