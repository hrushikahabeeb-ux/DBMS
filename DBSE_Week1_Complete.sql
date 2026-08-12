/* =========================================================
   DATABASE SYSTEM ENGINEERING (DBSE)
   WEEK 1 - BOOKFLOW LIBRARY SYSTEM
   =========================================================

   Tasks:
   1. Create database named bookflow_db
   2. Create Books table with constraints
   3. Create Members table with constraints
   4. Insert sample data
   5. Verify constraints with failing tests

   ========================================================= */

-- ========== STEP 1: DATABASE SETUP ==========

-- Create the database
CREATE DATABASE IF NOT EXISTS bookflow_db;

-- Select the database
USE bookflow_db;


-- ========== STEP 2: CREATE BOOKS TABLE ==========

CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(13) NOT NULL UNIQUE,
    published_year INT,
    CONSTRAINT chk_published_year CHECK (published_year < 2027)
);

-- Verify table structure
DESCRIBE books;


-- ========== STEP 3: CREATE MEMBERS TABLE ==========

CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE
);

-- Verify table structure
DESCRIBE members;


-- ========== STEP 4: INSERT SAMPLE DATA ==========

-- Insert 3 books
INSERT INTO books (title, isbn, published_year) VALUES
('The Alchemist', '9780061122415', 1988),
('Clean Code', '9780132350884', 2008),
('Atomic Habits', '9780735211292', 2018);

-- Verify books inserted
SELECT * FROM books;

-- Insert 3 members
INSERT INTO members (full_name, email) VALUES
('Anil Kumar', 'anil.kumar@example.com'),
('Priya Sharma', 'priya.sharma@example.com'),
('Ravi Verma', 'ravi.verma@example.com');

-- Verify members inserted
SELECT * FROM members;


-- ========== STEP 5: CONSTRAINT VIOLATION TESTS ==========

-- TEST 1: Duplicate ISBN (UNIQUE violation)
-- This should FAIL - ISBN already exists
-- INSERT INTO books (title, isbn, published_year)
-- VALUES ('Fake Copy', '9780061122415', 2000);
-- ERROR: Duplicate entry '9780061122415' for key 'books.isbn'

-- TEST 2: NULL title (NOT NULL violation)
-- This should FAIL - title cannot be NULL
-- INSERT INTO books (title, isbn, published_year)
-- VALUES (NULL, '9999999999999', 2010);
-- ERROR: Column 'title' cannot be null

-- TEST 3: Future publication year (CHECK violation)
-- This should FAIL - year must be < 2027
-- INSERT INTO books (title, isbn, published_year)
-- VALUES ('Time Traveler', '8888888888888', 2030);
-- ERROR: Check constraint 'chk_published_year' is violated

-- TEST 4: Duplicate email (UNIQUE violation)
-- This should FAIL - email already exists
-- INSERT INTO members (full_name, email)
-- VALUES ('Anil Clone', 'anil.kumar@example.com');
-- ERROR: Duplicate entry 'anil.kumar@example.com' for key 'members.email'


-- ========== VERIFICATION QUERIES ==========

-- Show all books with constraints enforced
SELECT
    book_id,
    title,
    isbn,
    published_year
FROM books
ORDER BY book_id;

-- Show all members with email uniqueness enforced
SELECT
    member_id,
    full_name,
    email
FROM members
ORDER BY member_id;

-- Count total books and members
SELECT 'Total Books' AS metric, COUNT(*) AS count FROM books
UNION ALL
SELECT 'Total Members' AS metric, COUNT(*) AS count FROM members;


-- ========== SCHEMA SUMMARY ==========

/*
CONSTRAINTS IMPLEMENTED:

Table: books
- book_id: PRIMARY KEY (NOT NULL + UNIQUE, AUTO_INCREMENT)
- title: NOT NULL (must have a name)
- isbn: UNIQUE (no duplicate ISBNs)
- published_year: CHECK (< 2027, not in future)

Table: members
- member_id: PRIMARY KEY (NOT NULL + UNIQUE, AUTO_INCREMENT)
- full_name: NOT NULL (must have a name)
- email: NOT NULL + UNIQUE (one account per email)

DATA INTEGRITY:
✓ Every book has a unique ISBN
✓ Every book has a title
✓ No books with future dates
✓ Every member has a unique email
✓ All members have names
✓ No duplicate entries possible
*/
