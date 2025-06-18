CREATE DATABASE IF NOT EXISTS library_db;

CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    author VARCHAR(100),
    genre VARCHAR(50),
    price DECIMAL(6, 2),
    published_year INT
);

CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    join_date DATE
);

CREATE TABLE borrowed_books (
    borrow_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    book_id INT,
    borrow_date DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Books
INSERT INTO books (title, author, genre, price, published_year) VALUES
('Data Structures', 'Mark Allen', 'Computer Science', 450.00, 2018),
('Algorithms Unlocked', 'Thomas Cormen', 'Computer Science', 550.00, 2020),
('Pride and Prejudice', 'Jane Austen', 'Fiction', 300.00, 1813),
('Clean Code', 'Robert Martin', 'Programming', 600.00, 2008),
('The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction', 350.00, 1925);

-- Members
INSERT INTO members (name, city, join_date) VALUES
('Rohit Jain', 'Delhi', '2022-01-10'),
('Meera Singh', 'Mumbai', '2021-06-18'),
('Aarav Patel', 'Ahmedabad', '2023-03-02'),
('Kavya Nair', 'Chennai', '2022-11-25');

-- Borrowed Books
INSERT INTO borrowed_books (member_id, book_id, borrow_date, return_date) VALUES
(1, 1, '2023-01-10', '2023-01-25'),
(2, 3, '2023-02-05', '2023-02-20'),
(1, 2, '2023-03-01', '2023-03-15'),
(3, 4, '2023-03-10', NULL),
(4, 5, '2023-04-01', '2023-04-20'),
(2, 1, '2023-05-01', NULL);


SELECT * FROM members;
SELECT * FROM books; 
SELECT * FROM borrowed_books; 

-- 1.Find the name of the member who borrowed the most books.
SELECT m.name,COUNT(bb.book_id) AS count FROM members m
INNER JOIN borrowed_books bb
ON m.member_id=bb.member_id
GROUP BY m.name 
HAVING count=(SELECT COUNT(bb.book_id) AS count FROM members m
INNER JOIN borrowed_books bb
ON m.member_id=bb.member_id
GROUP BY m.name
ORDER BY count desc
LIMIT 1
 );
 
-- 2 List all books that have never been borrowed.
SELECT * FROM books b
LEFT JOIN borrowed_books bb 
ON b.book_id=bb.book_id
WHERE bb.borrow_id IS NULL;

-- 3 Find the most expensive book that has been borrowed.
SELECT b.title FROM books b
INNER JOIN borrowed_books bb 
ON b.book_id=bb.book_id
WHERE price=(SELECT MAX(price) FROM books b
INNER JOIN borrowed_books bb 
ON b.book_id=bb.book_id);

-- 4 Find the members who have borrowed books in the ‘Fiction’ genre.
SELECT * FROM books b
INNER JOIN borrowed_books bb 
ON b.book_id=bb.book_id
WHERE b.genre='Fiction';

-- 5 Display books that were published before 2008 and have been borrowed at least once.
SELECT DISTINCT b.*
FROM books b
INNER JOIN borrowed_books bb 
ON b.book_id = bb.book_id
WHERE b.published_year < 2008;

-- 6 Find the name and city of members who borrowed books but haven’t returned them yet.
SELECT m.name,m.city FROM members m
INNER JOIN borrowed_books bb
ON m.member_id=bb.member_id
WHERE return_date IS NULL;

-- 7 Get the total number of books borrowed by each member (even if 0).
SELECT m.name,COUNT(bb.book_id) FROM members m
LEFT JOIN borrowed_books bb
ON m.member_id=bb.member_id
GROUP BY m.name;

-- 8 Find the average price of books borrowed by each member.
SELECT m.name ,ROUND(AVG(b.price)) FROM members m
INNER JOIN borrowed_books bb
ON m.member_id=bb.member_id
INNER JOIN books b
ON bb.book_id=b.book_id
GROUP BY m.name;

-- 9 List all members who have borrowed books written by ‘Jane Austen’.
SELECT m.name FROM members m
INNER JOIN borrowed_books bb
ON m.member_id=bb.member_id
INNER JOIN books b
ON bb.book_id=b.book_id
WHERE b.author='Jane Austen';

-- 10 Display members who have never borrowed any book.
SELECT * FROM members m
LEFT JOIN borrowed_books bb
ON m.member_id=bb.member_id
WHERE book_id is NULL;
