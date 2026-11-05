with source as (
select * from {{source('jobs', 'raw_job_postings')}}
where error is not True), cleaned as (
 SELECT
    job_id,
    job_title,
    trim(company_name) AS company_name,
    job_location,
    REGEXP_REPLACE(job_via,'^via','') AS job_source,
    job_posted_at as searched_at,
    job_salary,
    job_schedule_type,
    job_work_from_home AS is_remote,
    job_extensions_raw AS job_extensions,
    search_time,
    search_date,
    search_term,
    search_location
    from source)
    select * from cleaned
   


