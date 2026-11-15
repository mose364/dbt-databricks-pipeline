

{% set extension_keywords = [
    "No degree mentioned",
    "Paid time off",
    "Dental insurance",
    "Health insurance"
] %}

WITH source AS (
    SELECT *
    FROM {{ source('jobs', 'raw_job_postings') }}
    WHERE error IS NOT TRUE and job_id IS NOT NULL
),

cleaned AS (
    SELECT
        job_id,
        job_title,
        TRIM(company_name) AS company_name,
        job_location,
        TRIM(REGEXP_REPLACE(job_via, '(?i)^via\\s+', '')) AS job_source,
        job_posted_at AS searched_at,
        job_schedule_type,
        job_work_from_home AS is_remote,
        search_time,
        search_date,
        search_term,
        search_location,
        job_salary,
        -- 3.06 - the salary columns, before the macro
--
-- Paste this INSIDE the cleaned CTE of models/staging/stg_job_postings.sql,
-- directly under the `job_salary,` line.
--
-- Yes, salary_min and salary_max are the same twelve lines twice, with one
-- thing changed. That is not a mistake, it is the whole point of the lesson.
-- ===========================================================================

        -- lower bound: the number before the en-dash, times its K or M suffix
         {{parse_salary('min')}} AS salary_min,
        -- upper bound: the same parse on the LAST segment, so a single value is its own range
        {{parse_salary('max')}} AS salary_max,({{parse_salary('min')}}+  {{parse_salary('max')}})/2 as salary_avg,
        -- pay period, read off the end of the text: 'a year', 'an hour'
        NULLIF(REGEXP_EXTRACT(job_salary, 'an? (year|hour|month|day|week)$', 1), '') AS salary_period,
        -- currency marker; a salaried row with no marker is stamped USD on purpose
        CASE
            WHEN job_salary IS NOT NULL
            THEN COALESCE(NULLIF(TRIM(REGEXP_EXTRACT(job_salary, '^([^0-9]+)', 1)), ''), 'USD')
        END AS salary_currency,

        {% for keyword in extension_keywords %}
        ARRAY_CONTAINS(
            FROM_JSON(job_extensions_raw, 'array<string>'),
            '{{ keyword }}'
        ) AS has_{{ slugify(keyword) }}
        {% if not loop.last %},{% endif %}
        {% endfor %}

    FROM source
)

SELECT *
FROM cleaned

