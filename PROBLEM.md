# Data Engineering Home Assignment

## Objective

The purpose of this assignment is to evaluate your ability to work with data pipelines, perform data transformations, and optimize a data warehouse setup as well as to provide data analysis. You have been provided with a sample dataset and asked to perform a series of tasks to demonstrate your understanding of data engineering concepts.

## Problem

Our company has recently launched a new product and we are looking to analyze the sales data to understand its performance. Our sales team came up with a few questions that they would like to answer using the data:

- What are the top 5 products by total sales amount in the year 2023?
- What are the names of the top 5 customers by total sales amount in the year 2023?
- What is the average order value for each month in the year 2023?
- Which customer had the highest order volume in the month of October 2023?

### Setting Up Your Environment:

Create a new Snowflake account (free for 30 days) and set up a database named home_assignment.
Install dbt (data build tool) and configure it to connect to your Snowflake database.

- For this you will need to create a `profiles.yml` file in a folder in `~/.dbt`
- The content of this should take the following format

```yml
dbt_banxware_assignment:
  outputs:
    dev:
      type: SNOWFLAKE
      threads: 4
      account: <your_snowflake_account_details>
      database: <snowflake_database_name>
      user: <login-name>
      password: <yourpassword>
      schema: <your_snowflake_schema_name>
      warehouse: <compute_wh>
      role: <snowflake_role>
  target: dev
```

- Please change the values of the above parameters enclosed in `<>` to fit your snowflake system.

- To test if you have sucessfully established a connection to your snowflake cluster run the `dbt debug` command from the root of the `dbt_banxware_assignment` folder.

In the `dbt_banxware_assignment` folder you will find a dbt project where you will build the below requirements in the `models` folder.

## Relevant dbt commands

#### [dbt command reference](https://docs.getdbt.com/reference/dbt-commands):

- `dbt deps` pulls and installs project dependencies
- `dbt seed` loads `csv` files into data warehouse
- `dbt snapshot` executes "snapshot" jobs defined in a project
- `dbt run` executes the models in a project (add `--full-refresh` to force refresh incremental models)
- `dbt test` executes tests defined in a project
- `dbt docs generate` generates documentation for a project
- `dbt docs serve` starts local web server to view documentation (CLI version only)

### Resources:

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

### Data Ingestion:

You have been provided with 2 csv files under the `data` folder:

- sales.csv
- customers.csv

Both contain fictional data and are used for this assignment.

Using any data ingestion tool of your choice, create a process to ingest the `sales.csv` and `customer.csv` into your Snowflake database into a table named `raw_sales_data` and `raw_customer_data`.

### Hint:

[dbt seed](https://docs.getdbt.com/docs/build/seeds) might be able to make the process very easy!

### Data Transformation:

Use dbt to create a model that transforms `raw_sales_data` into a more structured format for analysis. Name this table `transformed_sales_data`.

Include the following transformations:

Extract year, month, and day from the `order_date` field.

Calculate the total sales amount for each order.

## Submission

- Document each step of your process, explaining your setup, transformations, and any decisions made during the assignment in a file named `DECISIONS.md`.
- Publish your project to a public GitHub repository and share the link with us by email.
- Incldue a `README.md` file with instructions on how to run your project.
- The queries to answer the questions should be included in the `queries` folder in separate `.sql` files.

## Evaluation Criteria

- Correctness: Does your solution correctly load, transform, and query the data?
- Efficiency: Are your SQL queries and data transformations optimized?
- Clarity: Is your code well-documented and easy to understand?
- Completion: Did you complete all parts of the assignment and provide all required files?
