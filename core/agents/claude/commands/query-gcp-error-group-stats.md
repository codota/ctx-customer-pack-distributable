Query GCP Error Reporting API for error group statistics with time-windowed counts. Returns timedCounts arrays for spike detection. Requires a connected and enabled gcp_monitoring data source.

# Gcp Tools

> Auto-generated from 1 exported tool(s) in the Context Engine.

## query_gcp_error_group_stats

Query GCP Error Reporting API for error group statistics with time-windowed counts. Returns timedCounts arrays for spike detection. Requires a connected and enabled gcp_monitoring data source.

```bash
ctx-cli mcp call query_gcp_error_group_stats -p projectId=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| projectId | string | Yes | GCP project ID (e.g., "my-project-123"). |
| timeRangePeriod | string | No | Predefined time range: PERIOD_1_HOUR, PERIOD_6_HOURS, PERIOD_1_DAY, PERIOD_1_WEEK, PERIOD_30_DAYS. Default: PERIOD_1_HOUR. |
| timedCountDuration | string | No | Duration for timed count buckets (e.g., "900s" for 15 minutes). Default: 900s. |
| serviceFilter | string | No | Filter by service name (e.g., "my-service"). Optional. |
| pageSize | number | No | Maximum number of error groups to return. Default: 50. |