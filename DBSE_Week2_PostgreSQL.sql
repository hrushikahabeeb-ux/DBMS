
   ========================================================= */

-- ========== STEP 1: CREATE DATABASE ==========

CREATE DATABASE IF NOT EXISTS bookflow_db;

\c bookflow_db


-- ========== STEP 2: CREATE BOOKS TABLE ==========

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    published_year INT CHECK (published_year < 2027)
);

-- Verify table created
\d books


-- ========== STEP 3: CREATE MEMBERS TABLE ==========

CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Verify table created
\d members


-- ========== STEP 4: INSERT INITIAL DATA ==========

-- Insert Books
INSERT INTO books (title, isbn, published_year) VALUES
('The Great Gatsby', '9780743273565', 1925),
('To Kill a Mockingbird', '9780061120084', 1960),
('1984', '9780451524935', 1949);

-- Verify books
SELECT * FROM books;

-- Insert Members
INSERT INTO members (member_id, full_name, email) VALUES
(101, 'John Smith', 'john.smith@email.com'),
(102, 'Emma Wilson', 'emma.wilson@email.com'),
(103, 'Michael Brown', 'michael.brown@email.com');

-- Verify members
SELECT * FROM members;


-- ========== STEP 5: CREATE LOANS TABLE (FOREIGN KEYS) ==========

CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,
    member_id INT,
    book_id INT,
    loan_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Verify table created
\d loans

-- View foreign key constraints
SELECT
    constraint_name,
    table_name,
    column_name
FROM information_schema.key_column_usage
WHERE table_name = 'loans';


-- ========== STEP 6: INSERT LOAN DATA ==========

INSERT INTO loans (loan_id, member_id, book_id, loan_date) VALUES
(1, 101, 1, '2025-01-05'),
(2, 102, 2, '2025-01-08'),
(3, 103, 3, '2025-01-10'),
(4, 101, 2, '2025-02-01'),
(5, 102, 1, '2025-02-05'),
(6, 103, 2, '2025-02-12'),
(7, 101, 3, '2025-03-01'),
(8, 102, 3, '2025-03-07'),
(9, 103, 1, '2025-03-15'),
(10, 101, 1, '2025-04-01');

-- Verify loans
SELECT * FROM loans;


-- ========== TASK 1: CATALOG SEARCH (JOIN QUERY) ==========

-- Query: Show Member Name and Book Title they borrowed
SELECT
    m.full_name AS member_name,
    b.title AS book_title,
    l.loan_date AS loan_date
FROM loans l
INNER JOIN members m ON l.member_id = m.member_id
INNER JOIN books b ON l.book_id = b.book_id
ORDER BY l.loan_date DESC;




-- ========== TASK 2: COLLECTION STATS (GROUP BY QUERY) ==========

-- Query: Total books published in each year
SELECT
    published_year,
    COUNT(book_id) AS total_books
FROM books
GROUP BY published_year
ORDER BY published_year;




-- ========== STEP 7: CREATE DONATION_HISTORY TABLE ==========

CREATE TABLE donation_history (
    donation_id SERIAL PRIMARY KEY,
    book_id INT,
    donor_name VARCHAR(100),
    donation_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Verify table created
\d donation_history


-- ========== TASK 3: TRANSACTION (ATOMICITY) ==========

-- Add a new book and log donation atomically
BEGIN TRANSACTION;

INSERT INTO books (title, isbn, published_year)
VALUES ('Animal Farm', '9780451526342', 1945);

INSERT INTO donation_history (book_id, donor_name, donation_date)
VALUES (
    (SELECT MAX(book_id) FROM books),
    'Raj Kumar',
    CURRENT_DATE
);

COMMIT;



-- Verify transaction was successful
SELECT * FROM books WHERE title = 'Animal Farm';
SELECT * FROM donation_history;


-- ========== TASK 4: INDEX ON ISBN (SEARCH SPEED) ==========

-- Create index on isbn column
CREATE INDEX idx_books_isbn ON books(isbn);

-- Verify index was created
\d books

-- List all indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'books';

-- Fast search using ISBN
SELECT * FROM books WHERE isbn = '9780451524935';

-- Explain query plan (shows index usage)
EXPLAIN SELECT * FROM books WHERE isbn = '9780451524935';

-- Full explain with analysis
EXPLAIN ANALYZE SELECT * FROM books WHERE isbn = '9780451524935';




-- ========== ADDITIONAL USEFUL QUERIES ==========

-- Query: Books borrowed by each member (with count)
SELECT
    m.full_name AS member_name,
    COUNT(l.loan_id) AS books_borrowed,
    STRING_AGG(b.title, ', ' ORDER BY b.title) AS book_titles
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
LEFT JOIN books b ON l.book_id = b.book_id
GROUP BY m.member_id, m.full_name
ORDER BY books_borrowed DESC;

-- Query: Most frequently borrowed books
SELECT
    b.title AS book_title,
    COUNT(l.loan_id) AS times_borrowed
FROM books b
INNER JOIN loans l ON b.book_id = l.book_id
GROUP BY b.book_id, b.title
ORDER BY times_borrowed DESC;

-- Query: Members who borrowed on specific date
SELECT
    m.full_name,
    b.title,
    l.loan_date
FROM loans l
INNER JOIN members m ON l.member_id = m.member_id
INNER JOIN books b ON l.book_id = b.book_id
WHERE l.loan_date = '2025-01-05';

-- Query: Books never borrowed
SELECT
    book_id,
    title,
    isbn
FROM books
WHERE book_id NOT IN (SELECT DISTINCT book_id FROM loans);

-- Query: Member activity summary
SELECT
    m.member_id,
    m.full_name,
    COUNT(l.loan_id) AS total_loans,
    MAX(l.loan_date) AS latest_loan
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.full_name;

-- Query: Books by publication decade
SELECT
    (published_year / 10 * 10)::text || 's' AS decade,
    COUNT(*) AS book_count
FROM books
GROUP BY (published_year / 10 * 10)
ORDER BY (published_year / 10 * 10);


-- ========== VIEW ALL DATA ==========

-- Display all tables
SELECT '=== BOOKS ===' AS table_name;
SELECT * FROM books ORDER BY book_id;

SELECT '=== MEMBERS ===' AS table_name;
SELECT * FROM members ORDER BY member_id;

SELECT '=== LOANS ===' AS table_name;
SELECT * FROM loans ORDER BY loan_id;

SELECT '=== DONATION_HISTORY ===' AS table_name;
SELECT * FROM donation_history ORDER BY donation_id;


-- ========== USEFUL POSTGRESQL META-COMMANDS ==========

-- List all tables
\dt

-- List all tables with details
\dt+

-- Describe table (show columns)
\d books
\d members
\d loans
\d donation_history

-- Show column details
\d+ books

-- List all indexes
\di

-- List all indexes for specific table
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'books';

-- Show table size
SELECT pg_size_pretty(pg_total_relation_size('books')) AS size;
SELECT pg_size_pretty(pg_total_relation_size('members')) AS size;

-- Show all constraints
SELECT
    constraint_name,
    constraint_type,
    table_name
FROM information_schema.table_constraints
WHERE table_name IN ('books', 'members', 'loans', 'donation_history')
ORDER BY table_name;

-- List databases
\l

-- Connect to different database
\c different_database

-- Exit PostgreSQL
\q


