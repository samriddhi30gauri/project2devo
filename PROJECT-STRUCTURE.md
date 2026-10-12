
PaySecure-DR-Project/
├── README.md (Step 1 complete)
├── docs/
│   ├── business-context.md
│   ├── architecture-decision-record.md
│   ├── architecture-overview.md (placeholder for Step 2+)
│   ├── compliance-mapping.md
│   ├── deliberate-errors-found.md
│   ├── BCRB-questions.md
│   └── cost-analysis.md
├── terraform/
│   ├── modules/ (vpc, kms, aurora-global, dynamodb-global, elasticache-global, msk, route53-failover, eks)
│   └── environments/prod/
├── k8s/base/
│   ├── payment-api-deployment.yaml
│   ├── networkpolicy.yaml (corrected)
│   └── transaction-processor.yaml
├── runbooks/ (12)
├── scripts/
│   ├── lambda/failover-orchestrator/main.py
│   └── health-check/health_check.sh
├── compliance/
│   ├── data-localisation-policy.md
│   └── drill-report-template.md
└── diagrams/
    └── architecture-high-level.mmd
