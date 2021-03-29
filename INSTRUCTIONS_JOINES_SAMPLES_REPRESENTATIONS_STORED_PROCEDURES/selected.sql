-- ----------------------------------
-- найти кто проработал меньше 2х лет
-- ----------------------------------
-- ----------------------------------
SELECT first_name, last_name, (TIMESTAMPDIFF(YEAR, start_date, finish_date)) AS shop_experience
FROM workers
WHERE (TIMESTAMPDIFF(YEAR, start_date, finish_date)) < '2'
ORDER BY shop_experience;
-- -------------------------------------------------------------------------------
SELECT (TIMESTAMPDIFF(YEAR, start_date, finish_date)) AS shop_experience, COUNT(*) as quantity_workers
FROM workers
WHERE (TIMESTAMPDIFF(YEAR, start_date, finish_date)) < '2'
GROUP BY (TIMESTAMPDIFF(YEAR, start_date, finish_date));
-- ----------------------------
-- кол-во продаж за посл. месяц
-- ----------------------------
-- ----------------------------
select * from sale where date_sale between '2020-08-07%' and '2020-09-09%'
order by date_sale;
-- -----------------------------
-- замена значений пола на слова 
-- -----------------------------
-- -----------------------------
SELECT 
	IF (gender=1, 'муж', 'жен')
    gender, count(*) FROM workers GROUP BY gender;

-- ------------------------------------------------
-- кто больше продал товара девушки или парни
-- ------------------------------------------------
-- ------------------------------------------------
SELECT
	IF (count(id_workers IN (SELECT workers.id FROM workers WHERE gender='1')) > count(id_workers IN (SELECT workers.id FROM workers WHERE gender='2')),
		'больше продали парни', 'больше продали девушки' ) AS who_sell_beter
FROM sale;
-- -------------------------------------------------------------------------
-- сделать выборку работников кто был ответстаенный за заказ товаров в первом магазе
-- ---------------------------------------
-- ---------------------------------------
SELECT p_p.responsabile_worker_id, w.first_name, w.last_name 
FROM 
purchase_products AS p_p, 
workers AS w
WHERE shop_id = '1' 
AND
w.id=p_p.responsabile_worker_id; 
-- -----------------------------------
-- имя, фамилия работников в автопарке
-- -----------------------------------
-- -----------------------------------
SELECT workers.first_name, workers.last_name FROM workers, auto_park
WHERE workers.id=auto_park.id_responsible;
-- -----------------------------------------------------------
-- какой работник и какую технику использует в первом магазине
-- -----------------------------------------------------------
-- -----------------------------------------------------------
SELECT w.`first_name`, w.`last_name`, a_p.`marka`, a_p.`type`
FROM 
workers AS w
RIGHT JOIN
auto_park AS a_p
ON a_p.id_responsible=w.id
JOIN 
relation_shop_auto AS rsa
ON rsa.auto_park_id=a_p.id AND shop_id = '1';
-- ------------------------------------------
-- ПРЕДСТАВЛЕНИЯ
-- -------------
-- -------------
create view Action_popular AS

	select w.first_name, w.last_name, s_s.profession,
	(TIMESTAMPDIFF(YEAR, w.start_date, w.finish_date)) AS experience_in_shop
	from 
		workers as w
	LEFT JOIN
		relation_workers_staff as rws ON
			rws.workers_id=w.id
	LEFT JOIN
		shop_staff as s_s ON
			s_s.id=rws.shop_staff_id;

-- ---------------------------------
-- разница в деньгах закупка-продажа
-- ---------------------------------
-- ---------------------------------
create view diferents as
select 
	sum(sale.price) as sales_amount,
	sum(purchase_products.total_sum) as order_value,
    (sum(sale.price) - sum(purchase_products.total_sum)) as diference
from sale join purchase_products;

-- ------------------------
-- средний чек у покупателя
-- ------------------------
-- ------------------------
CREATE VIEW mid_amount_money_spent_buyer AS
select 
	buyer.first_name, buyer.last_name,
	COUNT(id_buyer) AS Quantity,
    (SUM(total_sum) / Quantity) AS medium_money_spend
    -- AVG(total_sum) AS medium_money_spend
from sale
	join buyer
		on buyer.id=sale.id_buyer
	GROUP BY id_buyer
		HAVING quantity > '1'
		ORDER BY quantity DESC;
-- ------------------
-- продажи по месяцам
-- ------------------
-- ------------------
CREATE VIEW sales_per_month AS
SELECT 
	SUM(quantity), 
	MONTHNAME(date_sale), SUM(total_sum)
FROM sale
WHERE YEAR(date_sale)='2020'
group by MONTHNAME(date_sale);

-- ----------------
-- тригерры
-- --------------------------------------------------------
-- лучший продавец, который сделал наибольшее кол-во продаж
-- --------------------------------------------------------
DELIMITER //
CREATE PROCEDURE best_seller ()
BEGIN
	SELECT 
		workers.first_name, 
        workers.last_name, 
        COUNT(sale.id) as 'сумарные продажи'
        FROM sale
        join workers
			on sale.id_workers=workers.id
		group by workers.id
        order by sum(sale.id) DESC
        limit 2;
END //
DELIMITER ;

-- -------------------------------------------------------------------------------------------------------------------
-- запрос размера заказа с выводом имени и фамилии ответственного по закупкам и общая сумма заказа, в заданых пределах
-- -------------------------------------------------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE workers_size_orders (arg VARCHAR(45))
BEGIN
	CASE arg
	WHEN "не большой заказ"
    THEN
		SELECT workers.last_name, workers.first_name, purchase_products.total_sum, count(workers.id) as "Количество заказов"
		from workers 
		join purchase_products ON purchase_products.responsabile_worker_id=workers.id
		group by workers.id
		having total_sum < '100000'
		ORDER BY count(workers.id) DESC;
	WHEN "средний заказ"
    THEN
		SELECT workers.last_name, workers.first_name, purchase_products.total_sum, count(workers.id) as "Количество заказов"
		from workers 
		join purchase_products ON purchase_products.responsabile_worker_id=workers.id
		group by workers.id
		having total_sum >= '100000' AND total_sum < '300000'
		ORDER BY count(workers.id) DESC;
	WHEN "большой заказ"
    THEN
		SELECT workers.last_name, workers.first_name, purchase_products.total_sum, count(workers.id) as "Количество заказов"
		from workers 
		join purchase_products ON purchase_products.responsabile_worker_id=workers.id
		group by workers.id
		having total_sum >= '300000'
		ORDER BY count(workers.id) DESC;
	END CASE;
END //
DELIMITER ;

    
    






