{% docs __overview__ %}
# E-Commerce Analytics Pipeline

This dbt project transforms raw Brazilian e-commerce data from Olist into analytics-ready datasets using a modular staging → dimension → fact → mart architecture on Snowflake.

## Data Sources
- **Orders**: ~100K orders from 2016-2018
- **Customers**: ~99K unique customers across 27 Brazilian states
- **Products**: ~33K products across 70+ categories
- **Sellers**: ~3K active sellers
- **Reviews**: Customer review scores and comments
- **Payments**: Payment methods and installment data

## Key Analyses
- **Seller Performance**: Revenue, review scores, and delivery reliability per seller
- **Delivery Analysis**: Actual vs estimated delivery times and impact on customer satisfaction

{% enddocs %}
