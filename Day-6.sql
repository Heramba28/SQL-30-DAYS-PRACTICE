CREATE DATABASE IF NOT EXISTS company_hierarchy;



CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    manager_id INT
);

INSERT INTO employees (emp_id, name, manager_id) VALUES
(1, 'Alice', NULL),     
(2, 'Bob', 1),           
(3, 'Charlie', 1),      
(4, 'David', 2),         
(5, 'Emma', 2),          
(6, 'Frank', 3);      

SELECT * FROM employees;

-- 1 Show each employee’s name along with their manager’s name.
SELECT e1.name as manager ,e2.name as employee FROM employees e1
INNER JOIN employees e2
ON e1.emp_id=e2.manager_id;

-- 2 Find employees who do not manage anyone.
SELECT * FROM employees e1
LEFT JOIN employees e2
ON e1.emp_id=e2.manager_id
WHERE e2.manager_id is NULL;

-- 3 List all managers who manage more than 1 employee.
SELECT e1.name as manager , count(*) as total FROM employees e1
INNER JOIN employees e2
ON e1.emp_id=e2.manager_id
GROUP BY e1.name
HAVING total>1;

-- 4 . Show the names of employees who report to the same manager.
SELECT 
    e1.name AS employee_1,
    e2.name AS employee_2,
    e1.manager_id
FROM employees e1
JOIN employees e2
  ON e1.manager_id = e2.manager_id
  AND e1.emp_id < e2.emp_id;
  
-- 5 Find employees who report indirectly to Alice
SELECT e3.name AS employee, e2.name AS mid_manager, e1.name AS top_manager
FROM employees e1
JOIN employees e2 ON e2.manager_id = e1.emp_id
JOIN employees e3 ON e3.manager_id = e2.emp_id
WHERE e1.name = 'Alice';

-- 6 Show employee–manager pairs where both names start with the same letter
SELECT e2.name AS employee, e1.name AS manager
FROM employees e1
JOIN employees e2 ON e1.emp_id = e2.manager_id
WHERE LEFT(e1.name, 1) = LEFT(e2.name, 1);

-- 7 Count how many employees each manager has
SELECT e1.name AS manager, COUNT(e2.emp_id) AS team_size
FROM employees e1
LEFT JOIN employees e2 ON e1.emp_id = e2.manager_id
GROUP BY e1.name;

-- 8 Show employees whose manager’s name is shorter than theirs
SELECT e2.name AS employee, e1.name AS manager
FROM employees e1
JOIN employees e2 ON e1.emp_id = e2.manager_id
WHERE LENGTH(e1.name) < LENGTH(e2.name);

-- 9 Show all employees who are top-level managers (no manager themselves, but they manage others)
SELECT DISTINCT e1.name AS top_manager
FROM employees e1
LEFT JOIN employees e2 ON e1.emp_id = e2.manager_id
WHERE e1.manager_id IS NULL AND e2.emp_id IS NOT NULL;

-- 10 Display chain like Employee → Manager → Manager's Manager
SELECT e1.name AS employee, e2.name AS manager, e3.name AS managers_manager
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.emp_id
JOIN employees e3 ON e2.manager_id = e3.emp_id;
   

