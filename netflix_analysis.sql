select*
from netflix;

-- Number of Tv shows and Movies

select type, count(*) as total_type
from netflix
group by type;

--count the most frequent rating
select type,
rating 
from
   (
		select type , rating ,
		count(*) as rating_count , rank()over(partition by type order by count(*) desc ) as ranking
		from netflix
		group by 1,2
		order by 1, 3 desc
   ) where ranking = 1
   
-- list all movies released in a specific year
select type,release_year,title
from
	 (
	select type ,release_year,title, row_number()over(partition by release_year order by release_year ) as row_num
	from netflix 
	) 
where type = 'Movie' and release_year = 2020
order by release_year;

 
--find the top countries with the most content on netflix 

select unnest(string_to_array(country,',')) as new_country ,  count(show_id) as total_content
 from netflix
 where country is not null
 group by 1
 order by total_content desc
 limit 5;

 -- identify the longest movie or tv show 
 
select type,title, duration
from netflix
where type = 'Movie'  
and 
duration = (select max(duration) from netflix);

-- check content added in the last 5 years

select title,  date_added
from netflix
where to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years';

-- Movies directed by rajiv chilaka

select *
from netflix
where director ilike '%Rajiv Chilaka%';

-- Tv shows with more than 5 seasons 

select 
	type, duration 
	from netflix
	where type = 'TV Show'
	and split_part(duration,' ',1)::numeric > 5;


-- count the number of items in a genre 

select  unnest(string_to_array(listed_in,',')) as Genre,count(show_id)
	from netflix
	group by 1;
	
 -- calculate the average content released in each year

 select 
	 extract(year from to_date(date_added,'Month DD, YYYY')) as Date, 
	 count(*) as Yearly_content,
	 round(count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric * 100,2) as Avg_Content
	 from netflix
 group by 1
 order by 1;

 -- list all documentaries

 select type,title,listed_in from netflix
 where listed_in ilike '%documentaries%';

 -- content without a director 

 select * from netflix
 where director is null;

 -- movies with salman khan in the last 10 years 

 select type, release_year, "cast" 
 from netflix
 where "cast" ilike '%salman khan%'
 and release_year::int >= extract(year from current_date) - 10;

 -- 2019 > 2015

 -- top 10 actors with the highest number of movies in india

 select unnest(string_to_array("cast",',')) as Actors,count(*) 
 from netflix
 where country ilike '%india%' and type ='Movie'
 group by 1
 order by 2 desc
 limit 10;

 -- categorize content witk 'kill' and 'violence' keywords as bad_content else it is good _content 

with category_table as 
(
	select *,
		case 
			when description ilike '%kill%'
			or description ilike '%violence%' then 'bad_content'
			else 'good_content'
		end  category
from netflix 
)  select 
		category, 
		count(category) as total_content 
	from category_table
	group by 1;


 