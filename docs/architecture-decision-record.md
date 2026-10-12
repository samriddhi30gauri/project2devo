# ADR-001 Active-Passive
Context: choose replication model where downtime = financial + regulatory penalty.
Options: Active-Active both serve, Active-Passive 100% Mumbai warm Hyderabad, Pilot light DB only.
Decision: Active-Passive warm standby.
Rationale: Payment financial correctness over availability, active-active needs distributed transactions fencing tokens, 8-person team cannot safely operate, RBI allows active-passive if RTO<5min we achieve 3min.
Consequences: Positive zero double-spend simpler ops lower cost, Negative underutilized mitigated by non-prod load tests, Risk DNS TTL 90s both active mitigated idempotency.

# ADR-002 Region Pair
Mumbai ap-south-1 primary lowest NPCI latency 3 AZs, Hyderabad ap-south-2 DR 700km 15-25ms RTT different seismic zone same partition RBI compliant.
Rejected ap-south-1 + ap-southeast-1 Singapore violates RBI 2018.
