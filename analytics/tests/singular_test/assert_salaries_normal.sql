{{config(severity='warn')}} 

select job_id,
search_term,
job_title,
salary_min,
salary_max,
salary_period,
salary_currency
 from dev.default_staging.stg_job_postings
 where salary_period='year'
 and salary_currency='USD'
 and coalesce(salary_max,salary_min) >=1000000
