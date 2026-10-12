# RB-10: Settlement Reconciliation
On failover, pause settlement-engine 2 min to avoid duplicate settlement.
Steps:
1. kubectl scale deployment settlement-engine --replicas=0 -n paysecure --context paysecure-mumbai (if reachable)
2. In DR, check last checkpoint: aws dynamodb get-item --table-name settlement_checkpoint --key '{"id":{"S":"daily"}}'
3. Replay from checkpoint: settlement-engine reads Kafka settlement.ready from last committed offset
4. Run reconciliation job: ./scripts/reconcile.sh --date $(date +%F) --compare-npci
5. Compare ledger: SELECT SUM(amount) FROM ledger WHERE date=today vs NPCI report, mismatch alert
6. Resume settlement: kubectl scale deployment settlement-engine --replicas=3 -n paysecure --context paysecure-hyderabad
