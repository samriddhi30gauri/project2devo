# TCO/ROI
Current single region $8500/mo, downtime risk 145 Cr/year (7h *20 Cr +5 Cr fine)
Multi-region: Mumbai $9200 + Hyderabad warm $4100 + Route53+transfer $3200 = $16500/mo = 1.6 Cr/year
ROI 90x vs risk, avoids license suspension
Active-active would be $18400+ plus idempotency infra, not justified 8-person team
Optimization: Karpenter scale DR settlement to 0, payment-api min 3, Savings Plan 30% saving.
