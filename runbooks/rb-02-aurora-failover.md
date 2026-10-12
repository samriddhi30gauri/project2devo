# RB-02 Aurora Global Failover
aws rds describe-global-clusters --global-cluster-identifier paysecure-global
aws rds failover-global-cluster --global-cluster-identifier paysecure-global --target-db-cluster-identifier arn:aws:rds:ap-south-2:ACCOUNT:cluster:paysecure-secondary --region ap-south-1
Monitor Status, verify pg_is_in_recovery false, restart payment-api pods kubectl rollout restart deployment/payment-api -n paysecure
