--#1
Select st.name, st.surname, h.name
From students st
Inner join hobbies h
On st.id = h.id
--#2
Select st.*, min(sth.date_start)
From students st
Inner join students_hobbies sth
On st.id = sth.id
Where sth.date_finish is null
Group by st.id
Order by min
Limit 1
--#3
Select st.name, st.surname, st.score, avg(st.score), sum(h.risk)
From students st
Inner join students_hobbies sth
On st.id = sth.student_id
Inner join hobbies h
On h.id = sth.hobby_id
Group by st.name, st.surname, st.score
Having sum(h.risk) > 0.9 and st.score > (select avg(score) from students)
--#4
Select st.name, h.name, sth.date_finish, sth.date_start, 
(extract (month from age(sth.date_finish,sth.date_start)) + extract(year from age(sth.date_finish,sth.date_start)*12)) as mounth
From students st
Inner join students_hobbies sth
On st.id = sth.student_id
Inner join hobbies h
On h.id = sth.hobby_id
Where not sth.date_finish is null
Group by st.name, h.name, sth.date_finish, sth.date_start, mounth
--#5
WITH act_hob1 as (
select sth.student_id
From students_hobbies sth
Where sth.date_finish is null
Group by sth.student_id
Having count(*) > 1
)

Select st.name, st.surname, st.birth_date
From students st
Inner join act_hob1 ah
On st.id = ah.student_id
Where extract(year from age(now(),st.birth_date)) >= 20
--#6
Select st.n_group, avg(st.score)
From students st
Inner join students_hobbies sth
On st.id = sth.student_id
Where date_finish is null
Group by st.n_group
--#7
Select st.surname, st.n_group, h.risk, h.name, sth.date_start
From students st
Inner join students_hobbies sth
On st.id = sth.student_id
Inner join hobbies h
On h.id = sth.hobby_id
Where sth.date_finish is null
Order by sth.date_start
Limit 1
--#8
Select distinct h.name
From students st
Inner join students_hobbies sth
On st.id = sth.student_id
Inner join hobbies h
On h.id = sth.hobby_id
Where st.score = (Select max(score) from students)
--#9
Select st.surname, h.name
From students st
Inner join students_hobbies sth
On st.id = sth.student_id
Inner join hobbies h
On h.id = sth.hobby_id
Where st.score::varchar like '4%' and st.n_group::varchar like '2%' and sth.date_finish is null
--#10
Select distinct substr(st.n_group::varchar,1,1) as n_course
From students st 
Inner join students_hobbies sth on st.id = sth.student_id
Inner join hobbies h on sth.hobby_id = h.id
Where sth.date_finish is null
Group by st.surname, st.name, st.n_group
Having count(sth.hobby_id) > 1
--#11
Select *
From (Select n_group, count(score) as avg_count 
	  From students 
	  Group by n_group) t1
Inner join (Select n_group, count(score) as inner_count 
			From students
			Where score >= 4 
			Group by n_group) t2 
On t2.n_group = t1.n_group
Where inner_count/avg_count >= 0.6;
--#12
Select count(distinct sth.hobby_id), substr(st.n_group::varchar, 1, 1) as Course
From students st
Inner join students_hobbies sth
On st.id = sth.student_id
Where date_finish is null
Group by Course
--#13
Select st.name, st.surname, st.birth_date, substr(st.n_group::varchar, 1, 1) as course
From students st
Left join students_hobbies sth
On st.id = sth.student_id
Where st.score >= 4.5 and sth.date_start is null
Order by course asc, st.birth_date desc
--#14
Create view allinfst as
Select st.* from students st 
Inner join students_hobbies sh on st.id = sh.student_id
Inner join hobbies h on sh.hobby_id = h.id
Where sh.date_finish is null and extract (year from age(now()::date, sh.date_start))>=5
--#15
Select h.name, count(sh.student_id) as stud_on_hobby
From students_hobbies sh 
Inner join hobbies h on sh.hobby_id = h.id
Group by hobby_id, h.name
Order by stud_on_hobby desc
--#16
Select h.id
From students_hobbies sh 
Inner join hobbies h on sh.hobby_id = h.id
Group by h.id
Order by count(sh.student_id) desc limit 1
--#17
Select st.*
From students st
Inner join students_hobbies sh on st.id = sh.student_id
Where sh.hobby_id = (Select h.id
	From students_hobbies sh 
	Inner join hobbies h on sh.hobby_id = h.id
	Group by h.id
	Order by count(sh.student_id) desc limit 1)
--№18
Select h.risk as mostrisk
From hobbies h
Order by risk desc limit 3
--#19
Create or replace view num19 as  
Select h.name as hobby_name, h.risk,st.name as student_name,st.n_group,extract (year from age(now()::date, sh.date_start)) * 12
                       + extract(month from age(now()::date, sh.date_start)) as month_length
From students st 
Inner join students_hobbies sh on st.id = sh.student_id
Inner join hobbies h on sh.hobby_id = h.id
Order by month_length DESC limit 10
--#20
Select distinct n_group
From num19
--#21
Create or replace view info as  
Select name, surname, score
From students
Order by score desc
--#22
With chobbies as (
	Select substr(st.n_group::varchar, 1, 1) as course, sh.hobby_id, count(*) as c
	From students st
	Inner join students_hobbies sh on st.id = sh.student_id
	Group by course, sh.hobby_id
), maxforcourse as (
	Select ch.course, max(c) as max_c
	From chobbies ch
	Group by ch.course
)
Select ch.course, ch.hobby_id
From chobbies ch
Inner join maxforcourse mfc on ch.course = mfc.course and ch.c = mfc.max_c
--#23
Select h.risk as mostpopula, h.name
From students st 
Inner join students_hobbies sh on st.id = sh.student_id
Inner join hobbies h on sh.hobby_id = h.id
Where st.n_group::varchar like '2%'
Order by risk desc
Limit 1
--#25
Select sh.hobby_id, count(*) as count_stud
From students st
Inner join students_hobbies sh on st.id = sh.student_id
Group by sh.hobby_id
Order by count_stud desc
Limit 1
--#27
Select st.*, max(st.score), avg(st.score), min(st.score)
From students st
Where substr(name,1,1) like 'А%'
Group by st.id
Having st.score > 4.6
--#29
Select substr(st.birth_date::varchar,1,4) as birth_year, count(name)
From students st 
Inner join students_hobbies sh on st.id = sh.student_id
Group by birth_year
