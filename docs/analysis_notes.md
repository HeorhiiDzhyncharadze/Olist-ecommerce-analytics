# Olist Analytics – Analysis Notes

This document summarizes the analytical approach used in the Olist SQL analysis project.

The goal of the analysis was to explore the performance of a real e-commerce marketplace and identify patterns in revenue generation, customer behavior, product performance, and delivery operations.

---

# Analytical Approach

The analysis was structured around several key business areas:

1. Revenue and order performance  
2. Product category contribution  
3. Customer purchasing behavior  
4. Customer retention  
5. Delivery performance and logistics efficiency

The work was performed using SQL queries executed in PostgreSQL.

---

# Data Preparation

Before performing the analysis, several preparation steps were required:

- validating the structure of the dataset
- checking table grain and key relationships
- converting timestamp fields for time-based analysis
- ensuring consistent joins across orders, customers, and order items

The main tables used in the analysis were:

- orders
- order_items
- customers
- products
- product_category_translation

---

# Analytical Workflow

The SQL analysis was organized into several logical stages.

### Revenue and KPI analysis

Initial queries focused on understanding basic marketplace metrics:

- order volume over time
- revenue trends
- average order value

### Product performance

Product categories were analyzed to understand:

- which categories generate the most revenue
- how revenue is distributed across categories
- whether revenue follows a Pareto distribution

### Basket analysis

Orders were analyzed at the order level to evaluate:

- the number of items per order
- how basket size affects order revenue

### Customer behavior

Customer-level metrics were calculated to identify:

- repeat customers
- average revenue per customer
- differences between one-time and repeat buyers

### Cohort retention

A cohort analysis was performed to measure customer retention over time.

Customers were grouped by the month of their first purchase, and their activity was tracked in subsequent months.

This helped evaluate how quickly customers stop purchasing after their initial order.

### Delivery performance

Delivery metrics were analyzed to understand logistics performance, including:

- average delivery time
- percentage of late deliveries
- severity of delivery delays

---

# Observations During Analysis

Several characteristics of the dataset influenced the analysis:

- many customers only make a single purchase
- a small number of product categories drive a large share of revenue
- delivery times vary significantly across orders

These observations helped shape the analytical focus of the project.

---

# Future Extensions

The analysis could be expanded with additional work such as:

- building a BI dashboard for visualization
- performing deeper product-level analysis
- analyzing seller performance
- modeling customer lifetime value
