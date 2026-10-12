#!/bin/bash
# settlement reconciliation vs NPCI
DATE=${1:-$(date +%F)}
echo "Reconciling $DATE"
psql $AURORA_DR -c "SELECT count(*), sum(amount) FROM ledger WHERE date='$DATE'"
aws s3 cp s3://npci-reports/$DATE.csv /tmp/npci.csv
python3 scripts/compare_ledger.py /tmp/npci.csv
