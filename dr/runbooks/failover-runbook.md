# 🚨 DR Failover Runbook

## Step 1: Incident Declaration
- Incident Commander (IC) assigned
- Severity confirmed

## Step 2: Approval
- IC approves DR failover

## Step 3: Trigger Pipeline
- Run: dr-failover-pipeline

## Step 4: Switch Traffic
- Update Azure Front Door / Traffic Manager

## Step 5: Validate System
- Run health check scripts
- Verify:
  - API responses
  - DB connectivity
  - Cache availability

## Step 6: Notify Stakeholders
- Slack + Email

## Step 7: Monitor System
- Check logs & metrics

---

## Rollback Plan
If DR fails:
- Re-route traffic to primary (if partially available)
- Escalate to engineering team