# RB-03 DynamoDB Conflict Resolution
DynamoDB active-active LWW but we use conditional writes attribute_not_exists. Check Streams Lambda logs, query both regions get-item, export conflicts scan filter conflict_flag, no manual promotion needed
