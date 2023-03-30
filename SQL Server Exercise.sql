-- SQL Server Exercise --

-- 1. Create Database Syntax
CREATE DATABASE sample_db;
GO

-- 2. CREATE Schema Syntax
CREATE SCHEMA test;
GO

-- 3. Create table name test and test1 (with column id,  first_name, last_name, school, percentage, status (pass or fail),pin, created_date, updated_date)
-- Define constraints in it such as Primary Key, Foreign Key, Noit Null...
-- Apart from this take default value for some column such as cretaed_date"
CREATE TABLE test (
	id INT,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	school VARCHAR(255) NOT NULL,
	percentage NUMERIC(5,2) NOT NULL,
	status VARCHAR(4) NOT NULL,
	pin BIGINT NOT NULL,
	created_date DATETIME2 DEFAULT GETDATE(),
	updated_data DATETIME2 DEFAULT GETDATE()
	CONSTRAINT PK_test_id PRIMARY KEY (id),
	CONSTRAINT check_test_percentage CHECK (percentage BETWEEN 0 AND 100),
	CONSTRAINT check_test_status CHECK (status IN ('PASS', 'FAIL'))
	);

INSERT INTO test (id, first_name, last_name, school, percentage, status, pin) 
VALUES (1, 'JOHN', 'WICK', 'SAINT MARY', 90.901, 'PASS', 123456);

SELECT * INTO test1 FROM test;
GO

-- 4. Create film_cast table with film_id,title,first_name and last_name of the actor.. (create table from other table)
SELECT fa.film_id, f.title, a.first_name, a.last_name 
INTO film_cast
FROM actor a JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id;

GO

-- 5. drop table test1
DROP TABLE test1;
GO

-- 6. What is temproray table ? what is the purpose of temp table ? create one temp table 

-- Temporary tables are tables that exist temporarily on the SQL Server.
-- The temporary tables are useful for storing the immediate result sets that are accessed multiple times.
-- Temporary tables are automatically deleted after session ends.
CREATE TABLE #temp_table (
	id INT,
	name VARCHAR(10) );
GO

-- 7. difference between delete and truncate ? 

-- Delete remove rows from table one by one and keep log of all the deleted records and it is DML command.
-- Truncate remove all the rows from table without going through all rows, and it won't keep records of all the rows and it is DDL command.
-- Truncate statement resets identity columns while delete statement just delete records, doesn't interfere with identity columns.
DELETE FROM film_cast;
TRUNCATE TABLE film_cast;
GO

-- 8. rename test table to student table
sp_rename 'test', 'student';
GO

-- 9. add column in test table named city 
ALTER TABLE student 
ADD city VARCHAR(50);
GO

-- 10. change data type of one of the column of test table
ALTER TABLE student 
ALTER COLUMN pin SMALLINT;
GO

-- 11. drop column pin from test table 
ALTER TABLE student 
DROP COLUMN pin;
GO

-- 12. rename column city to location in test table
sp_rename 'student.city', 'location', 'COLUMN';
GO

-- 13. Create a Role with read only rights on the database.
CREATE ROLE role1;
GRANT SELECT ON DATABASE::sample_db TO role1;
GO

-- 14. Create a role with all the write permission on the database.
CREATE ROLE role2;
GRANT INSERT, DELETE, UPDATE ON DATABASE::sample_db TO role2;
GO

-- 15. Create a database user who can only read the data from the database.
CREATE LOGIN User1 WITH PASSWORD = 'password', CHECK_POLICY = OFF;

CREATE USER User1 FOR LOGIN User1;
ALTER ROLE role1 ADD MEMBER User1;
GO

-- 16. Create a database user who can read as well as write data into database.
CREATE LOGIN User2 WITH PASSWORD = 'password', CHECK_POLICY = OFF;

CREATE USER User2 FOR LOGIN User2;
ALTER ROLE role2 ADD MEMBER User2;

GRANT SELECT ON DATABASE::sample_db TO role2;
GO

-- 17. Create an admin role who is not superuser but can create database and manage roles.
CREATE LOGIN adminuser WITH PASSWORD = 'password', CHECK_POLICY = OFF;

CREATE USER adminuser FOR LOGIN adminuser;

CREATE ROLE adminrole;
ALTER ROLE adminrole ADD MEMBER adminuser;

GRANT CREATE ANY DATABASE TO adminrole;
GRANT ALTER ANY ROLE TO adminrole;
GRANT CREATE ROLE TO adminrole;
GO

-- 18. Create user whoes login credentials can last until 1st June 2023
CREATE LOGIN User3 WITH PASSWORD = 'P@ssword', CHECK_EXPIRATION = ON, CHECK_POLICY = ON;

CREATE USER User3 FOR LOGIN User3;
-- Can't specify expiration date in SQL server
GO

-- 19. List all unique film's name. 
SELECT DISTINCT(title) FROM film;
GO

-- 20. List top 100 customers details.
SELECT TOP 100 * FROM customer;
GO

-- 21. List top 10 inventory details starting from the 5th one.
SELECT * FROM inventory
ORDER BY inventory_id 
OFFSET 5 ROWS 
FETCH NEXT 10 ROWS ONLY;
GO

-- 22. find the customer's name who paid an amount between 1.99 and 5.99.
SELECT first_name + ' ' + last_name AS Name 
FROM customer c JOIN payment p ON c.customer_id = p.customer_id
WHERE p.amount BETWEEN 1.99 AND 5.66;
GO

-- 23. List film's name which is staring from the A.
SELECT title FROM film 
WHERE title LIKE 'A%';
GO

-- 24. List film's name which is end with "a"
SELECT title FROM film 
WHERE title LIKE '%a';
GO

-- 25. List film's name which is start with "M" and ends with "a"
SELECT title FROM film 
WHERE title LIKE 'M%a';
GO

-- 26. List all customer details which payment amount is greater than 40. (USING EXISTs)
SELECT * FROM customer AS c
WHERE EXISTS (
	SELECT customer_id, SUM(amount) AS Total 
	FROM payment AS p 
	WHERE c.customer_id = p.customer_id 
	GROUP BY customer_id 
	HAVING SUM(amount) > 40 );
GO

-- 27. List Staff details order by first_name.
SELECT * FROM staff 
ORDER BY first_name;
GO

-- 28. List customer's payment details (customer_id,payment_id,first_name,last_name,payment_date)
SELECT c.customer_id, p.payment_id, c.first_name, c.last_name, p.payment_date 
FROM customer c JOIN payment p 
ON c.customer_id = p.customer_id;
GO

-- 29. Display title and it's actor name.
SELECT f.title, a.first_name + ' ' + a.last_name as Name 
FROM film f JOIN film_actor fa 
ON f.film_id = fa.film_id 
JOIN actor a 
ON fa.actor_id = a.actor_id;
GO

SELECT f.title, STRING_AGG (a.first_name + ' ' + a.last_name, ', ') Actors
FROM film f JOIN film_actor fa 
ON f.film_id = fa.film_id 
JOIN actor a 
ON a.actor_id = fa.actor_id 
GROUP BY f.title;
GO

-- 30. List all actor name and find corresponding film id
SELECT a.first_name + ' ' + a.last_name as Name, fa.film_id 
FROM film f JOIN film_actor fa 
ON f.film_id = fa.film_id 
JOIN actor a
ON fa.actor_id = a.actor_id;

SELECT a.actor_id, a.first_name + ' ' + a.last_name as Name, STRING_AGG (fa.film_id, ',') film 
FROM actor a JOIN film_actor fa 
ON a.actor_id = fa.actor_id 
GROUP BY a.actor_id, a.first_name, a.last_name;
GO

-- 31. List all addresses and find corresponding customer's name and phone.
SELECT a.address_id, a.address, c.first_name + ' ' + c.last_name AS Name, a.phone 
FROM address a LEFT JOIN customer c 
ON c.address_id = a.address_id;
GO

-- 32. Find Customer's payment (include null values if not matched from both tables)(customer_id,payment_id,first_name,last_name,payment_date)
SELECT c.customer_id, p.payment_id, c.first_name, c.last_name, p.payment_date 
FROM customer c FULL OUTER JOIN payment p 
ON c.customer_id = p.customer_id;
GO

-- 33. List customer's address_id. (Not include duplicate id )
SELECT DISTINCT(address_id) FROM customer;
GO

-- 34. List customer's address_id. (Include duplicate id )
SELECT address_id FROM customer;
GO

-- 35. List Individual Customers' Payment total.
WITH total AS (
	SELECT customer_id, SUM(amount) sum_ 
	FROM payment 
	GROUP BY customer_id )
SELECT c.customer_id, c.first_name + ' ' + c.last_name AS Name, t.sum_ 
FROM total t JOIN customer c 
ON t.customer_id = c.customer_id;
GO

-- 36. List Customer whose payment is greater than 80.
WITH total AS (
	SELECT customer_id, SUM(amount) sum_ 
	FROM payment 
	GROUP BY customer_id 
	HAVING SUM(amount) > 80 )
SELECT c.customer_id, c.first_name + ' ' + c.last_name AS Name, t.sum_ 
FROM total t JOIN customer c 
ON t.customer_id = c.customer_id;
GO

-- 37. Shop owners decided to give  5 extra days to keep their dvds to all the rentees who rent the movie before June 15th 2005 make according changes in db
UPDATE rental SET return_date = DATEADD(DAY, 5, return_date) 
WHERE rental_date < '2005-06-15';
GO

-- 38. Remove the records of all the inactive customers from the Database
DELETE FROM customer 
WHERE active = 0;
GO

-- 39. count the number of special_features category wise.... total no.of deleted scenes, Trailers etc....
DECLARE  
	@columns NVARCHAR(MAX) = '', 
	@col VARCHAR(MAX),
	@sql NVARCHAR(MAX) = '';

SELECT  @columns += QUOTENAME(value) + ','
FROM film
CROSS APPLY 
STRING_SPLIT(REPLACE(REPLACE(REPLACE(special_features, '{', ''), '}', ''), '"', '' ), ',');

SET @columns = LEFT(@columns, LEN(@columns) - 1);

WITH cte AS (
	SELECT DISTINCT(VALUE) val 
	FROM STRING_SPLIT(@columns, ',') )
SELECT @col = COALESCE(@col + ', ', '') + val
FROM cte;

SET @sql = '
WITH cte AS (
	SELECT value, f.film_id, name AS Category 
	FROM film f JOIN film_category fc ON f.film_id = fc.film_id 
	JOIN category c ON fc.category_id = c.category_id
	CROSS APPLY 
	STRING_SPLIT(REPLACE(REPLACE(REPLACE(special_features, ''{'', ''''), ''}'', ''''), ''"'', '''' ), '','') )
SELECT * FROM cte PIVOT(count(film_id) 
FOR value IN (' + @col + ')) piv ORDER BY Category;';

EXECUTE sp_executesql @sql;
GO

-- 40. count the numbers of records in film table
SELECT COUNT(*) FROM film;
GO

-- 41. count the no.of special fetures which have Trailers alone, Trailers and Deleted Scened both etc....
SELECT COUNT(film_id), special_features FROM film GROUP BY special_features
GO

-- 42. use CASE expression with the SUM function to calculate the number of films in each rating:
SELECT 
	SUM(CASE rating 
		WHEN 'G' THEN 1 ELSE 0 END) G,
	SUM(CASE rating 
		WHEN 'PG' THEN 1 ELSE 0 END) PG,
	SUM(CASE rating 
		WHEN 'PG-13' THEN 1 ELSE 0 END) "PG-13",
	SUM(CASE rating 
		WHEN 'R' THEN 1 ELSE 0 END) R,
	SUM(CASE rating 
		WHEN 'NC-17' THEN 1 ELSE 0 END) "NC-17"
FROM film;
GO

-- 43. Display the discount on each product, if there is no discount on product Return 0
SELECT id, product, price, COALESCE(discount, 0) AS discount FROM items;
GO

-- 44. Return title and it's excerpt, if excerpt is empty or null display last 6 letters of respective body from posts table
SELECT title, COALESCE(NULLIF(excerpt, ''), RIGHT(CAST(body AS VARCHAR(MAX)), 6)) AS excerpt FROM posts;
GO

-- 45. Can we know how many distinct users have rented each genre? if yes, name a category with highest and lowest rented number  ..
WITH rented_genre AS (
	SELECT COUNT(DISTINCT(r.customer_id)) AS Count_, fc.category_id, c.name
	FROM rental r JOIN inventory i 
	ON r.inventory_id = i.inventory_id
	JOIN film_category fc 
	ON i.film_id = fc.film_id
	JOIN category c 
	ON fc.category_id = c.category_id
	GROUP BY fc.category_id, c.name )
SELECT * FROM rented_genre 
	WHERE Count_ = (SELECT MIN(Count_) FROM rented_genre)
UNION
SELECT * FROM rented_genre 
	WHERE Count_ = (SELECT MAX(Count_) FROM rented_genre);
GO

-- 46. Return film_id,title,rental_date and rental_duration
-- according to rental_rate need to define rental_duration 
-- such as 
-- rental rate  = 0.99 --> rental_duration = 3
-- rental rate  = 2.99 --> rental_duration = 4
-- rental rate  = 4.99 --> rental_duration = 5
-- otherwise  6"
SELECT film_id, title, 
	CASE rental_rate
		WHEN 0.99 THEN 3
		WHEN 2.99 THEN 4
		WHEN 4.99 THEN 5
		ELSE 6
	END AS rental_duration
	FROM film;
GO

-- 47. Find customers and their email that have rented movies at priced $9.99.
SELECT c.customer_id, c.first_name + ' ' + c.last_name Name, c.email 
FROM customer c JOIN payment p 
ON c.customer_id = p.customer_id 
WHERE p.amount = 9.99;
GO

-- 48. Find customers in store #1 that spent less than $2.99 on individual rentals, but have spent a total higher than $5.
SELECT customer_id FROM payment 
WHERE customer_id IN (
	SELECT DISTINCT(customer_id) 
	FROM payment JOIN staff 
	ON payment.staff_id = staff.staff_id 
	WHERE staff.store_id = 1 AND amount < 2.99 )
GROUP BY customer_id 
HAVING SUM(amount) > 5;
GO

-- 49. Select the titles of the movies that have the highest replacement cost.
SELECT title FROM film 
WHERE replacement_cost = (SELECT MAX(replacement_cost) FROM film);
GO

-- 50. list the cutomer who have rented maximum time movie and also display the count of that... 
-- (we can add limit here too---> list top 5 customer who rented maximum time)
SELECT TOP 5 customer_id, COUNT(rental_id) total 
FROM rental GROUP BY customer_id ORDER BY total DESC
GO

-- 51. Display the max salary for each department
SELECT dept_name, MAX(salary) 
FROM employee 
GROUP BY dept_name;
GO

-- 52. Display all the details of employee and add one extra column name max_salary (which shows max_salary dept wise) 
/*
emp_id	 emp_name   	dept_name	salary   max_salary
120	""Monica""	""Admin""	5000	 5000
101	""Mohan""	""Admin""	4000	 5000
116	""Satya""	""Finance""	6500	 6500
118	""Tejaswi""	""Finance""	5500	 6500
--> like this way if emp is from admin dept then , max salary of admin dept is 5000, then in the max salary column 5000 will be shown for dept admin
*/
SELECT *, FIRST_VALUE(salary) OVER (PARTITION BY dept_name ORDER BY salary DESC) max_salary FROM employee;
GO

-- 53. Assign a number to the all the employee department wise  
-- such as if admin dept have 8 emp then no. goes from 1 to 8, then if finance have 3 then it goes to 1 to 3
/*
	emp_id   emp_name	dept_name   	salary  no_of_emp_dept_wsie
	120	""Monica""	""Admin""	5000	1
	101	""Mohan""	""Admin""	4000	2
	113	""Gautham""	""Admin""	2000	3
	108	""Maryam""	""Admin""	4000	4
	113	""Gautham""	""Admin""	2000	5
	120	""Monica""	""Admin""	5000	6
	101	""Mohan""	""Admin""	4000	7
	108	""Maryam""	""Admin""	4000	8
	116	""Satya""      	""Finance""	6500	1
	118	""Tejaswi""	""Finance""	5500	2
	104	""Dorvin""	""Finance""	6500	3
	106	""Rajesh""	""Finance""	5000	4
	104	""Dorvin""	""Finance""	6500	5
	118	""Tejaswi""	""Finance""	5500	6"
*/
SELECT *, ROW_NUMBER() OVER (PARTITION BY dept_name ORDER BY salary) no_of_emp_dept_wise FROM employee;
GO

-- 54. Fetch the first 2 employees from each department to join the company. (assume that emp_id assign in the order of joining)
WITH cte AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY dept_name ORDER BY emp_id) num 
	FROM employee )
SELECT emp_id, emp_name, dept_name, salary 
FROM cte
WHERE num < 3;
GO

-- 55. Fetch the top 3 employees in each department earning the max salary.
WITH cte AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY dept_name ORDER BY salary DESC) num 
	FROM employee )
SELECT emp_id, emp_name, dept_name, salary 
FROM cte
WHERE num < 3;
GO

-- 56. Write a query to display if the salary of an employee is higher, lower or equal to the previous employee.
WITH cte AS
(
	SELECT *, LAG(salary) OVER(ORDER BY emp_id) AS previous_sal
	FROM employee
)
SELECT *,
	CASE
		WHEN previous_sal < salary THEN 'Higher'
		WHEN previous_sal = salary THEN 'Equal'
		WHEN previous_sal > salary THEN 'Lower'
		ELSE NULL
	END
FROM cte;
GO

-- 57. Get all title names those are released on may DATE
SELECT title 
FROM film f JOIN inventory i 
ON f.film_id = i.film_id 
JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE DATEPART(MONTH, rental_date) = 5;
GO

-- 58. Get all Payments Related Details from Previous week
SELECT * FROM payment
WHERE payment_date 
BETWEEN (GETDATE() - DATEPART(DW, GETDATE()) - 6) AND (GETDATE() - DATEPART(DW, GETDATE()));
GO

-- 59. Get all customer related Information from Previous Year
SELECT * FROM payment
WHERE DATEPART(YEAR, payment_date) > DATEPART(YEAR, GETDATE()) - 1;
GO

-- 60. What is the number of rentals per month for each store?
SELECT staff_id, DATEPART(MONTH, rental_date) month_rental, COUNT(rental_id) Total 
FROM rental 
GROUP BY DATEPART(MONTH, rental_date), staff_id 
ORDER BY staff_id, month_rental;
GO

-- 61. Replace Title 'Date speed' to 'Data speed' whose Language 'English'
UPDATE film SET title = 'Data Speed' 
WHERE title = 'Date Speed' AND language_id = (SELECT language_id FROM language WHERE name = 'English');
GO

-- 62. Remove Starting Character "A" from Description Of film
UPDATE film SET description = SUBSTRING(description, 3, LEN(description))
WHERE description LIKE 'A %'
GO

-- 63. If end Of string is 'Italian' then Remove word from Description of Title
UPDATE film SET description = SUBSTRING(description, 0, LEN(description) - len(' Italian')) 
WHERE description LIKE '%Italian';
GO

-- 64. Who are the top 5 customers with email details per total sales
SELECT TOP 5 c.customer_id, c.email,SUM(amount) AS sales
FROM payment p JOIN customer c 
ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.email
ORDER BY SUM(p.amount) DESC;
GO

-- 65. Display the movie titles of those movies offered in both stores at the same time.
SELECT f.film_id, f.title, i.last_update
	FROM film f JOIN inventory i
	ON f.film_id = i.film_id
	WHERE i.store_id = 1
INTERSECT
SELECT f.film_id, f.title, i.last_update
	FROM film f JOIN inventory i
	ON f.film_id = i.film_id
	WHERE i.store_id = 2;
GO

-- 66. Display the movies offered for rent in store_id 1 and not offered in store_id 2.
SELECT DISTINCT(f.film_id), f.title 
	FROM film f JOIN inventory i 
	ON f.film_id = i.film_id 
	JOIN rental r 
	ON r.inventory_id = i.inventory_id 
	WHERE store_id = 1
EXCEPT
SELECT DISTINCT(f.film_id), f.title 
	FROM film f JOIN inventory i 
	ON f.film_id = i.film_id 
	JOIN rental r 
	ON r.inventory_id = i.inventory_id 
	WHERE store_id = 2;
GO

-- 67. Show the number of movies each actor acted in
SELECT a.actor_id, a.first_name + ' ' + a.last_name AS Name, COUNT(film_id) Movie_count
FROM film_actor fa JOIN actor a 
ON fa.actor_id = a.actor_id 
GROUP BY a.actor_id, a.first_name, a.last_name;
GO

-- 68. Find all customers with at least three payments whose amount is greater than 9 dollars
WITH cte AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY amount) total 
	FROM payment 
	WHERE amount > 9 )
SELECT DISTINCT(a.customer_id), c.first_name + ' ' + c.last_name Name 
FROM cte a JOIN customer c 
ON a.customer_id = c.customer_id 
WHERE total >= 3;
GO

-- 69. Find out the lastest payment date of each customer
SELECT customer_id, MAX(payment_date) 
FROM payment 
GROUP BY customer_id 
ORDER BY customer_id;
GO

-- 70. Create a trigger that will delete a customer's reservation record once the customer's rents the DVD
CREATE OR ALTER TRIGGER reservation_rental_log 
ON rental
AFTER INSERT
AS
	DECLARE @c_id INT, @i_id INT;

	SELECT @c_id = customer_id, @i_id = inventory_id 
	FROM inserted i;

	DELETE FROM reservation 
	WHERE customer_id = @c_id AND inventory_id = @i_id;

GO

-- 71. Create a trigger that will help me keep track of all operations performed on the reservation table. 
-- I want to record whether an insert, delete or update occurred on the reservation table and store that log in reservation_audit table.
CREATE OR ALTER TRIGGER reservation_log
ON reservation
AFTER INSERT, DELETE, UPDATE
AS
	DECLARE
		@c_id INT, @i_id INT, 
		@uc_id INT, @ui_id INT, 
		@date DATE, @log VARCHAR(MAX);

	IF (EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted))
	BEGIN
		SELECT @c_id = customer_id, @i_id = inventory_id, @date = reserve_date
		FROM inserted;

		SET @log = 'Inserted: Customer ID: ' + cast(@c_id as varchar) + ', Inventory ID: ' + cast(@i_id as varchar) + ', on Date: ' + cast(@date as varchar);

		INSERT INTO reservation_audit (log) 
		VALUES (@log);
	END
	ELSE IF(EXISTS(SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted))
	BEGIN
		SELECT @c_id = customer_id, @i_id = inventory_id, @date = reserve_date
		FROM deleted;

		SET @log = 'Deleted: Customer ID: ' + cast(@c_id as varchar) + ', Inventory ID: ' + cast(@i_id as varchar) + ', on Date: ' + cast(@date as varchar);

		INSERT INTO reservation_audit (log) 
		VALUES (@log);
	END
	ELSE
	BEGIN
		SET @log = 'Updated: ';

		SELECT @c_id = customer_id, @i_id = inventory_id 
		FROM deleted;
		SELECT @uc_id = customer_id, @ui_id = inventory_id 
		FROM inserted;

		IF (@c_id <> @uc_id)
		BEGIN
			SET @log = @log + 'Update Customer ID: ' + cast(@c_id as varchar) + ' to ' + cast(@uc_id as varchar) + '. ';
		END
		ELSE IF (@i_id <> @ui_id)
		BEGIN
			SET @log = @log + 'Update Inventory ID: ' + cast(@i_id as varchar) + ' to ' + cast(@ui_id as varchar) + '. ';
		END;

		INSERT INTO reservation_audit (log) 
		VALUES (@log);
	END;

GO

-- 72. Create trigger to prevent a customer for reserving more than 3 DVD's.
CREATE OR ALTER TRIGGER prevent_reserve
ON reservation
INSTEAD OF INSERT
AS
	DECLARE 
		@c_id INT, @i_id INT, @date DATE;

	DECLARE cur CURSOR LOCAL
	FOR 
		SELECT customer_id, inventory_id, reserve_date 
		FROM inserted;

	OPEN cur;
	FETCH cur INTO @c_id, @i_id, @date;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF ((SELECT COUNT(*) FROM reservation WHERE customer_id = @c_id) >= 3)
		BEGIN
			PRINT('The customer already has 3 reservations.');
			BREAK;
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION;

			INSERT INTO reservation 
			VALUES (@c_id, @i_id, @date);

			FETCH cur INTO @c_id, @i_id, @date;

			COMMIT TRANSACTION;
		END;
	END;

	CLOSE cur;
	DEALLOCATE cur;
GO

-- 73. Create a function which takes year as a argument and return the concatenated result of title which contain 'ful' in it and release year 
-- like this (title:release_year) --> use cursor in function
CREATE OR ALTER FUNCTION get_result_year (@year INT)
RETURNS VARCHAR(MAX)
AS BEGIN
	DECLARE 
		@out VARCHAR(MAX) = '',
		@title_film VARCHAR(MAX),
		@release_film VARCHAR(MAX);

	DECLARE cur CURSOR
	FOR 
		SELECT title, release_year 
		FROM FILM WHERE release_year = @year AND title LIKE '%ful%';

	OPEN cur;
	FETCH cur INTO @title_film, @release_film;

	IF (@@FETCH_STATUS <> 0)   
        RETURN '<none>'

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@out = '')
			SET @out = @title_film + ':' + @release_film;
		ELSE
			SET @out = @out + ', ' + @title_film + ':' + @release_film;

		FETCH cur INTO @title_film, @release_film;
	END;
	RETURN @out;
END ;

SELECT dbo.get_result_year(2005) AS title_year;
GO

-- 74. Find top 10 shortest movies using for loop
DECLARE 
	@counter INT = 1,
	@max INT = 10;

WHILE (@counter <= @max)
BEGIN
    SELECT title, length
    FROM film
    ORDER BY length ASC 
	OFFSET @counter - 1 ROWS 
	FETCH NEXT 1 ROWS ONLY;

    SET @counter = @counter + 1;
END;
GO

-- 75. Write a function using for loop to derive value of 6th field in fibonacci series 
-- (fibonacci starts like this --> 1,1,.....)
CREATE OR ALTER FUNCTION fibonacci (@n INT)
RETURNS INT
AS BEGIN
	IF (@n = 1 OR @n = 2)
		RETURN 1;
	ELSE
		DECLARE 
			@a int = 1,
			@b int = 1,
			@c int;

		WHILE @n > 2
			BEGIN
				SET @c = @a + @b;
				SET @a = @b;
				SET @b = @c;
				SET @n = @n - 1;
			END;
		RETURN @c;
END ;

SELECT dbo.fibonacci(6) FIBONACCI;
GO
