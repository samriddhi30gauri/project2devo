# RB-11: Cardholder Data Residency
RBI requires all payment data in India. After failover verify:
1. S3 bucket replication: aws s3api get-bucket-replication --bucket paysecure-audit-logs should show only ap-south-2 destination, not us-east-1
2. KMS keys: aws kms describe-key --key-id alias/paysecure-ap-south-2 --region ap-south-2 should show India region
3. CloudTrail: no PutObject to non-IN region
4. Tokenisation-service logs: no PAN, only tokens
5. Audit: run compliance/check_data_localisation.py
If violation found, immediately delete non-IN copy and report to Compliance Head.
