# Validation details

## What was checked

- All five analytical queries executed against synthetic records in a local SQLite engine with explicit equivalents for SAFE_DIVIDE, SAFE_MULTIPLY, IF, REGEXP_REPLACE, and ANY_VALUE.
- Date variables and typed date literals were translated for that local check. Published files remain GoogleSQL.
- Expected business counts were asserted: three first-period Atlas first-touch viewers; three Episode 1 viewers; two Episode 1 viewers continuing to another episode; one Episode 2 viewer continuing; two viewers shared between Episodes 1 and 2; and one three-plus-episode viewer among Episode 1 viewers.
- The analytical bodies were compared before and after packaging: no changes.
- Every runnable file creates its viewing sample table before analysis and places declarations first.
- Document links, new numbering, internal-identifier scans, and removal of the requested section were checked.

## Execution status

BigQuery execution was not available during this review. Local execution verifies the sample calculations but does not certify BigQuery parsing or engine behavior. ANY_VALUE selections are arbitrary by definition and can differ across engines or runs; a particular first-day assignment was not asserted.

The output JSON contains local synthetic demonstration results, not employer results or BigQuery output.

## Viewing-data-only update

Removed unused paid-spend and country-spend fixtures from all ten runnable files. Re-executed all five analyses locally and compared every result row with the previous synthetic results: unchanged. BigQuery execution remains unverified.
