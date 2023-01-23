use employees;

# Will be using these tables - employees, departments, dept_manager, titles & salaries to showcase SQL implementation.
#Select_from examples
SELECT 
    *
FROM
    departments;


#Getting distinct contract dates
SELECT DISTINCT
    hire_date
FROM
    employees;


#Looking for female employees from the "employees" table whose first name is "Mary" or "Aruna".
SELECT 
    *
FROM
    employees
WHERE
    gender = 'F'
        AND (first_name = 'Mary'
        OR first_name = 'Aruna');


#Extracting all records from employees table aside from first name 'Jaques','Mary' & 'Deniz'.
SELECT 
    *
FROM
    employees
WHERE
    first_name NOT IN ('Jaques' , 'Mary', 'Deniz');
    

#Extracting all records from employees table whose first name contains 'Mar'.
SELECT 
    *
FROM
    employees
WHERE
    first_name LIKE ('%Mar%');


#Getting salaries between $60,000 and $70,000.
SELECT 
    *
FROM
    salaries
WHERE
    salary BETWEEN 60000 AND 70000;


# Getting average amount of money spent on salaries for all contracts that started after the 1st of January 2000 to a precision of cents.
SELECT 
    ROUND(AVG(salary), 2)
FROM
    salaries
WHERE
    from_date > '2000-01-01';


#Extracting information about all manager's employee number, first and last name, department number, and hire date, that belong department no 'd003'.
SELECT 
    e.emp_no, e.first_name, e.last_name, dm.dept_no, e.hire_date
FROM
    employees e
        JOIN
    dept_manager dm ON e.emp_no = dm.emp_no
WHERE
    dept_no = 'd003';


#Getting info from more than 2 tables
#Getting all managers’ first and last name, hire date, job title, start date, and department name.
SELECT 
    e.first_name,
    e.last_name,
    e.hire_date,
    t.title,
    dm.from_date,
    d.dept_name
FROM
    employees e
        JOIN
    dept_manager dm ON e.emp_no = dm.emp_no
        JOIN
    departments d ON dm.dept_no = d.dept_no
        JOIN
    titles t ON e.emp_no = t.emp_no
WHERE
    t.title = 'Manager'
ORDER BY e.emp_no;


#Getting information of employees whose job title is 'Assistant Engineer'.
SELECT 
    *
FROM
    employees e
WHERE
    EXISTS( SELECT 
            *
        FROM
            titles t
        WHERE
            t.emp_no = e.emp_no
                AND t.title = 'Assistant Engineer');
#The same can also be extracted using join statement)


#Assigning employee number 110022 as a manager to all employees from 10001 to 10020. &
#Assigning employee number 110039 as a manager to all employees from 10021 to 10040.
SELECT 
    A.*
FROM
    (SELECT 
        e.emp_no AS employee_ID,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110022) AS Manager_ID
    FROM
        employees e
    WHERE
        e.emp_no <= 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no) AS A 
UNION SELECT 
    B.*
FROM
    (SELECT 
        e.emp_no AS employee_ID,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110039) AS Manager_ID
    FROM
        employees e
    WHERE
        e.emp_no > 10020 AND e.emp_no <= 10040
    GROUP BY e.emp_no
    ORDER BY e.emp_no) AS B;


#Getting the 2nd highest salary of each employee.
SELECT N.emp_no, MIN(salary) AS min_sal
from (select emp_no, salary,
row_number() over (w) as row_num
from salaries
window w as (partition by emp_no order by salary)) as N
where N.row_num = 2
group by N.emp_no;


#lets check salary increase of all department managers based on assumed conditions.
SELECT 
    dm.emp_no,
    e.first_name,
    e.last_name,
    MAX(salary) - MIN(salary) AS salary_diff,
    CASE
        WHEN MAX(s.salary) - MIN(salary) > 30000 THEN 'salary raised more than $30k'
        WHEN MAX(s.salary) - MIN(salary) BETWEEN 20000 AND 30000 THEN 'salary raised more than $20k but less than $30k'
        ELSE 'salary raised by less than $20k'
    END AS salary_increase
FROM
    dept_manager dm
        JOIN
    employees e ON e.emp_no = dm.emp_no
        JOIN
    salaries s ON s.emp_no = dm.emp_no
GROUP BY s.emp_no;


#Temp table
drop table if exists assigned_managers;
CREATE TABLE assigned_managers (
    employee_ID INT,
    first_name VARCHAR(25),
    last_name VARCHAR(25),
    Manager_ID INT
);

insert into assigned_managers
select A.* from
(select e.emp_no as employee_ID, e.first_name, e.last_name,
(select emp_no
from dept_manager
where emp_no = 110022) as Manager_ID
from employees e
where e.emp_no <= 10020
group by e.emp_no
order by e.emp_no) as A
union
select B.* from
(select e.emp_no as employee_ID,  e.first_name, e.last_name,
(select emp_no
from dept_manager
where emp_no = 110039) as Manager_ID
from employees e
where e.emp_no > 10020 and e.emp_no <= 10040
group by e.emp_no
order by e.emp_no) as B;

SELECT 
    *
FROM
    assigned_managers;

#creating a stored procedure to invoke example average salary.
#drop procedure if exists emp_avg_salary_output;

#Delimiter $$
#create procedure emp_avg_salary_output (in p_emp_no integer)
#begin 
#select avg(s.salary) as avg_sal
#from employees e
#join salaries s on e.emp_no = s.emp_no
#where e.emp_no = p_emp_no;
#end$$

#delimiter ;

