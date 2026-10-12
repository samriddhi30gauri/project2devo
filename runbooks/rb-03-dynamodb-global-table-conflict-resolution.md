# RB-03: DynamoDB Conflict Resolution
DynamoDB Global Tables is active-active, LWW but we use conditional writes.
Check conflicts: Look at DynamoDB Streams Lambda logs in CloudWatch /aws/lambda/paysecure-idempotency-audit
If duplicate txn_id detected:
1. Query both regions: aws dynamodb get-item --table-name txn_idempotency --key '{"idempotency_key":{"S":"<key>"}}' --region ap-south-1 and ap-south-2
2. If both have same key with different timestamps, last writer wins but financial logic already prevented double via condition. Keep earliest record.
3. For audit, export to S3: aws dynamodb scan --table-name txn_idempotency --filter-expression "attribute_exists(conflict_flag)"
4. No manual promotion needed — always active.
