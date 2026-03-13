---

# Project Structure
# Olist E-commerce SQL Analysis

This project analyzes the performance of a real Brazilian e-commerce marketplace using SQL.  
The goal is to understand how the business performs across orders, products, customers, and logistics, and to extract insights that could help improve growth and operational efficiency.

The analysis covers core business areas including revenue trends, customer behavior, product performance, retention, and delivery reliability.

The project is built entirely in SQL using PostgreSQL and is structured as a set of analytical queries that answer common business questions in an e-commerce environment.


---

# Dataset

The analysis uses the **Olist E-commerce dataset**, a public dataset that contains detailed order, product, payment, customer, and delivery information.

The dataset includes:

- ~100k orders
- ~300k order items
- ~90k customers
- product catalog and category translations
- delivery and logistics timestamps

The dataset represents a real online marketplace and allows analysis across the full e-commerce lifecycle:

**customer → order → product → delivery**

Source:  
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce


---

# Project Structure
# Olist E-commerce SQL Analysis

This project analyzes the performance of a real Brazilian e-commerce marketplace using SQL.  
The goal is to understand how the business performs across orders, products, customers, and logistics, and to extract insights that could help improve growth and operational efficiency.

The analysis covers core business areas including revenue trends, customer behavior, product performance, retention, and delivery reliability.

The project is built entirely in SQL using PostgreSQL and is structured as a set of analytical queries that answer common business questions in an e-commerce environment.


---

# Dataset

The analysis uses the **Olist E-commerce dataset**, a public dataset that contains detailed order, product, payment, customer, and delivery information.

The dataset includes:

- ~100k orders
- ~300k order items
- ~90k customers
- product catalog and category translations
- delivery and logistics timestamps

The dataset represents a real online marketplace and allows analysis across the full e-commerce lifecycle:

**customer → order → product → delivery**

Source:  
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce


---

# Project Structure

olist-analytics/
│
├── sql/
│ ├── 01_data_preparation.sql
│ ├── 02_monthly_kpis.sql
│ ├── 03_revenue_by_category.sql
│ ├── 04_category_share.sql
│ ├── 05_category_trend.sql
│ ├── 06_product_analysis.sql
│ ├── 07_customer_analysis.sql
│ ├── 08_cohort_analysis.sql
│ └── 09_delivery_analysis.sql
│
├── docs/
│ └── project_notes.md
│
├── notebooks/
│ └── exploratory_analysis.ipynb
│
└── README.md



Each SQL file focuses on a specific business topic and can be executed independently.


---

# Key Business Questions

The project answers several practical questions that an e-commerce company would typically ask.

### Revenue and Growth
- How are revenue and order volume evolving over time?
- What is the average order value?
- Which product categories generate the most revenue?

### Product and Basket Analysis
- How does basket size influence order value?
- Do customers tend to buy multiple items per order?

### Customer Behavior
- How many customers are repeat buyers?
- What share of revenue comes from returning customers?
- Do customers return after their first purchase?

### Customer Retention
- What does cohort retention look like month-by-month?
- How quickly does customer activity decline after acquisition?

### Logistics Performance
- How long does delivery take on average?
- What percentage of deliveries arrive late?
- How severe are delivery delays?


---

# Methods and Techniques

The analysis uses a combination of SQL techniques commonly applied in real analytics workflows.

Key techniques used in this project include:

- multi-table joins
- window functions
- cohort analysis
- cumulative revenue calculations
- segmentation using CASE statements
- time-based aggregation
- delivery delay analysis

Examples include:

- **Pareto analysis (80/20 rule)** to identify categories driving most revenue  
- **basket size analysis** to understand order composition  
- **cohort retention analysis** to measure customer return behavior  
- **delivery performance analysis** to evaluate logistics reliability


---

# Key Insights

Some notable observations from the analysis:

**Revenue concentration**

A relatively small number of product categories generate the majority of marketplace revenue, confirming a typical Pareto distribution in e-commerce.

**Basket behavior**

Most orders contain a single item, but orders with multiple items tend to generate significantly higher revenue.

**Customer retention**

The majority of customers purchase only once. Repeat customers represent a much smaller share of the user base but generate higher average revenue.

**Delivery performance**

Average delivery time is around **12 days**, with roughly **8% of deliveries arriving later than estimated**.

These patterns highlight common challenges for online marketplaces: improving customer retention and optimizing logistics performance.


---

# Tools Used

- **SQL (PostgreSQL)**
- **DBeaver**
- **Git & GitHub**
- Public dataset from **Kaggle**

The focus of the project is SQL-based analytics and business insight generation.


---

# About the Author

I am transitioning into a **Data Analyst role** with a focus on business analytics and performance analysis.

My background includes operational and leadership experience in manufacturing, where I worked with KPIs, performance monitoring, and process improvement. This project reflects my approach to analytics: focusing not only on queries, but on answering meaningful business questions.

I am currently developing projects in:

- SQL analytics
- business intelligence
- product and customer analytics
- data-driven decision making


---

# Next Steps

Possible future extensions of this project include:

- building a BI dashboard (Tableau / Looker Studio)
- visualizing cohort retention
- deeper product-level analysis
- logistics performance modeling
