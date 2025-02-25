# Retail-Shop-RFM-Analysis

## Project introduction & business target
In this project, I want to demonstrate a well-known RFM model for analyzing the customer segementation, identify customer value which give marketers better picture of how they can engage customers with different strategies.

## What is RFM
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

## Which companies and industries use the RFM model

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
 - Microsoft SQL Server for data analysis, view details [Here](https://github.com/Alexleehj/Retail-Shop-RFM-Analysis/blob/main/Online%20retail%20shop%20RFM%20Analysis.sql)
 - Power BI for data visualization [Here](https://github.com/Alexleehj/Retail-Shop-RFM-Analysis/blob/main/Retail%20RFM%20Analysis.pbix)



## Dashboard Snapshoot
![Business Overview](https://github.com/Alexleehj/Retail-Shop-RFM-Analysis/raw/main/Retail%20shop%20business%20overview.png)
![RFM Segement](https://github.com/Alexleehj/Retail-Shop-RFM-Analysis/raw/main/RFM%20segements.png)



