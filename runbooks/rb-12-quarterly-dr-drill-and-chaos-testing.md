# RB-12: Quarterly DR Drill
Required by RBI Para 15.
Plan:
1. Announce drill in #engineering 1 week prior, freeze deploys
2. Use AWS FIS:
   - aws fis create-experiment-template --cli-input-json file://fis-az-failure.json (kill 1 AZ in Mumbai)
   - aws fis create-experiment-template --cli-input-json file://fis-region-failure.json (blackhole Route53 HC)
3. Execute: measure RTO via script: time until curl https://api.paysecure.in/healthz returns 200 from DR
4. Measure RPO: insert marker row in Aurora primary, failover, check if marker exists in secondary
5. Expected: RTO <3min, RPO <60s
6. Document: fill compliance/drill-report-template.md with timeline, metrics, gaps
7. Evidence: CloudTrail logs, Grafana screenshots, PagerDuty timeline
8. Retro: update runbooks
Frequency: monthly automated, quarterly business review with BCRB stakeholders.
