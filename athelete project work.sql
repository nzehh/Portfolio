select * from athlete_events
select * from noc_regions

--columns to work with
select name,sex,age,Team,Games,Year,Season,City,Event,Medal from athlete_events 

--how many olympic game have been held
select count(distinct Games) as total_olymoic_games  from athlete_events 

-- list of olympic games held go far 
select distinct year,season,city from athlete_events

-- total number of nations to participate in each olympic game (using joins)
select count(distinct noc.region) as total_numberofnations,ath.games
        from athlete_events ath
         join noc_regions noc on noc.noc=ath.NOC
           group by ath.Games

--identify the sport which was played in all summer olympics
--using CTE
with t1 as (
    select count(distinct games)as total_games 
	     from athlete_events
           where season = 'summer'),
t2 as (
    select distinct games, sport from athlete_events 
      where season = 'summer'),
t3 as (
    select sport,count(1) as no_of_games 
	  from t2
       group by sport)
select * from t3 join t1 on t1.total_games=t3.no_of_games

--which nation has participated in all olympic games
with tot_games as 
     (select count(distinct games)as total_games
       from athlete_events ath),
countries as
     (select games,noc.region as country 
	 from athlete_events ath
       join noc_regions noc on noc.noc = ath.noc
     group by games,noc.region),
countries_participated  as 
     (select country,count(1) as total_participated_games 
	     from countries
	      group by country)
select cp.*
    from countries_participated cp join tot_games tg 
     on tg.total_games = cp.total_participated_games
       order by 1

--sports played only once in the olympics

select sport,count(distinct games)as no_of_games,Games 
   from athlete_events
     group by Sport,Games
      having count(distinct games)=1
 
--fetch the total number of sports played in each olympic games.
with t1 as
    (select distinct Games,sport from athlete_events),
t2 as 
     (select games,count(1)as no_of_sports from t1
        group by Games) 
select * from t2 
    order by no_of_sports desc

--fetch details of the oldest athlete to win a gold medal
with temp as 
           (select name,sex,cast(case when age = 'na' then 0 else age end as int)
		   as age,team,games,city,sport,event,medal 
	from athlete_events),
ranking as 
        (select *,rank() over (order by age desc)as rnk
	from temp 
	      where medal='gold')
select * from ranking where rnk=1

--top 5 most successful countries in olympics. success is defined by the number of medals won
with t1 as 
        (select noc.region,count(1) as total_medal 
	from athlete_events ath join noc_regions noc on noc.noc=ath.noc
		where Medal <> 'NA' group by noc.region order by total_medals desc 
		),
t2 as 
     (select *, dense_rank() over (order by total_medals desc) as rnk from t1)
 select * from t2 where rnk <=5

