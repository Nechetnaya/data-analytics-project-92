select count(*) from customers as customers_count; -- считает покупателей

select
	concat(e.first_name, ' ', e.last_name) as name,
	count(s.sales_id) as operations,
	floor(sum(s.quantity*p.price)) as income
from employees e
left join sales s
on s.sales_person_id = e.employee_id
left join products p
on p.product_id = s.product_id
group by concat(e.first_name, ' ', e.last_name)
order by income desc nulls last
limit 10; -- топ 10 продавцов с наибольшей выручкой

with avg_income as (
	select
		concat(e.first_name, ' ', e.last_name) as name,
		round(avg(s.quantity*p.price)) as average_income
	from employees e
	left join sales s
	on s.sales_person_id = e.employee_id
	left join products p
	on p.product_id = s.product_id
	group by concat(e.first_name, ' ', e.last_name)
	order by average_income
)
select * from avg_income where average_income < (
	select avg(average_income) from avg_income); -- продавцы со средней выручкой сделки ниже, чем средняя среди всех продавцов

select
	name,
	case
		when weekday_n = '1' then 'monday   '
		when weekday_n = '2' then 'tuesday  '
		when weekday_n = '3' then 'wednesday'
		when weekday_n = '4' then 'thursday '
		when weekday_n = '5' then 'friday   '
		when weekday_n = '6' then 'saturday '
		when weekday_n = '7' then 'sunday   '
	end as weekday,
	income
from (
	select
		concat(e.first_name, ' ', e.last_name) as name,
		to_char(s.sale_date, 'id') as weekday_n,
		round(sum(s.quantity*p.price)) as income
	from employees e
	left join sales s
	on s.sales_person_id = e.employee_id
	left join products p
	on p.product_id = s.product_id
	group by concat(e.first_name, ' ', e.last_name), weekday_n
	having round(sum(s.quantity*p.price)) is not null
	order by weekday_n, name
) as result; -- прибыль по продовцам по дням недели

select
	case
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		when age > 40 then '40+'
	end as age_category,
	count (customer_id)
from customers c
group by age_category
order by age_category; -- количество покупателей по возрастным категориям

select
	to_char(sale_date, 'YYYY-MM') as date,
	count(distinct customer_id) as total_customers,
	floor(sum(income)) as income
from (
	select
		s.sale_date,
		s.customer_id,
		(s.quantity * p.price) as income
	from sales s
	inner join products p
	on p.product_id = s.product_id
) as result
group by date
order by date; -- количество уникальных покупателей и прибыль по месяцам

with row_date_customer as (
	select
		s.customer_id,
		concat(c.first_name, ' ', c.last_name) as customer,
		s.sale_date,
		concat(e.first_name, ' ', e.last_name) as saller,
		p.price,
		row_number() over (partition by s.customer_id order by s.sale_date)
	from sales s
	inner join customers c
	on c.customer_id = s.customer_id
	inner join employees e
	on e.employee_id = s.sales_person_id
	inner join products p
	on p.product_id = s.product_id
)
select customer, sale_date, seller
from row_date_customer
where row_number = 1 and price = 0
order by customer_id; -- покупатели с первой покупкой по акции

