select search_term,count(*)  
as postings from raw.jobs.raw_job_postings
group by search_term
order by postings desc