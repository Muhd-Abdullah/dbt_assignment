# DECISIONS.md  
## Architectural & Implementation Decisions

This document outlines the key technical and architectural decisions taken while implementing the dbt data pipeline.

---

# 1️⃣ dbt Version Alignment

The project uses:

- `dbt-core==1.9.4`
- `dbt-snowflake==1.9.2`

These versions match the Snowflake Cloud dbt environment to ensure:

- Compatibility
- Consistent macro behavior
- No version-related compilation conflicts

---

# 2️⃣ Data Ingestion via dbt Seed

Data ingestion is handled using `dbt seed`, as suggested in the assignment hint.

Reasons:

- Simplifies ingestion process
- Eliminates need for external ingestion tools
- Ensures reproducibility
- Integrates naturally into dbt workflow (`dbt build`)

This allows the pipeline to remain fully dbt-native.

---

# 3️⃣ Sales Table Modeling Decision

Although the raw `sales.csv` contains unique `order_id`s, it was modeled as a **sales fact table** rather than an orders table.

Reasoning:

- Fact tables should represent measurable business events.
- Orders were modeled separately as a dimension (`dim_orders`) for scalability.
- This enables:
  - Flexible aggregation
  - Proper dimensional modeling
  - Better extensibility in real-world scenarios

---

# 4️⃣ No Metadata Columns in Bronze Layer

Metadata fields such as:

- `ingestion_at`
- `source`

were intentionally not added to the Bronze layer.

Reasoning:

- Data is ingested via `dbt seed`
- Full refresh occurs during each run
- No external ingestion pipeline exists
- Metadata tracking would not provide meaningful value in this context

In a production system with streaming or batch ingestion, metadata columns would be required.

---

# 5️⃣ Deduplication Strategy

Since no reliable `updated_at` or ingestion timestamp exists, deduplication was implemented based on:

- Record completeness
- Logical consistency
- Business key uniqueness

This ensures deterministic cleaning despite lack of temporal metadata.

---

# 6️⃣ Surrogate Key Strategy

Surrogate keys were **not created** for:

- Customers
- Orders
- Products

Reasoning:

- Business keys are already stable and unique
- For this assignment, surrogate keys would not add value
- Keeps implementation simpler and clearer

However, an example surrogate key was created in the sales model to demonstrate understanding of the concept.

In a production environment, surrogate keys would typically be required for:

- Slowly changing dimensions
- Late-arriving data
- Warehouse abstraction

---

# 7️⃣ Date Dimension Instead of Direct Order Date Usage

Instead of repeatedly deriving year/month/day from `order_date`, a proper `dim_date` table was created.

Benefits:

- Scalable design
- Reusable date attributes
- Simplifies time-based analysis
- Aligns with dimensional modeling best practices

This improves analytical flexibility and long-term maintainability.

---

# 8️⃣ Aggregated Mart Design

An additional aggregated model:

`agg_completed_orders`

was created on top of the fact table.

Reasoning:

- Fact table grain: `order_id + product_id`
- Aggregated mart grain: `order_id`

This aggregated table:

- Simplifies AOV calculations
- Improves query readability
- Optimizes analytical queries
- Avoids repeated aggregation logic

Three of the required business queries use this aggregated model.

---

# 9️⃣ Query Organization

All business queries are stored inside the:

`queries/` folder

This follows the assignment requirement.

---

# 🔟 Analytics Folder Usage

The `analytics/` folder contains:

- Simple exploratory SQL
- Data quality exploration queries
- Initial investigation queries

It was used to better understand data before modeling.

---

# 1️⃣1️⃣ No Incremental Models

Incremental logic was intentionally not implemented.

Reasoning:

- Dataset is small
- No ingestion timestamp exists
- No real incremental loading requirement
- Full refresh is sufficient

In production systems with large datasets, incremental models would be critical.

---

# 1️⃣2️⃣ Order Status Not Modeled as SCD Type 2

`order_status` was not treated as Slowly Changing Dimension (SCD Type 2).

Reasoning:

- Each order appears only once
- No historical status tracking exists
- No update logic present

If order status changes over time in a real-world system, SCD Type 2 would be required.

---

# 1️⃣3️⃣ Business Logic: Only Completed Orders Used in Analytics

All analytical queries (Top Products, Top Customers, AOV, Highest Order Volume) were designed to consider only completed orders.

Reasoning:

1. Pending or cancelled orders do not represent realized revenue.
2. Including non-completed orders would distort:
    - Revenue calculations
    - Average Order Value (AOV)
    - Customer ranking
    - Product performance metrics

3. Revenue should reflect finalized transactions only.

Implementation Approach:

- The agg_completed_orders model filters for order_status = 'completed'.
- Business queries are executed against this aggregated mart (or against filtered fact data where applicable).
- This ensures:
    - Consistent metric definitions
    - Centralized business logic
    - No need to repeatedly filter order status in downstream queries
    - Improved query performance through early filtering

In a production system, this logic would be:

- Explicitly documented in a data contract or semantic layer
- Aligned with finance and business stakeholders to ensure revenue definitions are standardized

# Queries, and Results `Only Completed Orders`

## 1) Top 5 Products by Total Sales Amount in 2023

```sql  
select
    p.product_name,
    round(sum(f.total_sales_amount), 2) as total_sales
from HOME_ASSIGNMENT.GOLD.fct_transformed_sales_data f
join HOME_ASSIGNMENT.GOLD.dim_product p
  on f.product_id = p.product_id
join HOME_ASSIGNMENT.GOLD.dim_date d
  on f.date_day = d.date_day
join HOME_ASSIGNMENT.GOLD.dim_orders o
  on f.order_id = o.order_id
where d.year = 2023
  and o.order_status = 'Completed'
group by p.product_name
order by total_sales desc  
limit 5
```
| Rank | PRODUCT_NAME | TOTAL_SALES |
|------|--------------|------------:|
| 1    | Product_3003 | 3207.92 |
| 2    | Product_3001 | 2557.35 |
| 3    | Product_3002 | 2332.59 |
| 4    | Product_3004 | 1997.90 |
| 5    | Product_3009 | 1469.18 |


## 2) Top 5 Customers by Total Sales Amount in 2023

```sql
select
  customer_name,
  ROUND(sum(order_total_sales_amount),2) as total_sales
from HOME_ASSIGNMENT.GOLD.agg_completed_orders
where year = 2023
group by customer_name
order by total_sales desc
limit 5
```
| Rank | CUSTOMER_NAME | TOTAL_SALES |
|------|---------------|------------:|
| 1    | j7lXV1P2Mo | 1141.54 |
| 2    | jRiNoSMORL | 957.64 |
| 3    | g8f5j8VUxl | 944.44 |
| 4    | KwrIays2uS | 907.50 |
| 5    | miTbp86xy6 | 757.60 |


## 3) Customer with Highest Order Volume in October 2023

```sql
select
  customer_name,
  count(distinct order_id) as order_volume
from HOME_ASSIGNMENT.GOLD.agg_completed_orders
where year = 2023
  and month = 10
group by customer_name
order by order_volume desc
limit 1
```

| CUSTOMER_NAME | ORDER_VOLUME |
|---------------|-------------:|
| g8f5j8VUxl    | 2 |

## 4) Average Order Value by Month in 2023

```sql
select
  year,
  month,
  Round(avg(order_total_sales_amount),2) as avg_order_value
from HOME_ASSIGNMENT.GOLD.agg_completed_orders
where year = 2023
group by year, month
order by year, month
limit 500
```

| YEAR | MONTH | AVG_ORDER_VALUE |
|-----:|------:|----------------:|
| 2023 | 1     | 251.23 |
| 2023 | 2     | 252.85 |
| 2023 | 3     | 205.26 |
| 2023 | 4     | 154.58 |
| 2023 | 5     | 276.14 |
| 2023 | 6     | 321.08 |
| 2023 | 7     | 260.68 |
| 2023 | 8     | 306.29 |
| 2023 | 9     | 273.85 |
| 2023 | 10    | 126.48 |
| 2023 | 11    | 174.51 |
| 2023 | 12    | 274.38 |



# 📌 Summary

The project was designed to:

- Follow Medallion architecture
- Implement a proper Star Schema
- Enforce data quality via tests
- Maintain scalability where meaningful
- Avoid over-engineering where unnecessary
- Balance realism with assignment scope

The overall design prioritizes clarity, scalability, and analytical performance while remaining aligned with the assignment constraints.
