# RB-07: EKS Scaling
DR EKS is warm at 6 nodes. On failover scale to 12:
kubectl --context paysecure-hyderabad scale deployment payment-api --replicas=12 -n paysecure
Or Karpenter will auto-scale on pending pods.
If Mumbai EKS partially available, cordon: kubectl --context paysecure-mumbai cordon <node>, drain.
Verify: kubectl --context paysecure-hyderabad get pods -n paysecure -w
HPA will further scale to 40 on TPS spike.
