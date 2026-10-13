# SQL JOIN Practice Guide

**Setup:** run `join_practice_dataset.sql` first. It creates and fills 6 tables.

## The dataset

| Table | Columns | Rows |
|---|---|---|
| `departments` | dept_id, dept_name, location | 5 |
| `employees` | emp_id, first_name, last_name, dept_id, manager_id, salary, hire_date | 10 |
| `customers` | customer_id, customer_name, city | 6 |
| `products` | product_id, product_name, category, price | 6 |
| `orders` | order_id, customer_id, order_date, status | 7 |
| `order_items` | item_id, order_id, product_id, quantity | 11 |

**Relationships**
- `employees.dept_id` → `departments.dept_id`
- `employees.manager_id` → `employees.emp_id` (self-reference)
- `orders.customer_id` → `customers.customer_id`
- `order_items.order_id` → `orders.order_id`
- `order_items.product_id` → `products.product_id`

**Deliberate edge cases** (so joins behave differently):
- Finance department has **no employees**
- Miguel Aquino has **no department** (`dept_id` is NULL)
- Maria Santos has **no manager** (`manager_id` is NULL)
- Rico Valdez and Tina Navarro (customers) have **no orders**
- Backpack (product) was **never ordered**

> Expected outputs below were produced by actually running each query (SQLite 3.45). Row order matches the `ORDER BY` in each problem, so sort yours the same way to compare.

---

## Problem 1: INNER JOIN — Employees and their departments

**Task:** Show each employee's full name (as `full_name`) and their department name. Only include employees who belong to a department. Order by `emp_id`.

<details>
<summary>Solution</summary>

```sql
SELECT e.first_name || ' ' || e.last_name AS full_name,
       d.dept_name
FROM employees e
INNER JOIN departments d
        ON e.dept_id = d.dept_id
ORDER BY e.emp_id;
```

</details>

**Expected output** (9 rows):

| full_name | dept_name |
|---|---|
| Maria Santos | Engineering |
| Jose Reyes | Engineering |
| Ana Cruz | Engineering |
| Carlo Garcia | Marketing |
| Liza Mendoza | Marketing |
| Ramon Dela Cruz | Sales |
| Grace Lim | Sales |
| Paolo Torres | Sales |
| Sofia Ramos | HR |

---

## Problem 2: LEFT JOIN — Keep unmatched rows

**Task:** Show **all** employees with their department name. If an employee has no department, display `Unassigned`. Columns: `full_name`, `department`. Order by `emp_id`.

<details>
<summary>Solution</summary>

```sql
SELECT e.first_name || ' ' || e.last_name AS full_name,
       COALESCE(d.dept_name, 'Unassigned') AS department
FROM employees e
LEFT JOIN departments d
       ON e.dept_id = d.dept_id
ORDER BY e.emp_id;
```

</details>

**Expected output** (10 rows):

| full_name | department |
|---|---|
| Maria Santos | Engineering |
| Jose Reyes | Engineering |
| Ana Cruz | Engineering |
| Carlo Garcia | Marketing |
| Liza Mendoza | Marketing |
| Ramon Dela Cruz | Sales |
| Grace Lim | Sales |
| Paolo Torres | Sales |
| Sofia Ramos | HR |
| Miguel Aquino | Unassigned |

---

## Problem 3: LEFT JOIN + IS NULL — Departments with no employees

**Task:** Find the departments that have no employees. Columns: `dept_name`, `location`.

<details>
<summary>Solution</summary>

```sql
SELECT d.dept_name,
       d.location
FROM departments d
LEFT JOIN employees e
       ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;
```

</details>

**Expected output** (1 row):

| dept_name | location |
|---|---|
| Finance | Manila |

---

## Problem 4: FULL OUTER JOIN — Everything from both sides

**Task:** Show every employee and every department, matched where possible. Include employees with no department AND departments with no employees. Columns: `first_name`, `dept_name`. Order by `dept_name`, then `first_name` (NULLs come first in SQLite).

<details>
<summary>Solution</summary>

```sql
SELECT e.first_name,
       d.dept_name
FROM employees e
FULL OUTER JOIN departments d
             ON e.dept_id = d.dept_id
ORDER BY d.dept_name, e.first_name;
```

</details>

**Expected output** (11 rows):

| first_name | dept_name |
|---|---|
| Miguel | NULL |
| Ana | Engineering |
| Jose | Engineering |
| Maria | Engineering |
| NULL | Finance |
| Sofia | HR |
| Carlo | Marketing |
| Liza | Marketing |
| Grace | Sales |
| Paolo | Sales |
| Ramon | Sales |

---

## Problem 5: SELF JOIN — Employee and their manager

**Task:** List each employee together with their manager's first name. Employees without a manager (the top boss) should show `No Manager`. Columns: `employee`, `manager`. Order by `emp_id`.

<details>
<summary>Solution</summary>

```sql
SELECT e.first_name AS employee,
       COALESCE(m.first_name, 'No Manager') AS manager
FROM employees e
LEFT JOIN employees m
       ON e.manager_id = m.emp_id
ORDER BY e.emp_id;
```

</details>

**Expected output** (10 rows):

| employee | manager |
|---|---|
| Maria | No Manager |
| Jose | Maria |
| Ana | Maria |
| Carlo | Maria |
| Liza | Carlo |
| Ramon | Maria |
| Grace | Ramon |
| Paolo | Ramon |
| Sofia | Maria |
| Miguel | Maria |

---

## Problem 6: JOIN + GROUP BY — Headcount and average salary per department

**Task:** For **every** department (even those with no employees), show `dept_name`, the number of employees as `emp_count`, and the average salary as `avg_salary` (use 0 if there are no employees). Order by `dept_name`.

<details>
<summary>Solution</summary>

```sql
SELECT d.dept_name,
       COUNT(e.emp_id)              AS emp_count,
       COALESCE(AVG(e.salary), 0)   AS avg_salary
FROM departments d
LEFT JOIN employees e
       ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_name;
```

</details>

**Expected output** (5 rows):

| dept_name | emp_count | avg_salary |
|---|---|---|
| Engineering | 3 | 77333.33 |
| Finance | 0 | 0 |
| HR | 1 | 60000 |
| Marketing | 2 | 56500 |
| Sales | 3 | 56666.67 |

---

## Problem 7: Multi-table JOIN — Order line details

**Task:** For all orders with status `Delivered`, show `customer_name`, `order_id`, `product_name`, `quantity`, and the line total as `line_total` (price × quantity). Order by `order_id`, then `product_name`.

<details>
<summary>Solution</summary>

```sql
SELECT c.customer_name,
       o.order_id,
       p.product_name,
       oi.quantity,
       p.price * oi.quantity AS line_total
FROM orders o
JOIN customers   c  ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id
WHERE o.status = 'Delivered'
ORDER BY o.order_id, p.product_name;
```

</details>

**Expected output** (8 rows):

| customer_name | order_id | product_name | quantity | line_total |
|---|---|---|---|---|
| Juan Dela Pena | 101 | Laptop | 1 | 800 |
| Juan Dela Pena | 101 | Mouse | 2 | 40 |
| Juan Dela Pena | 102 | Keyboard | 1 | 45 |
| Juan Dela Pena | 102 | Notebook | 10 | 50 |
| Elena Soriano | 105 | Keyboard | 1 | 45 |
| Elena Soriano | 105 | Mouse | 3 | 60 |
| Elena Soriano | 107 | Desk Lamp | 1 | 30 |
| Elena Soriano | 107 | Laptop | 2 | 1600 |

---

## Problem 8: Anti-join — Customers who never ordered

**Task:** Find customers who have never placed an order. Columns: `customer_name`, `city`.

<details>
<summary>Solution</summary>

```sql
SELECT c.customer_name,
       c.city
FROM customers c
LEFT JOIN orders o
       ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

</details>

**Expected output** (2 rows):

| customer_name | city |
|---|---|
| Rico Valdez | Manila |
| Tina Navarro | Davao |

---

## Problem 9: LEFT JOIN + SUM — Units sold per product

**Task:** Show every product with the total units sold as `total_units`. Products that were never ordered must show `0`. Order by `total_units` descending, then `product_name`.

<details>
<summary>Solution</summary>

```sql
SELECT p.product_name,
       COALESCE(SUM(oi.quantity), 0) AS total_units
FROM products p
LEFT JOIN order_items oi
       ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units DESC, p.product_name;
```

</details>

**Expected output** (6 rows):

| product_name | total_units |
|---|---|
| Notebook | 30 |
| Mouse | 5 |
| Laptop | 4 |
| Desk Lamp | 3 |
| Keyboard | 2 |
| Backpack | 0 |

---

## Problem 10: 4-table JOIN + aggregate — Revenue per customer

**Task:** Calculate each customer's total spend as `total_spent` (sum of price × quantity), **excluding** `Cancelled` orders. Only show customers who have spend. Order by `total_spent` descending.

<details>
<summary>Solution</summary>

```sql
SELECT c.customer_name,
       SUM(p.price * oi.quantity) AS total_spent
FROM customers c
JOIN orders      o  ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id
WHERE o.status <> 'Cancelled'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;
```

</details>

**Expected output** (3 rows):

| customer_name | total_spent |
|---|---|
| Elena Soriano | 1735 |
| Juan Dela Pena | 935 |
| Karla Bautista | 160 |

---

## Bonus: CROSS JOIN — All combinations

**Task:** Pair every customer from `Cebu City` with every `Electronics` product. Columns: `customer_name`, `product_name`. Order by `customer_name`, then `product_name`.

<details>
<summary>Solution</summary>

```sql
SELECT c.customer_name,
       p.product_name
FROM customers c
CROSS JOIN products p
WHERE c.city = 'Cebu City'
  AND p.category = 'Electronics'
ORDER BY c.customer_name, p.product_name;
```

</details>

**Expected output** (6 rows):

| customer_name | product_name |
|---|---|
| Elena Soriano | Keyboard |
| Elena Soriano | Laptop |
| Elena Soriano | Mouse |
| Juan Dela Pena | Keyboard |
| Juan Dela Pena | Laptop |
| Juan Dela Pena | Mouse |

---

## Compatibility notes

- **String concatenation:** `||` works in SQLite and PostgreSQL. In MySQL use `CONCAT(e.first_name, ' ', e.last_name)`.
- **FULL OUTER JOIN (Problem 4):** not supported in MySQL. Use this instead:

```sql
SELECT e.first_name, d.dept_name
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.first_name, d.dept_name
FROM employees e RIGHT JOIN departments d ON e.dept_id = d.dept_id;
```

- **NULL ordering (Problem 4):** SQLite and MySQL put NULLs first in ascending order; PostgreSQL puts them last. Add `NULLS FIRST` in PostgreSQL to match.
- **Average formatting (Problem 6):** some databases show `AVG` with more decimals (e.g. `77333.3333`). The values are the same.
