CREATE DATABASE IF NOT EXISTS movie_rental;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100),
    signup_date DATE
);

CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50),
    release_year INT,
    rating FLOAT
);

CREATE TABLE rentals (
    rental_id INT PRIMARY KEY,
    customer_id INT,
    movie_id INT,
    rental_date DATE,
    return_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

-- Sample Data
INSERT INTO customers VALUES 
(1, 'Amit Singh', 'Delhi', '2022-03-10'),
(2, 'Priya Mehra', 'Mumbai', '2023-01-22'),
(3, 'Ravi Verma', 'Chennai', '2021-11-18'),
(4, 'Sara Ali', 'Bangalore', '2022-07-05');

INSERT INTO movies VALUES 
(101, 'Inception', 'Sci-Fi', 2010, 8.8),
(102, 'Dangal', 'Drama', 2016, 8.4),
(103, 'Avengers', 'Action', 2012, 8.0),
(104, '3 Idiots', 'Comedy', 2009, 8.4),
(105, 'Parasite', 'Thriller', 2019, 8.6),
(106, 'Interstellar', 'Sci-Fi', 2014, 8.6);

INSERT INTO rentals VALUES 
(1001, 1, 101, '2023-01-15', '2023-01-17'),
(1002, 2, 102, '2023-02-10', '2023-02-15'),
(1003, 1, 103, '2023-02-25', NULL),
(1004, 3, 104, '2023-03-01', '2023-03-05'),
(1005, 4, 106, '2023-03-10', NULL),
(1006, 1, 106, '2023-03-20', '2023-03-25');

SELECT * FROM customers;
SELECT * FROM movies;
SELECT * FROM rentals;

-- 1.Which movie has been rented the most?
SELECT title,count(*) as total FROM movies m
INNER JOIN rentals r
ON m.movie_id=r.movie_id
GROUP BY title
ORDER BY total DESC
LIMIT 1;

-- 2.Find the top 2 customers who rented the highest number of movies.
SELECT c.name as name ,count(*) as total FROM customers c 
INNER JOIN rentals r 
ON c.customer_id=r.customer_id
GROUP BY name 
ORDER BY total DESC 
LIMIT 2;

-- 3.Show customers who rented at least one 'Sci-Fi' movie. 
SELECT * FROM customers c 
INNER JOIN rentals r 
ON c.customer_id=r.customer_id
INNER JOIN movies m 
ON r.movie_id=m.movie_id
WHERE genre='Sci-Fi';

-- 4. List movies that have never been rented
SELECT * FROM movies m
LEFT JOIN rentals r
ON m.movie_id=r.movie_id
WHERE r.rental_id IS NULL;

-- 5.Show average rating of movies rented by each customer.
SELECT c.name,avg(m.rating) FROM customers c 
INNER JOIN rentals r 
ON c.customer_id=r.customer_id
INNER JOIN movies m 
ON r.movie_id=m.movie_id
GROUP by c.name;

-- 6 Get the number of rentals each customer made per genre
SELECT c.name ,m.genre,count(*) FROM customers c 
INNER JOIN rentals r 
ON c.customer_id=r.customer_id
INNER JOIN movies m 
ON r.movie_id=m.movie_id
GROUP BY c.name,m.genre;

-- 7 Find the highest-rated movie rented by each customer.
SELECT name, title, rating
FROM (
    SELECT c.name, m.title, m.rating,
           RANK() OVER (PARTITION BY c.customer_id ORDER BY m.rating DESC) AS rnk
    FROM customers c
    JOIN rentals r ON c.customer_id = r.customer_id
    JOIN movies m ON r.movie_id = m.movie_id
) ranked_movies
WHERE rnk = 1;

-- 8 Most recent movie rented by each customer using window function. 
SELECT name, title, rating, rental_date
FROM (
    SELECT c.name, m.title, m.rating, r.rental_date,
           RANK() OVER (PARTITION BY c.customer_id ORDER BY r.rental_date DESC) AS rnk
    FROM customers c
    JOIN rentals r ON c.customer_id = r.customer_id
    JOIN movies m ON r.movie_id = m.movie_id
) ranked_movies
WHERE rnk = 1;

-- 9 Customers who have pending returns (return_date IS NULL)? 
SELECT * FROM customers c 
INNER JOIN rentals r 
ON c.customer_id=r.customer_id
INNER JOIN movies m 
ON r.movie_id=m.movie_id
where r.return_date is NULL;

-- 10  Using a CASE WHEN, show number of rentals in 2023 split by: Sci-Fi, Action, and Others.
SELECT 
  COUNT(CASE WHEN m.genre = 'Sci-Fi' THEN 1 END) AS sci_fi_rentals,
  COUNT(CASE WHEN m.genre = 'Action' THEN 1 END) AS action_rentals,
  COUNT(CASE WHEN m.genre NOT IN ('Sci-Fi', 'Action') THEN 1 END) AS other_rentals
FROM rentals r
JOIN movies m ON r.movie_id = m.movie_id
WHERE YEAR(r.rental_date) = 2023;
