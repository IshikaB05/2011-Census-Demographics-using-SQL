select * from Census.dbo.Data1;

select * from Census.dbo.Data2;

--Number of rows in datasets:

select count(*) from Census..Data1;

select count(*) from Census..Data2;

--Dataset for particular states:

select * from Census..Data1 where State in ('Jharkhand', 'Bihar');

select * from Census..Data1 where State in ('West Bengal', 'Maharashtra');

--Calculating population of India:

select sum(population) from Census..Data2;

select sum(population) as Population from Census..Data2;

--Calculating average growth:

select avg(growth) from Census..Data1;

select avg(growth)*100 as avg_growth from Census..Data1;

select state,avg(growth)*100 as avg_growth from Census..Data1 group by state;

--Calculating average sex ratio:

select state,avg(sex_ratio) as avg_sex_ratio from Census..Data1 group by state;

select state,round(avg(sex_ratio),0) as avg_sex_ratio from Census..Data1 group by state;

select state,round(avg(sex_ratio),0) as avg_sex_ratio from Census..Data1 group by state order by avg_sex_ratio desc;

--Calculating average literacy ratio:

select state,round(avg(literacy),0) as avg_literacy_ratio from Census..Data1 group by state order by avg_literacy_ratio desc ;

select state,round(avg(literacy),0) as avg_literacy_ratio from Census..Data1 group by state having round(avg(literacy),0)>90 order by avg_literacy_ratio desc ;


--Top 3 state showing the highest growth ratio:

select state,avg(growth)*100 as avg_growth from Census..Data1 group by state order by avg_growth desc limit 3;

select top 3 state,avg(growth)*100 as avg_growth from Census..Data1 group by state order by avg_growth desc;

--Bottom 3 state showing the lowest growth ratio:

select top 3 state,avg(growth)*100 as avg_growth from Census..Data1 group by state order by avg_growth asc;


--Bottom 3 state showing the lowest sex ratio:

select state,round(avg(sex_ratio),0) as avg_sex_ratio from Census..Data1 group by state order by avg_sex_ratio asc;

select top 3 state,round(avg(sex_ratio),0) as avg_sex_ratio from Census..Data1 group by state order by avg_sex_ratio asc;


--Top 3 state showing the highest sex ratio:

select state,round(avg(sex_ratio),0) avg_sex_ratio from Census..Data1 group by state order by avg_sex_ratio desc;

select top 3 state,round(avg(sex_ratio),0) avg_sex_ratio from Census..Data1 group by state order by avg_sex_ratio desc;


-- Top & bottom 3 states in literacy rate:

drop table if exists #topstates;
create table #topstates
(state nvarchar(255),
topstates float)

insert into #topstates
select state,round(avg(literacy),0) as avg_literacy_ratio from Census..Data1 group by state order by avg_literacy_ratio desc;

select * from #topstates;

select top 3 * from #topstates order by #topstates.topstates desc;

drop table if exists #bottomstates;
create table #bottomstates
(state nvarchar(255),
bottomstates float)

insert into #bottomstates
select state,round(avg(literacy),0) as avg_literacy_ratio from Census..Data1 group by state order by avg_literacy_ratio asc;

select * from #bottomstates;

select top 3 * from #bottomstates order by #bottomstates.bottomstates asc;

select * from (select top 3 * from #topstates order by #topstates.topstates desc)a
union
select * from (select top 3 * from #bottomstates order by #bottomstates.bottomstates asc)b;


--Searching the states with particular letters:

select state from Census..Data1 where state like 'A%';

select distinct state from Census..Data1 where state like 'A%';

select distinct state from Census..Data1 where state like 'A%' or state like 'B%';


select distinct state from Census..Data1 where lower(state) like 'a%' or lower(state) like 'b%';

select distinct state from Census..Data1 where lower(state) like 'a%' and lower(state) like '%h';

select distinct state from Census..Data1 where lower(state) like 'a%' or lower(state) like '%m';

select distinct state from Census..Data1 where lower(state) like 'a%' and lower(state) like '%m';


--Joining Tables:

select * from Census.dbo.Data1;

select * from Census.dbo.Data2;

select a.district,a.state,a.sex_ratio,b.population  from Census..Data1 a inner join Census..Data2 b on a.district=b.district;


--Calculating total number of Males and Females:

select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from Census..Data1 a inner join Census..Data2 b on a.district=b.district )c;


select d.state, sum(d.males) as Total_males, sum(d.females) as total_females from 
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from Census..Data1 a inner join Census..Data2 b on a.district=b.district )c) d group by d.state;


--Calculating total literacy rates:

select * from Census.dbo.Data1;

select a.district,a.state,a.literacy/100 as literacy_ratio,b.population  from Census..Data1 a inner join Census..Data2 b on a.district=b.district;

select d.district,d.state,d.literacy_ratio*d.population as literate_people,(1-d.literacy_ratio)* d.population as illiterate_people from
(select a.district,a.state,a.literacy/100 as literacy_ratio,b.population from Census..Data1 a inner join Census..Data2 b on a.district=b.district) d;

select d.district,d.state,round(d.literacy_ratio*d.population,0) as literate_people,round((1-d.literacy_ratio)* d.population,0) as illiterate_people from
(select a.district,a.state,a.literacy/100 as literacy_ratio,b.population from Census..Data1 a inner join Census..Data2 b on a.district=b.district) d;


select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from
(select d.district,d.state,round(d.literacy_ratio*d.population,0) as literate_people,round((1-d.literacy_ratio)* d.population,0) as illiterate_people from
(select a.district,a.state,a.literacy/100 as literacy_ratio,b.population from Census..Data1 a inner join Census..Data2 b on a.district=b.district) d) c
group by c.state;


--population in previous census:

select * from Census.dbo.Data1;
select * from Census.dbo.Data2;

select a.district,a.state,a.growth,b.population  from Census..Data1 a inner join Census..Data2 b on a.district=b.district;

select d.district,d.state,d.population/(1+d.growth) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth,b.population  from Census..Data1 a inner join Census..Data2 b on a.district=b.district) d;

select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth,b.population  from Census..Data1 a inner join Census..Data2 b on a.district=b.district) d;

select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth,b.population  from Census..Data1 a inner join Census..Data2 b on a.district=b.district) d) e
group by e.state;

--previous_census_population & current_census_population simulataneously:

select sum(f.previous_census_population) previous_census_population,sum(f.current_census_population) current_census_population from
(select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth,b.population  from Census..Data1 a inner join Census..Data2 b on a.district=b.district) d) e
group by e.state) f;


--population vs area

select * from Census.dbo.Data1;
select * from Census.dbo.Data2;

select sum(area_km2) from Census..Data2;

select '1' as keyy,n.* from
(select sum(f.previous_census_population) previous_census_population,sum(f.current_census_population) current_census_population from
(select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth,b.population  from Census..Data1 a inner join Census..Data2 b on a.district=b.district) d) e
group by e.state) f)n;

select '1' as keyy,z.* from
(select sum(area_km2) as total_area from Census..Data2)z;

select q.*,r.* from 
(select '1' as keyy,n.* from
(select sum(f.previous_census_population) previous_census_population,sum(f.current_census_population) current_census_population from
(select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth,b.population  from Census..Data1 a inner join Census..Data2 b on a.district=b.district) d) e
group by e.state) f)n)q inner join 
(select '1' as keyy,z.* from
(select sum(area_km2) as total_area from Census..Data2)z)r on q.keyy=r.keyy;


--Top 3 districts from each state which has highest literacy ratio:

select * from Census.dbo.Data1;

select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from Census..Data1;

select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from Census..Data1) a where a.rnk in (1,2,3);

select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from Census..Data1) a where a.rnk in (1,2,3) order by state;
