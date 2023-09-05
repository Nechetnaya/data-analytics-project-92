select count(*) from customers as customers_count; -- считает покупателей

select
	concat(e.first_name, e.last_name) as name,
	count(s.sales_id) as operations,
	floor(sum(s.quantity*p.price)) as income
from employees e
left join sales s
on s.sales_person_id = e.employee_id
left join products p
on p.product_id = s.product_id
group by concat(e.first_name, e.last_name)
order by income desc nulls last
limit 10; -- топ 10 продавцов с наибольшей выручкой

with avg_income as (
	select
		concat(e.first_name, e.last_name) as name,
		coalesce(floor(avg(s.quantity*p.price)), 0) as average_income
	from employees e
	left join sales s
	on s.sales_person_id = e.employee_id
	left join products p
	on p.product_id = s.product_id
	group by concat(e.first_name, e.last_name)
	order by average_income
)
select * from avg_income where average_income < (
	select avg(average_income) from avg_income); -- продавцы со средней выручкой сделки ниже, чем средняя среди всех продавцов

select
	name,
	case
		when weekday_n = '1' then 'monday'
		when weekday_n = '2' then 'tuesday'
		when weekday_n = '3' then 'wednesday'
		when weekday_n = '4' then 'thursday'
		when weekday_n = '5' then 'friday'
		when weekday_n = '6' then 'saturday'
		when weekday_n = '7' then 'sunday'
	end as weekday,
	income
from (
	select
		concat(e.first_name, e.last_name) as name,
		to_char(s.sale_date, 'id') as weekday_n,
		floor(sum(s.quantity*p.price)) as income
	from employees e
	left join sales s
	on s.sales_person_id = e.employee_id
	left join products p
	on p.product_id = s.product_id
	group by concat(e.first_name, e.last_name), weekday_n
	order by weekday_n, name
) as result; -- прибыль по продовцам по дням недели
