-- ============================================================
-- SQL JOIN PRACTICE DATASET
-- Works in SQLite / PostgreSQL / MySQL (see notes in the guide)
-- ============================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- ---------- departments ----------
CREATE TABLE departments (
    dept_id   INTEGER PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location  VARCHAR(50)
);

INSERT INTO departments (dept_id, dept_name, location) VALUES
(1, 'Engineering', 'Cebu City'),
(2, 'Marketing',   'Manila'),
(3, 'Sales',       'Cebu City'),
(4, 'HR',          'Davao'),
(5, 'Finance',     'Manila');   -- Finance has NO employees

-- ---------- employees ----------
CREATE TABLE employees (
    emp_id     INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    dept_id    INTEGER,          -- NULL = not assigned to a department
    manager_id INTEGER,          -- refers to emp_id of the manager
    salary     INTEGER,
    hire_date  DATE,
    FOREIGN KEY (dept_id)    REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

INSERT INTO employees (emp_id, first_name, last_name, dept_id, manager_id, salary, hire_date) VALUES
(1,  'Maria',  'Santos',   1, NULL, 90000, '2018-03-15'),  -- top boss
(2,  'Jose',   'Reyes',    1, 1,    70000, '2019-06-01'),
(3,  'Ana',    'Cruz',     1, 1,    72000, '2020-01-20'),
(4,  'Carlo',  'Garcia',   2, 1,    65000, '2019-09-10'),
(5,  'Liza',   'Mendoza',  2, 4,    48000, '2021-02-14'),
(6,  'Ramon',  'Dela Cruz',3, 1,    68000, '2018-11-05'),
(7,  'Grace',  'Lim',      3, 6,    50000, '2022-04-18'),
(8,  'Paolo',  'Torres',   3, 6,    52000, '2021-08-23'),
(9,  'Sofia',  'Ramos',    4, 1,    60000, '2020-07-07'),
(10, 'Miguel', 'Aquino',   NULL, 1, 45000, '2023-01-09');  -- no department yet

-- ---------- customers ----------
CREATE TABLE customers (
    customer_id   INTEGER PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL,
    city          VARCHAR(50)
);

INSERT INTO customers (customer_id, customer_name, city) VALUES
(1, 'Juan Dela Pena', 'Cebu City'),
(2, 'Karla Bautista', 'Manila'),
(3, 'Dennis Uy',      'Davao'),
(4, 'Elena Soriano',  'Cebu City'),
(5, 'Rico Valdez',    'Manila'),     -- has NO orders
(6, 'Tina Navarro',   'Davao');      -- has NO orders

-- ---------- products ----------
CREATE TABLE products (
    product_id   INTEGER PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    category     VARCHAR(30),
    price        INTEGER
);

INSERT INTO products (product_id, product_name, category, price) VALUES
(1, 'Laptop',      'Electronics', 800),
(2, 'Mouse',       'Electronics', 20),
(3, 'Keyboard',    'Electronics', 45),
(4, 'Desk Lamp',   'Home',        30),
(5, 'Notebook',    'Stationery',  5),
(6, 'Backpack',    'Accessories', 60);   -- never ordered

-- ---------- orders ----------
CREATE TABLE orders (
    order_id    INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date  DATE,
    status      VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
(101, 1, '2025-01-10', 'Delivered'),
(102, 1, '2025-02-15', 'Delivered'),
(103, 2, '2025-02-20', 'Shipped'),
(104, 3, '2025-03-05', 'Cancelled'),
(105, 4, '2025-03-12', 'Delivered'),
(106, 2, '2025-04-01', 'Pending'),
(107, 4, '2025-04-18', 'Delivered');

-- ---------- order_items ----------
CREATE TABLE order_items (
    item_id    INTEGER PRIMARY KEY,
    order_id   INTEGER,
    product_id INTEGER,
    quantity   INTEGER,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES
(1,  101, 1, 1),
(2,  101, 2, 2),
(3,  102, 3, 1),
(4,  102, 5, 10),
(5,  103, 4, 2),
(6,  104, 1, 1),
(7,  105, 2, 3),
(8,  105, 3, 1),
(9,  106, 5, 20),
(10, 107, 1, 2),
(11, 107, 4, 1);
