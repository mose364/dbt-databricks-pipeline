select search_term,count(*) as postings
from dev.default_staging.stg_job_postings
group by search_term