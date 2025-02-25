# Retail-Shop-RFM-Analysis

## Project introduction & business target
In this project, I want to introduce a well-known RFM model for analyzing the customer segmentation, identify customer value which give marketers better picture of how they can engage customers with different marketing strategies.

## What is RFM?
The RFM model describes the value of a customer through three indicators: recent transaction behavior, overall transaction frequency, and transaction amount. Based on these three indicators, 8 types of customer value are divided:

 - Important value customers
 - Important recall customers
 - Important deep cultivation customers
 - Important retention customers
 - Potential customers
 - New customers
 - General maintenance customers
 - Lost customers

After distinguishing these customer types, companies can focus its main energy and resources on important value customers, important recall customers, and important deep-cultivation customers.

## Which companies and industries use the RFM model?

RFM is commonly used in industries such as consumer goods, cosmetics, small appliances, video stores, supermarkets, gas stations, travel insurance, transportation, express delivery, fast food restaurants, KTV, mobile phones, credit cards, and securities companies.

The data source usually comes from the company's CRM-related order data, in below I will use the data of retail stores as an example to conduct a specific analysis. 

## Dataset
 - Data Source: https://archive.ics.uci.edu/dataset/502/online+retail+ii
 - Online Retail dataset contains all the transactions occurring for a UK-based
 - Time: Between 01/12/2009 and 09/12/2011. 
 - Product: unique all-occasion gift-ware, many customers of the company are wholesalers.

|  Variables  | Remark | 
|-------------|---------------------------------------------------------------------------------|
| InvoiceNo   | Unique number for each transaction. If it starts with C, canceled transaction.|
| StockCode   | Product code. Unique number for each product.| 
| Description | Product name| 
| Quantity    | Product quantity. It expresses how many of the products in the invoices are sold.| 
| InvoiceDate | Transaction date and time.|
| UnitPrice   | Product price per unit in sterling (Â£)| 
| CustomerID  | Unique customer number| 
| Country     | Country name. The country where the customer lives.| 


## Analysis tools
 - Microsoft SQL Server for ETL jobs, view details [Here](https://github.com/Alexleehj/Retail-Shop-RFM-Analysis/blob/main/Online%20retail%20shop%20RFM%20Analysis.sql)
 - Power BI for data visualization [Here](https://github.com/Alexleehj/Retail-Shop-RFM-Analysis/blob/main/Retail%20RFM%20Analysis.pbix)
 - Note: Power BI supports basic data processing, but for large datasets, it's better to use SQL Server or other ETL tools for intensive processing. This lets Power BI focus on its strength—visualizations—ensuring better performance and faster analysis.



## Dashboard snapshoot
![Business Overview](https://github.com/Alexleehj/Retail-Shop-RFM-Analysis/raw/main/Retail%20shop%20business%20overview.png)
![RFM Segment](https://github.com/Alexleehj/Retail-Shop-RFM-Analysis/blob/main/RFM%20segments.png)


## RFM segmentation details and steps
### 1. Calculate customer basic Recency, Frequency, Monetary original values via sql
Since the data source is much earlier than the author's development time, we use the most recent time in the data source as the baseline to calculate recency. once compeletd, you will see sample data as follow:
    
| CustomerID | Recency | Frequency | Monetary      |
|------------|---------|-----------|---------------|
| 18102      | 0       | 145       | 580987.04     |
| 14646      | 1       | 152       | 528510.78     |
| 14156      | 9       | 156       | 313409.02     |
| 14911      | 1       | 398       | 291420.81     |
| 17450      | 8       | 51        | 244784.25     |

### 2. Binning method
 - Recency: Bin in ascending order (the fewer days, the higher the score).
 - Frequency and Monetary: Bin in descending order (the larger the value, the higher the score).
 - Use NTILE(5) to divide each indicator into 5 groups and generate a score of 1-5.

| CustomerID | Recency | Frequency | Monetary      | R_Score | F_Score | M_Score |
|------------|---------|-----------|---------------|---------|---------|---------|
| 18102      | 0       | 145       | 580987.04     | 5       | 5       | 5       |
| 14646      | 1       | 152       | 528510.78     | 5       | 5       | 5       |
| 14156      | 9       | 156       | 313409.02     | 5       | 5       | 5       |
| 14911      | 1       | 398       | 291420.81     | 5       | 5       | 5       |
| 17450      | 8       | 51        | 244784.25     | 5       | 5       | 5       |


### 3. Customer segmentation logic

Based on RFM analysis, customers are segmented into the following categories:

| Customer Type            | Business Logic                                                   |
|--------------------------|-------------------------------------------------------------------|
| **Top Customers**        | Top customers: R_Score = 5, and both F_Score and M_Score are >= 4. |
| **At-Risk Customers**    | At-risk customers: R_Score <= 2.                                  |
| **Dormant Customers**    | Dormant customers: R_Score <= 3 and F_Score <= 2.                 |
| **High-Potential**       | High-potential customers: R_Score = 5, and either F_Score or M_Score is 3 or 4. |
| **Mid-Value Customers**  | Mid-value customers: R_Score = 1 or 2, and either F_Score or M_Score is 2 or 3. |
| **New Customers**        | New customers: F_Score = 1 and R_Score = 5.                      |
| **Need Attention Customers** | Catch-all category: Customers who do not fit the above conditions, needing special attention & seperate analysis (at this moment, detailed analysis for this group is not included yet). |

As a result, we can see the numbers and proportion for this company customers' Segmentation as follow：
| Segment                  | Customer # | Customer % |
|--------------------------|------------|------------|
| At-Risk Customers        | 2353       | 40%        |
| Need Attention Customers | 2070       | 35%        |
| Top Customers            | 726        | 12%        |
| Dormant Customers        | 422        | 7%         |
| High-Potential           | 310        | 5%         |


## Take away and marketing approach
### 1. Take-aways
  - Compared to the previous year (2010 vs 2011, January-November, due to incomplete records for December 2011), the company’s business performance remained relatively stable with a 1% increase in revenue.
  - The average order value per customer increased by 7% (from £350 to £376). However, there was a 2% decrease in the number of customers and a 6% decline in the number of orders. Further investigation into order patterns (e.g., repeat orders, cross-product purchases) is needed, and will be included in the next analysis release.
 - The customer base shows a relatively small proportion of loyal customers (12%) and low potential customer pipelines (5%), with no new customers acquired. In contrast, at-risk customers, dormant customers, and those requiring attention make up approximately 83% of the total customer base.





