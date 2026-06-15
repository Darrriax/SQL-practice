-- DDL and DML
-- Working with the whole table (DDL)
CREATE TABLE persons (
    id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NULL,
    birth_date DATE NULL,
    CONSTRAINT pk_persons PRIMARY KEY (id)
)

ALTER TABLE persons
ADD phone VARCHAR(15) NULL

ALTER TABLE persons
DROP COLUMN phone

ALTER TABLE persons
ALTER COLUMN name VARCHAR(100) NOT NULL

DROP TABLE persons

-- ________________________________________________________________________-
-- Working with data inside the table (DML)
INSERT INTO persons (id, name, surname, email, phone, birth_date)
VALUES (10, 'Daria', 'Yakovenko', 'test@gmail.com', '0999393992', '2004-03-10')

INSERT INTO persons (id, name, surname, email, phone, birth_date)
SELECT 
    id, 
    first_name,
    'Unknown',
    'Unknown',
    NULL,
    NULL
FROM customers


UPDATE customers
SET score = 0
WHERE score IS NULL


DELETE FROM persons
-- Total execution time: 00:00:00.042

TRUNCATE TABLE persons
-- Total execution time: 00:00:00.017


DELETE FROM persons
WHERE id > 1