

{% set extension_keywords = [
    "No degree mentioned",
    "Paid time off",
    "Dental insurance",
    "Health insurance"
] %}

WITH source AS (
    SELECT *
    FROM {{ source('jobs', 'raw_job_postings') }}
    WHERE error IS NOT TRUE
),

cleaned AS (
    SELECT
        job_id,
        job_title,
        TRIM(company_name) AS company_name,
        job_location,
        REGEXP_REPLACE(job_via, '^via', '') AS job_source,
        job_posted_at AS searched_at,
        job_salary,
        job_schedule_type,
        job_work_from_home AS is_remote,
        job_extensions_raw AS job_extensions,

        {% for keyword in extension_keywords %}
        ARRAY_CONTAINS(
            FROM_JSON(job_extensions_raw, 'array<string>'),
            '{{ keyword }}'
        ) AS has_{{ keyword | lower | replace(' ', '_') }}
        {% if not loop.last %},{% endif %}
        {% endfor %},

        search_time,
        search_date,
        search_term,
        search_location

    FROM source
)

SELECT *
FROM cleaned
