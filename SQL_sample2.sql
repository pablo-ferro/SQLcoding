-- Question: With data about the state of a page changes, code in SQL: lookup for the current number of pages using latest_event. Note that the page_flag column in the table will be used to identify whether the page is "OFF" or "ON".

With 
latest event 
as
( 
SELECT page_id, max(event time) as latest event
FROM pages_info
GRO page_id
)

SELECT sum(case when page_flag=“ON” then 1 else 0 end) as result
FROM pages_info pi
Join latest_event le on pi.page_id=le.page_id and pi.event_time=le.latest_time