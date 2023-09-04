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
