SELECT
    operation,
    operationMetrics['numOutputRows'] AS numOutputRows,
    operationMetrics['numSourceRows'] AS numSourceRows,
    operationMetrics['numTargetRowsUpdated'] AS numTargetRowsUpdated,
    operationMetrics['numTargetRowsInserted'] AS numTargetRowsInserted
FROM (DESCRIBE HISTORY dev.default.fct_job_postings)
WHERE operation IN (
    'CREATE OR REPLACE TABLE AS SELECT',
    'MERGE'
)
ORDER BY version DESC;


