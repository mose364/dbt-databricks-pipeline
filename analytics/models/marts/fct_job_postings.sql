{{config(materialized='incremental',incremental_strategy='merge',
unique_key='job_id')}}

WITH job_postings AS (
    SELECT * FROM {{ ref('stg_job_postings') }}
)

SELECT
    job_id,
    job_title,
    search_term,
    company_name,
    job_location,
    job_source,
    job_schedule_type,
    is_remote,
    search_date,
    salary_min,
    salary_max,
    salary_avg,
    salary_period,
    salary_currency,
    has_health_insurance,
    has_dental_insurance,
    has_paid_time_off,
    has_no_degree_mentioned
FROM job_postings
 {% if is_incremental() %}
        WHERE search_date > (
    SELECT MAX(search_date)
    FROM {{ this }}
)
    {% endif %}
qualify row_number()over(partition by job_id order by search_date desc) =1
