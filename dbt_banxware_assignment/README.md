# Data Engineering Home Assignment  
## End-to-End Data Pipeline with Snowflake & dbt

---

## 📌 Project Overview

This project implements a complete end-to-end data pipeline using:

- **Snowflake** as the data warehouse
- **dbt (v1.9.4)** for transformations
- **Medallion Architecture (Bronze → Silver → Gold)**
- **Star Schema modeling in the final layer**
- **Custom generic tests**
- **Analytical queries answering business questions**

The objective is to ingest raw CSV data, transform it using dbt best practices, and build a dimensional model optimized for analytics.

---

# 🏗 Architecture Overview

This project follows a **Medallion Architecture**:

| Layer | dbt Folder | Purpose |
|-------|------------|----------|
| 🥉 Bronze | `staging/` | Raw ingestion & minimal cleaning |
| 🥈 Silver | `intermediate/` | Business logic & transformation |
| 🥇 Gold | `marts/` | Star schema (fact + dimension tables) |

---

# 📂 Project Structure

```text
dbt_banxware_assignment/
│
├── models/
│ ├── staging/
│ │ ├── raw_customer_data.sql
│ │ ├── raw_sales_data.sql
│ │ └── __staging_schema.yml
│ │
│ ├── intermediate/
│ │ ├── int_customer.sql
│ │ ├── int_orders.sql
│ │ ├── int_product.sql
│ │ ├── int_transformed_sales_data.sql
│ │ └── __intermediate_schema.yml
│ │
│ ├── marts/
│ │ ├── dim_customer.sql
│ │ ├── dim_product.sql
│ │ ├── dim_orders.sql
│ │ ├── dim_date.sql
│ │ ├── fct_transformed_sales_data.sql
│ │ ├── agg_completed_orders.sql
│ │ └── __marts_schema.yml
│ │
│ └── sources.yml
│
├── seeds/
│ ├── customers.csv
│ └── sales.csv
│
├── tests/
│ └── generic/
│ ├── accepted_range.sql
│ └── expression_is_true.sql
│
├── queries/
│ ├── AOV.sql
│ ├── customer_highest_order.sql
│ ├── top_5_customers.sql
│ └── top_5_product.sql
│
├── dbt_project.yml
├── requirements.txt
└── README.md
```

# 🥉 Bronze Layer (Staging)

Models:
- `raw_customer_data`
- `raw_sales_data`

Purpose:
- Load seed data into Snowflake
- Apply basic casting and cleanup
- Preserve raw structure

Data is loaded using:

```bash
dbt seed
```
# 🥈 Silver Layer (Intermediate)

Models:
- `int_customer`
- `int_product`
- `int_orders`
- `int_transformed_sales_data`

## Purpose

The Silver layer applies business logic and prepares clean, structured datasets for dimensional modeling.

### Key Transformations

- Standardization of column names and data types
- Removal of duplicates
- Logical separation of entities:
  - Customers
  - Products
  - Orders
- Extraction of:
  - `year`
  - `month`
  - `day` from `order_date`
- Calculation of total sales amount per order

This layer acts as the refined, analytics-ready foundation for the Gold layer.

---

# 🥇 Gold Layer (Marts – Star Schema)

The Gold layer implements a **Star Schema** optimized for analytical queries and reporting.

The design follows dimensional modeling best practices:

- One central **fact table**
- Multiple **dimension tables**
- Clear foreign key relationships
- Proper grain definition

---

## ⭐ Fact Table

### `fct_transformed_sales_data`

**Grain:**  
One row per order line.

### Contains:

- `customer_id` (FK)
- `product_id` (FK)
- `order_id` (FK)
- `date_key` (FK)
- `quantity`
- `price`
- `total_sales_amount`

This table stores all measurable metrics and connects to dimensions via business keys.

---

## 📐 Dimension Tables

### `dim_customer`
- Customer attributes
- One row per customer
- Primary key: `customer_id`

### `dim_product`
- Product attributes
- One row per product
- Primary key: `product_id`

### `dim_orders`
- Order-level information
- One row per order
- Primary key: `order_id`

### `dim_date`
- Date dimension derived from `order_date`
- Contains:
  - `year`
  - `month`
  - `day`
- Primary key: `date_key`

Each dimension:
- Enforces `unique` and `not_null` tests
- Is connected to the fact table using `relationships` tests

---

## 📊 Aggregated Mart

### `agg_completed_orders`

An aggregated reporting model built on top of the fact table.

**Grain:** One row per order.

Used for:
- Average Order Value (AOV)
- Revenue analysis
- Order-level reporting
- Monthly trends

---

# 🧪 Testing Strategy

Data quality is enforced across all layers.

## Built-in dbt Tests

- `not_null`
- `unique`
- `relationships`
- `accepted_values`

## Custom Generic Tests

Located in:
```
tests/generic/
```
- `accepted_range.sql`
- `expression_is_true.sql`

These ensure:

- Numeric values fall within expected ranges
- Business logic conditions are satisfied
- No invalid data propagates into the marts layer

Run all tests using:

```bash
dbt build
```
# ⚙️ Environment Setup & Running the Project

## 1️⃣ Create Virtual Environment

```bash
python -m venv dbt_env
```
Activate the environment:

```bash
dbt_env\Scripts\activate
```
## 2️⃣ Install Required Dependencies

Install the exact versions to match Snowflake Cloud dbt:

```bash
pip install -r requirements.txt
```
Important versions:

- `dbt-core==1.9.4`
- `dbt-snowflake==1.9.2`

## 3️⃣ Configure Snowflake Profile
Create the following file:

```bash
~/.dbt/profiles.yml
```
```yml
dbt_banxware_assignment:
  outputs:
    dev:
      type: snowflake
      account: <account>
      user: <user>
      password: <password>
      role: <role>
      database: home_assignment
      warehouse: <warehouse>
      schema: <schema>
      threads: 4
  target: dev
```
Test the connection:

```bash
dbt debug
```

## 4️⃣ Load Seed Data
```bash
dbt seed
```
This loads:
- `customers.csv`
- `sales.csv`

into Snowflake.

## 5️⃣ Build the Full Pipeline

```bash
dbt build
```

This command executes:
- Seeds
- Staging models
- Intermediate models
- Mart models
- All tests


# 📈 Running Analytical Queries

The analytical queries are located in:

```bash
queries/
```
They answer:

1. Top 5 products by total sales amount in 2023
2. Top 5 customers by total sales amount in 2023
3. Average Order Value per month in 2023
4. Customer with highest order volume in October 2023

### Execution Options

#### Option 1 — VSCode

Use the dbt Power User extension to execute queries locally.

#### Option 2 — Snowflake

Use the compiled SQL from:

```bash
target/compiled/
```

and execute it directly in Snowflake Worksheets.