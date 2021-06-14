# ETL-IrvineCompanyApts

A database was put together that could be used by Irvine Company Apartments (ICA) to analyze the length of time that available apartment units remain on their site, how the list, or starting price, compares to the rental price in relation to the time the listing remains available, and how their pricing compares to average rental prices for the city where the apartment complex is, the cost of living for that city, demographics information, and whether those factors seem to affect the length of time available and rental price.


Questions for Analysis:
How long are apartments staying on the market by city?
By apartment complex?
By apartment type?
How does the pricing affect how long an apartment stays on the market?
How does a city’s average rent price compare to our pricing?
Does the cost of living for an area affect the time an apartment stays on the market?
What about the city’s median age, median income, population?


Source URLs

Base Site - Irvine Company Apartments: https://www.irvinecompanyapartments.com/
Demographics Info: https://www.california-demographics.com/
Cost of Living Index: https://www.numbeo.com/cost-of-living/rankings.jsp
Average Rent by City: https://www.apartmentlist.com/research/category/data-rent-estimates


Database:

PostgreSQL Database: ETL_IrvineCoApts_db


Cost of Living Index:

This is a relative indicator that was calculated from the weighted averages of consumer good products such as groceries, transportation, etc. The index excludes accommodation costs, such as rents and mortgage. However, the website provides another cost of living index that includes the accommodation costs. The numerical value is a quantity measured in percentage to the weighted average of New York City. For example, an index of 80 means the cost of living is 20% less than New York City, and 120 means the cost of living is 20% more.

Extract: The website Cost of Living Index was scraped for the cost of living index of CA. The website provides data throughout the world. North American region and the year 2021 is selected for building the HTML. Then, the HTML is scraped using Pandas is used to read the table from the html, and SQLAlchemy was used to update the database.

Transform: In the scraped table, the city entries included countries, and states where applicable. The entry is split and only the city and state names are extracted, and only the cities within California are kept and added to the database.

Load: Using SQLAlchemy, the cities are first compared in the database with the cities obtained from the Cost of Living Index website. If the city exists in the database, only the cost of living index value of the city is updated, and the other entries are not altered. If the city does not exist in the database, a new entry is created and cost of living index value is set. The rest of the entries are set to zero.


Demographics:

Extract: The California Demographics website was scraped for the population, the median income for each city, and the median age of people who live there. The HTML was scraped using Pandas. Splinter was used to visit the browser and read the table from HTML, then go into each city page to pull more information for income and age, and SQLAlchemy was used to update the database.

Transformation: Pandas used the information from HTML to create a table to store each city name, the population, the median income, and the median age in each city. It then adds all the information into the same table and drop any rows that do not contain the information that is needed.

Load: The demographics info will be updated monthly.  We query the database to check to see if the city exists , and add the new city if it is not on there. Then add the population, median income, median age into the existing city.  If the city exists, the population, median income and median age are updated in the record.


Average Rent:

Extract:  A website called Apartment List was found that had calculated average rents based on the number of bedrooms in apartments for different locations.  The website contained different CSVs of the average rent data at different scopes such as by city or state or county.  The URL to the CSV for the rent values calculated per city in the United States was scraped from the site using splinter and SQLAlchemy was used to update the database.  The CSV’s were not available to extract from the main source code page of the website.  In order to scrape off the specific CSV, it needed to be found in the dropdown where it was located and a download button needed to be clicked in order for the source code path to appear.  Regular expressions were used to find the URL in the code.

Transform: The scraped CSV was converted into a Pandas DataFrame in order to further transform the data.  The City Name column, formatted as a city along with its associated state, the Bedroom Size column, which was the number of bedrooms per apartment, and the Avg Rent column were pulled into their own DataFrame.  The Avg Rent was called in such a way that it would grab the most recent avg rent value if the calculated averages had been updated.  The City Name column was split into its City and State to be added as their own columns so only the cities from CA could be pulled and separated from the rest.  Data containing null values were removed, the original City Name column was dropped, columns were renamed and rearranged, and some data in the table needed to be reformatted after the split.  A separate DataFrame was made by grouping the data by the City Name to assist in loading the data into the database.

Load:  The grouped City Name list was compared to the cities table in the database.  If the city already existed in the database and had its own city id associated with it, then no new city record needs to be added to the database.  If the city did not already exist in the database, a new record was created for that city assigning it a city id in the city table within the database while also assigning 0 values for the cost of living index, population, median income and median age were initialized to 0.  The avg_rent table was populated from the DataFrame with the rent data for each city, the city names, bedroom sizes, and average rents were made into their own lists.  The cities table was queried for city in order to grab their associated city id to be inserted into the avg rents table along with each city’s different bedroom sizes and their average rent values. This process will be run monthly to capture the latest average rent data.


Available Apartments:

Extract: The Irvine Company Apartments website was scraped for apartment complex information, and available units at each complex.  The HTML was scraped using splinter and SQLalchemy was used to update the database.

Transform: The data for each complex included the complex name, the complex address, and the complex URL.  Because the complex table contains a city_id from the cities table, the complex city is stripped from the complex URL.   The complex city is used to access the cities table.

The data for each available apartment included the unit name, which identifies the building and apartment number, the floor plan name, the apartment type (number of bedrooms, etc), the square footage, the starting price for the associated floor plan name, the current price for which the unit is being offered, the date the listing was posted, the date the apartment will be available for occupation, and the current date stamp.

	Data Transformation:

City name and area name are stripped from complex URL
If area name is “San Diego”, and city name is not “Carlsbad”,  city name is set to “San Diego”
Apartment complexes with no postings are dropped
Floor plans with no available apartments are dropped
Start price and current price are stripped of symbols and converted to integer
Non-numeric prices are set to 0
Start date is set to current date
If available date is set to “Today”, set it to the current date and set vacant to TRUE
If available date is in the past, set vacant to TRUE


Load: This script should be run daily.  The logic will:
Check to see if the city that the complex is in exists in the database, and add to the cities table if it does not
Check to see if the apartment complex exists in the database, and add to the complex table if it does not
Check to see if the available unit exists in the database, add the row if it does not, and update the curr_price, curr_date, and vacant attributes if it does


Ongoing analysis:  The tables were not joined during the load phase.  During analysis, all tables were joined to the apartment table via the complex_id and the city id.  That would facilitate comparisons between apartment prices and a city’s average data.

A script should be written and run every day, after the Available Apartments process has been run, to pull all rows from the apartments table where the curr_date is a past date.  This indicates that the apartment is no longer on the available list and should be moved to historical data for analysis.
For any rows in the apartments table where the curr_date is past, insert/update into history table
Delete all rows from the apartments table where the curr_date is past


Running ETL:

Create PostgreSQL database named ETL_IrvineCoApts_db
Run db/create_ICA_tbls.sql to create database tables
Run populationbycity.ipynb to add demographics data to the cities table
Run scrape_cost-of-living.ipynb to add cost of living data to the cities table
Run csv_scrape.ipynb to add average rent data to the cities table
Run scrape_ICA.ipynb to add data to complex and apartments tables


Collaborated with Kate Spitzer, Tolga Caglar, Luan Dinh


![image](https://user-images.githubusercontent.com/65049133/121832128-30b44c00-cc7e-11eb-94d2-8cd571b06828.png)

