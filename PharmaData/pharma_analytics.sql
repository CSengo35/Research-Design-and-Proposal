create database pharma_data_2025;
select database();
show tables;
select count(*) from customers;
select count(*) from inventory;
select * from inventory;
select * from products;

select p.product_name,
		p.category,
        i.stock_on_hand,
        i.reorder_level,
        i.stock_on_hand - i.reorder_level AS stock_gap
from products p
join inventory i
on i.product_id = p.product_id
group by product_name, p.category, i.stock_on_hand, i.reorder_level
order by stock_gap;

select p.product_name,
		p.category,
        sum(o.quantity)/count(distinct(o.order_date)) AS daily_sales
from orders o
join products p
on p.product_id = o.product_id
group by p.product_name, p.category
order by daily_sales DESC;

create view daily_sales AS
select     o.product_id,
			sum(o.quantity)/count(distinct(o.order_date)) AS daily_sales
from orders o
group by o.product_id;

select p.product_name,
		p.category,
        i.stock_on_hand,
		d.daily_sales,
        round(i.stock_on_hand/d.daily_sales,1) AS days_remaining
from products p
join inventory i 
on i.product_id = p.product_id
join daily_sales d
on p.product_id = d.product_id
group by p.product_name, p.category, i.stock_on_hand, d.daily_sales
order by days_remaining ASC;

select p.product_name,
		p.category,
        i.stock_on_hand,
		d.daily_sales,
        round(i.stock_on_hand/d.daily_sales,1) AS days_remaining,
CASE
		when (i.stock_on_hand/d.daily_sales) < 7 THEN 'Critical'
        when (i.stock_on_hand/d.daily_sales) between 7 and 14 then 'Warning'
        else 'Safe'
        END AS risk_category
from products p
join inventory i 
on i.product_id = p.product_id
join daily_sales d
on p.product_id = d.product_id
group by p.product_name, p.category, i.stock_on_hand, d.daily_sales
order by days_remaining ASC;

create view rev_segmentation AS
select o.customer_id,
sum(o.quantity*p.unit_price) As total_revenue,
case
		when sum(o.quantity*p.unit_price) > 10000 then 'High Value'
        when sum(o.quantity*p.unit_price) between 5000 and 9999 then 'Middle value'
        else 'Low value'
        end AS 'revenue_segment'
        from orders o
        join products p
        on p.product_id = o.product_id
        group by o.customer_id;

select c.customer_type,
		r.revenue_segment,
        count(*) as number_of_customers,
        sum(r.total_revenue) As segment_revenue
	from rev_segmentation r
    join customers c
    on c.customer_id = r.customer_id
    group by r.revenue_segment, c.customer_type 
    order by segment_revenue desc;
    
select c.customer_id,
		count(distinct o.order_id) As total_orders,
        Min(o.order_date) As first_order_date,
        max(o.order_date) As last_order_date
From orders o
join customers c
on c.customer_id = o.customer_id
group by c.customer_id
order by total_orders;

select o.customer_id,
count(distinct o.order_id) as total_orders,
max(o.order_date) as last_order_date,
case
	when count(distinct o.order_id) >=10 then 'Loyal'
    when count(distinct o.order_id) between 4 and 9 then 'Regular'
    else 'At risk'
    end as 'retention_Segment'
from orders o
group by o.customer_id;

create view customer_retention as
select o.customer_id,
		count(distinct o.order_id) as total_orders,
	case
		when count(distinct o.order_id) >= 10 then 'Loyal customers'
        when count(distinct o.order_id) between 4 and 9 then 'Regular customers'
        else 'At Risk'
        end as 'retention_segment'
from orders o
group by o.customer_id
order by total_orders;

select retention_segment,
		count(*) as number_of_customers
from customer_retention
group by retention_segment
order by number_of_customers DESC;

        
        

