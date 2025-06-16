CREATE DATABASE IF NOT EXISTS company_db;

CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    joining_date DATE
);

INSERT INTO employees (name, department, salary, joining_date) VALUES
('Alice Sharma', 'HR', 55000.00, '2021-01-15'),
('Bob Mehta', 'Engineering', 75000.50, '2020-07-23'),
('Charlie Desai', 'Marketing', 62000.00, '2019-11-30'),
('Diana Patel', 'Engineering', 80000.75, '2022-03-12'),
('Evan Khan', 'Finance', 67000.00, '2021-05-05');


SELECT * FROM EMPLOYEES;

-- Show names and departments of all employees
SELECT name,department FROM employees;

-- Find employees who work in the 'Engineering' department.
SELECT * FROM employees
WHERE department='Engineering';

-- Find employees who joined after January 1, 2021.
SELECT * FROM employees
WHERE joining_date>2021-1-1; 

-- List employees with salary greater than 70,000.
SELECT * FROM employees
WHERE salary>70000;

-- Find the total number of employees in each department.
SELECT department,COUNT(id) as Total_employees  FROM employees
GROUP BY department
order by Total_employees DESC;

-- Find the average salary in the company.
select ROUND(avg(salary),2) AS avg_salary from employees;

-- Find the highest salary in the 'Engineering' department.
SELECT MAX(salary) as Highest_salary FROM employees
WHERE department='Engineering';

-- List employees whose name starts with 'A'.
SELECT * FROM employees
WHERE substring(name,1,1)='A';

-- Show all employees sorted by salary in descending order.
SELECT * from employees
order by salary DESC;

-- Find the second highest salary in the table.
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 1;

-- Find departments having more than one employee.
SELECT department,COUNT(id) as counting FROM employees
group by department
HAVING counting>1;

-- Get the employee with the earliest joining date.
SELECT * FROM employees
WHERE joining_date=(SELECT MIN(joining_date) FROM employees);

-- Show the number of employees who joined in each year.
SELECT YEAR(joining_date) AS join_year, COUNT(*) AS employee_count
FROM employees
GROUP BY YEAR(joining_date)
ORDER BY join_year;

-- Increase salary of all employees in 'HR' by 10%.
UPDATE employees
SET salary = salary * 1.10
WHERE department = 'HR';


