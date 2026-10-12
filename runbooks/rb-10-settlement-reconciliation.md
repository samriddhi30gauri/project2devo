# RB-10 Settlement Reconciliation
Pause settlement 2 min scale to 0 Mumbai if reachable, check last checkpoint dynamodb get-item settlement_checkpoint, replay from checkpoint Kafka settlement.ready, run reconcile.sh compare ledger vs NPCI report, resume scale 3 Hyderabad
