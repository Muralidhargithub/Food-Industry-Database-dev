
# Food Industry DB System

## Project Overview

This project involves the design and implementation of a database management system for a company that owns several restaurants in different states across the US. The system includes various operations such as establishing new restaurants, updating menus, hiring employees, placing orders, generating financial statements, and running reports for restaurant managers.

## Tables

- **Cuisine Types:** Contains cuisine type ID and names (American, Indian, Italian, BBQ, Ethiopian).
- **Restaurants:** Each restaurant has an ID, name, address, city, state, zip, and cuisine type.
- **Waiters:** Each waiter has an ID, name, and restaurant ID.
- **Menu Items:** Food items served in each restaurant, categorized by cuisine type.
- **Restaurant Inventory:** Stock information for each restaurant's food items.
- **Customers:** Customer information including ID, name, address, email, and credit card number.
- **Orders:** Order details including order ID, restaurant ID, customer ID, date, menu item ID, waiter ID, amount paid, and tip.
- **Reviews:** Reviews for restaurants, including review ID, restaurant ID, reviewer email, stars given, and review text.
- **Recommendations:** Recommendations for customers based on review data.

## Operations

### Month 1

1. **Week 1:**
   - Designed the initial database schema.
   - Created tables for Cuisine Types and Restaurants.
   - Implemented procedures to add cuisine types and restaurants.

2. **Week 2:**
   - Created the Waiters table.
   - Implemented procedures to hire waiters and show list of waiters for a restaurant.
   - Generated reports for total tips by waiters and tips by state.

3. **Week 3:**
   - Developed Menu Items and Restaurant Inventory tables.
   - Implemented procedures to create menu items and add them to restaurant inventory.

### Month 2

1. **Week 4:**
   - Implemented procedures to update menu item inventory.
   - Generated reports to show totals of each menu item by cuisine type.

2. **Week 5:**
   - Created Customers and Orders tables.
   - Implemented procedures to add customers and place orders.

3. **Week 6:**
   - Implemented procedures to list all orders at a given restaurant on a specific date.
   - Generated reports showing the top 3 restaurants in each state based on total amount paid.

4. **Week 7:**
   - Created Reviews and Recommendations tables.
   - Implemented procedures to add reviews and generate recommendations for customers.

### Month 3

1. **Week 8:**
   - Implemented the Buy Or Beware procedure to list top-rated and worst-rated restaurants based on reviews.

2. **Week 9:**
   - Implemented procedures to list recommendations for customers, including the name of the customer, recommended restaurant, cuisine type, and average stars.

3. **Week 10:**
   - Developed helper functions such as FIND_CUISINE_TYPE_ID, FIND_RESTAURANT_ID, FIND_MENU_ITEM_ID, FIND_CUSTOMER_ID, and FIND_WAITER_ID to facilitate various operations.

4. **Week 11:**
   - Debugged and tested all procedures and functions.
   - Conducted integration testing with the consolidated system.

5. **Week 12:**
   - Prepared for the final demo by creating a driver program to simulate a given scenario.
   - Finalized documentation and comments for all PL/SQL code.

6. **Week 13:**
   - Conducted the final demo, presenting individual procedures and the integrated system.
   - Submitted the final project, ensuring compliance with all requirements.

## Important Notes

- **No GUI:** All operations are implemented as PL/SQL procedures and functions.
- **Input/Output:** Input parameters are required for procedures and functions, with output being the results of database operations or reports.
- **Sequences:** Primary keys are automatically generated using sequences.
- **Debugging:** Extensively used print statements and exceptions for debugging.
- **Integration:** Code was tested individually and then integrated into the group Oracle account for consistency.

## Helper Functions

- **FIND_CUISINE_TYPE_ID:** Returns the cuisine type ID given a cuisine name.
- **FIND_RESTAURANT_ID:** Returns the restaurant ID given a restaurant name.
- **FIND_MENU_ITEM_ID:** Returns the menu item ID given an item name.
- **FIND_CUSTOMER_ID:** Returns the customer ID given a customer name.
- **FIND_WAITER_ID:** Returns the waiter ID given a waiter name.

## Submission

All deliverables were uploaded to the project repository, with each text file containing SQL and PL/SQL commands, comments, and drop table commands to ensure clean execution from start to finish.

```

Feel free to customize any part of the README as needed!
