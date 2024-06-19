
-- Enable Server output
SET SERVEROUTPUT ON SIZE 1000000;

-- Drop All Tables
DROP TABLE CUSTOMER_ORDER;
DROP TABLE RECOMMENDATION;
DROP TABLE INVENTORY;
DROP TABLE WAITER;
DROP TABLE REVIEW;
DROP TABLE MENU_ITEM;
DROP TABLE RESTAURANT;
DROP TABLE CUSTOMER;
DROP TABLE CUISINE;
-- Drop end

-- Here are all the tables that are need for our project 
-- Import start
CREATE TABLE cuisine (
  cuisineId INT PRIMARY KEY,
  cuisineName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE menu_item (
  menuItemId INT PRIMARY KEY,
  cuisineId INT,
  menuItemName VARCHAR(50) NOT NULL,
  menuItemPrice NUMBER(10, 2) DEFAULT 0,
  CONSTRAINT fkCuisine FOREIGN KEY (cuisineId) REFERENCES cuisine(cuisineId),
  CONSTRAINT uqMenuItem UNIQUE (cuisineId, menuItemName)
);

CREATE TABLE customer (
  customerId INT PRIMARY KEY,
  customerName VARCHAR(50) NOT NULL,
  customerEmail VARCHAR(50) NOT NULL,
  customerStreetAddress VARCHAR(100) NOT NULL,
  customerCity VARCHAR(50) NOT NULL,
  customerState VARCHAR(50) NOT NULL,
  customerZip INT NOT NULL,
  customerCreditCardNumber VARCHAR(16) NOT NULL,
  CONSTRAINT custUnique UNIQUE (customerEmail)
);

CREATE TABLE restaurant (
  restaurantId INT PRIMARY KEY,
  cuisineId INT,
  restaurantName VARCHAR(50) NOT NULL,
  restaurantStreetAddress VARCHAR(100) NOT NULL,
  restaurantCity VARCHAR(50) NOT NULL,
  restaurantState VARCHAR(50) NOT NULL,
  restaurantZip INT NOT NULL,
  CONSTRAINT fkResCuisine FOREIGN KEY (cuisineId) REFERENCES cuisine(cuisineId)
);

CREATE TABLE inventory (
  inventoryId INT PRIMARY KEY,
  restaurantId INT,
  menuItemId INT,
  quantity INT DEFAULT 0,
  CONSTRAINT fkMenuItem FOREIGN KEY (menuItemId) REFERENCES menu_item(menuItemId),
  CONSTRAINT fkRestaurant FOREIGN KEY (restaurantId) REFERENCES restaurant(restaurantId),
  CONSTRAINT uqInventory UNIQUE (menuItemId, restaurantId)
);

CREATE TABLE review (
  reviewId INT PRIMARY KEY,
  restaurantId INT,
  reviewerEmail VARCHAR(50) NOT NULL,
  reviewerStarsGiven INT,
  reviewText VARCHAR(255) NOT NULL,
  CONSTRAINT fkReviewRes FOREIGN KEY (restaurantId) REFERENCES restaurant(restaurantId)
);

CREATE TABLE waiter (
  waiterId INT PRIMARY KEY,
  restaurantId INT,
  waiterName VARCHAR(50) NOT NULL,
  CONSTRAINT fkWaiterRes FOREIGN KEY (restaurantId) REFERENCES restaurant(restaurantId),
  CONSTRAINT uqWaiter UNIQUE (restaurantId, waiterName)
);

CREATE TABLE recommendation (
  recommendationId INT PRIMARY KEY,
  customerId INT,
  restaurantId INT,
  recommendationAt DATE,
  CONSTRAINT fkRecommCus FOREIGN KEY (customerId) REFERENCES customer(customerId),
  CONSTRAINT fkRecommRes FOREIGN KEY (restaurantId) REFERENCES restaurant(restaurantId)
);

CREATE TABLE customer_order (
  orderId INT PRIMARY KEY,
  customerId INT,
  restaurantId INT,
  menuItemId INT,
  waiterId INT,
  quantity INT,
  orderAmountPaid NUMBER(10, 2) DEFAULT 0,
  orderTips NUMBER(10, 2) DEFAULT 0,
  orderAt DATE,
  CONSTRAINT fkCusOrCus FOREIGN KEY (customerId) REFERENCES customer(customerId),
  CONSTRAINT fkCusOrRest FOREIGN KEY (restaurantId) REFERENCES restaurant(restaurantId),
  CONSTRAINT fkCusOrMenItm FOREIGN KEY (menuItemId) REFERENCES menu_item(menuItemId),
  CONSTRAINT fkCusOrWaiter FOREIGN KEY (waiterId) REFERENCES waiter(waiterId)
);
-- Table import END

-- Drop sequences if they already exist
DROP SEQUENCE cuisineTypeSeq;
DROP SEQUENCE menuItemSeq;
DROP SEQUENCE restaurantSeq;
DROP SEQUENCE waiterSeq;
DROP SEQUENCE inventorySeq;
DROP SEQUENCE customerSeq;
DROP SEQUENCE customerOrderSeq;
DROP SEQUENCE reviewSeq;
DROP SEQUENCE RecommendationSeq;
-- Drop END

-- Generate sequences for tables
CREATE SEQUENCE cuisineTypeSeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE restaurantSeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE waiterSeq START WITH 1 INCREMENT BY 1; 
CREATE SEQUENCE menuItemSeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE inventorySeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE customerSeq START WITH 1 INCREMENT BY 1; 
CREATE SEQUENCE customerOrderSeq START WITH 1 INCREMENT BY 1; 
CREATE SEQUENCE reviewSeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE RecommendationSeq START WITH 1 INCREMENT BY 1;
-- End Sequence create

-- Helper Functions
-- Find cuisine by name
CREATE OR REPLACE FUNCTION FIND_CUISINE_TYPE_ID(
    inCuisineName IN cuisine.cuisineName%TYPE
) RETURN INT
IS
  cCuisineId cuisine.cuisineId%TYPE; -- Variable to store the cuisine ID
BEGIN
  -- Select the cuisine ID corresponding to the given cuisine name
  SELECT cuisineId INTO cCuisineId FROM cuisine WHERE cuisineName = inCuisineName;
  -- Return the found cuisine ID
  RETURN cCuisineId;
EXCEPTION
  -- Handle the case where no data is found for the given cuisine name
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Cuisine with name ' || inCuisineName || ' not found.'); -- Output message when no data found
        RETURN -1; -- or any other custom value indicating no cuisine was found
    WHEN OTHERS THEN
        -- Handle other exceptions if necessary
        DBMS_OUTPUT.PUT_LINE('Error in FIND_CUISINE_TYPE_ID function: ' || SQLERRM);
        RETURN -1; -- or any other custom value indicating no cuisine was found
END;
/

-- Function to find the ID of a restaurant based on its name and location
CREATE OR REPLACE FUNCTION FIND_RESTAURANT_ID(
    inRestaurantName restaurant.restaurantName%TYPE
)
RETURN INT
IS
    outRestaurantID restaurant.restaurantId%TYPE; -- Variable to store the cuisine ID
BEGIN
    -- Initialize the output ID to NULL
    outRestaurantID := NULL;
    -- Retrieve the restaurant ID based on provided parameters
    SELECT restaurantId INTO outRestaurantID FROM restaurant WHERE restaurantName = inRestaurantName;

    -- Return the found restaurant ID
    RETURN outRestaurantID;
EXCEPTION
    -- Exception handling in case no matching restaurant is found
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Restaurant with name ' || inRestaurantName || ' not found.'); -- Output message when no data found
        RETURN -1; -- Return -1 if the restaurant is not found
    WHEN OTHERS THEN
        -- Handle other exceptions if necessary
        DBMS_OUTPUT.PUT_LINE('Error in FIND_RESTAURANT_ID function: ' || SQLERRM);
        RETURN -1; -- Return -1 if the restaurant is not found
END;
/

-- Function to find the menu item ID
CREATE OR REPLACE FUNCTION FIND_MENU_ITEM_ID (
    inMenuItemName IN menu_item.menuItemName%TYPE
) RETURN menu_item.menuItemId%TYPE
IS
    outMenuItemID menu_item.menuItemId%TYPE;
BEGIN
    -- Retrieve the menu item ID based on cuisine ID and menu item name
    SELECT menuItemId INTO outMenuItemID FROM menu_item WHERE menuItemName = inMenuItemName;

    -- Return the menu item ID
    RETURN outMenuItemID;
EXCEPTION
    -- Handle exceptions if multiple rows are returned
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Multiple menu items with name ' || inMenuItemName || ' found.'); -- Output message when multiple rows found
        RETURN -1; -- Return -1 if multiple rows are found
    -- Handle exceptions if the menu item is not found
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('MenuItem with name ' || inMenuItemName || ' not found.'); -- Output message when no data found
        RETURN -1; -- Return -1 if the menu item is not found
    WHEN OTHERS THEN
        -- Handle other exceptions
        DBMS_OUTPUT.PUT_LINE('Error in FIND_MENU_ITEM_ID function: ' || SQLERRM);
        RETURN -1; -- Return -1 if there's an error
END;
/

-- Function to find the customer ID
CREATE OR REPLACE FUNCTION FIND_CUSTOMER_ID(
    inCustomerName IN customer.customerName%TYPE
) RETURN INT
IS
    outCustomerID customer.customerId%TYPE; -- Variable to store the customer ID
BEGIN
    -- Retrieve the customer ID corresponding to the provided name
    SELECT customerId INTO outCustomerID
    FROM customer
    WHERE customerName = inCustomerName;
    -- Return the customer ID
    RETURN outCustomerID;
EXCEPTION
    -- Handle the case when no data is found for the provided name
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Customer with name ' || inCustomerName || ' not found.'); -- Output message when no data found
        RETURN -1; -- Return -1 if the customer is not found
    WHEN OTHERS THEN
        -- Handle other exceptions if necessary
        DBMS_OUTPUT.PUT_LINE('Error in FIND_CUSTOMER_ID function: ' || SQLERRM);
        RETURN -1; -- Return -1 if the customer is not found
END;
/

-- Function to find the waiter ID
CREATE OR RE

PLACE FUNCTION FIND_WAITER_ID(
    inWaiterName IN waiter.waiterName%TYPE
) RETURN INT
IS
    outWaiterID waiter.waiterId%TYPE; -- Variable to store the waiter ID
BEGIN
    -- Query to retrieve the waiter ID based on the name provided
    SELECT waiterId INTO outWaiterID
    FROM waiter
    WHERE waiterName = inWaiterName;
    -- Return the waiter ID
    RETURN outWaiterID;
EXCEPTION
    -- Handle exceptions if the waiter is not found
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Waiter not found with the provided name: ' || inWaiterName); -- Output message when no data found
        RETURN -1; -- Return -1 if the waiter is not found
    WHEN OTHERS THEN
        -- Handle other exceptions
        DBMS_OUTPUT.PUT_LINE('Error in FIND_WAITER_ID function: ' || SQLERRM);
        RETURN -1; -- Return -1 for other exceptions
END;
/

-- Function to get available quantity of a menu item in a restaurant
CREATE OR REPLACE FUNCTION GET_AVAILABLE_QUANTITY(
    inMenuItemId INT,
    inRestaurantId INT
) RETURN INT
IS
    v_quantity INT;
BEGIN
    SELECT quantity
    INTO v_quantity
    FROM inventory
    WHERE menuItemId = inMenuItemId
    AND restaurantId = inRestaurantId;

    RETURN v_quantity;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0; -- Return 0 if no matching record is found
END;
/

-- Helper Functions Import Done

-- Procedures

-- Procedure to add a cuisine type
CREATE OR REPLACE PROCEDURE ADD_CUISINE_TYPE(
    inCuisineName IN cuisine.cuisineName%TYPE
)AS
 isExist INT;
BEGIN

    SELECT COUNT(*) INTO isExist FROM cuisine WHERE cuisineName = inCuisineName;
    -- If a waiter and restaurant already exists, print a message.
    IF isExist > 0 THEN
        -- show the message for cuisine already exist.
        DBMS_OUTPUT.PUT_LINE('Cuisine '|| inCuisineName || ' with the provided name already exists.');
    ELSE
        INSERT INTO cuisine (cuisineId, cuisineName) VALUES (cuisineTypeSeq.NEXTVAL, inCuisineName);
        DBMS_OUTPUT.PUT_LINE('Cuisine added successfully.'); -- Print success message
    END IF;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- Procedure to add a restaurant
CREATE OR REPLACE PROCEDURE ADD_RESTAURANT(
    inRestaurantName IN restaurant.restaurantName%TYPE,
    inCuisineName IN cuisine.cuisineName%TYPE,
    inRestaurantStreetAddress IN restaurant.restaurantStreetAddress%TYPE,
    inRestaurantCity IN restaurant.restaurantCity%TYPE,
    inRestaurantState IN restaurant.restaurantState%TYPE,
    inRestaurantZip IN restaurant.restaurantZip%TYPE
) AS
    isExist INT;
    fnCuisineID INT;
BEGIN
    -- Return cuisine ID with the desired cuisine name using helper function
    fnCuisineID := FIND_CUISINE_TYPE_ID(inCuisineName); 
    
    IF fnCuisineID > 0 THEN
        -- Check Duplicate Check for the restaurant
        SELECT COUNT(*) INTO isExist FROM restaurant 
        WHERE cuisineId = fnCuisineID 
        AND restaurantName = inRestaurantName 
        AND restaurantStreetAddress = inRestaurantStreetAddress
        AND restaurantCity = inRestaurantCity 
        AND restaurantState = inRestaurantState 
        AND restaurantZip = inRestaurantZip;
    
        -- If the restaurant already exists, print a message
        IF isExist > 0 THEN
            -- Show the message for restaurant already existing
            DBMS_OUTPUT.PUT_LINE('Restaurant '|| inRestaurantName || ' with the provided information already exists.');
        ELSE
            -- Insert the record for the restaurant
            INSERT INTO restaurant (
                restaurantId,
                cuisineId,
                restaurantName,
                restaurantStreetAddress,
                restaurantCity,
                restaurantState,
                restaurantZip
            ) VALUES (
                restaurantSeq.NEXTVAL, -- Assuming you have a sequence named restaurantSeq
                fnCuisineID,
                inRestaurantName,
                inRestaurantStreetAddress,
                inRestaurantCity,
                inRestaurantState,
                inRestaurantZip
            );
            DBMS_OUTPUT.PUT_LINE('Restaurant added successfully.'); -- Print success message
        END IF;
    ELSE
         DBMS_OUTPUT.PUT_LINE('Unable to find any cuisine with the given name.'); -- Print error message
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting restaurant: ' || SQLERRM || fnCuisineID);
END;
/

-- Procedure to show restaurant information
CREATE OR REPLACE PROCEDURE SHOW_RESTAURANT_INFO IS
  -- Declare variables to store restaurant information
  v_restaurantId restaurant.restaurantId%TYPE;
  v_cuisineId restaurant.cuisineId%TYPE;
  v_restaurantName restaurant.restaurantName%TYPE;
  v_restaurantStreetAddress restaurant.restaurantStreetAddress%TYPE;
  v_restaurantCity restaurant.restaurantCity%TYPE;
  v_restaurantState restaurant.restaurantState%TYPE;
  v_restaurantZip restaurant.restaurantZip%TYPE;

  -- Declare cursor to fetch restaurant data
  CURSOR restaurant_cursor IS
    SELECT * FROM restaurant;

BEGIN
  -- Open cursor
  OPEN restaurant_cursor;
  
  -- Fetch restaurant data into variables
  LOOP
    FETCH restaurant_cursor INTO v_restaurantId, v_cuisineId, v_restaurantName, v_restaurantStreetAddress, v_restaurantCity, v_restaurantState, v_restaurantZip;
    
    -- Exit loop if no more rows to fetch
    EXIT WHEN restaurant_cursor%NOTFOUND;
    
    -- Display restaurant information
    DBMS_OUTPUT.PUT_LINE('Restaurant ID: ' || v_restaurantId);
    DBMS_OUTPUT.PUT_LINE('Cuisine ID: ' || v_cuisineId);
    DBMS_OUTPUT.PUT_LINE('Restaurant Name: ' || v_restaurantName);
    DBMS_OUTPUT.PUT_LINE('Address: ' || v_restaurantStreetAddress || ', ' || v_restaurantCity || ', ' || v_restaurantState || ' ' || v_restaurantZip);
    DBMS_OUTPUT.PUT_LINE('---------------------------');
  END LOOP;

  -- Close cursor
  CLOSE restaurant_cursor;
  
EXCEPTION
  WHEN OTHERS THEN
    -- Exception handling
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- Procedure to hire a waiter
CREATE OR REPLACE PROCEDURE HIRE_WAITER(
    inWaiterName IN waiter.waiterName%TYPE,
    inRestaurantName IN restaurant.restaurantName%TYPE
) AS
    isExist INT;
    fnWaiterID waiter.waiterId%TYPE;
    fnRestaurantID restaurant.restaurantId%TYPE;
BEGIN

    fnRestaurantID  := FIND_RESTAURANT_ID(inRestaurantName); -- return restaurant ID with the desired restaurant name using helper function   
    -- Check if the waiter already exists in the specified restaurant
    SELECT COUNT(*) INTO isExist FROM waiter WHERE restaurantId = fnRestaurantID AND waiterName = inWaiterName;
   
    -- If a waiter and restaurant already exists, print a message.
    IF isExist > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Waiter with the provided name already exists.');
    ELSE
        -- Insert the new waiter into the waiter table
        INSERT INTO waiter (waiterId, restaurantId, waiterName)
        VALUES (waiterSeq.NEXTVAL, fnRestaurantID, inWaiterName);
        -- Print success message
        DBMS_OUTPUT.PUT_LINE('Waiter hired successfully.');
    END IF;
EXCEPTION
    -- Exception handling for general errors
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Procedure to show waiters for a restaurant
CREATE OR REPLACE PROCEDURE SHOW_WAITERS(
    inRestaurantName IN restaurant.restaurantName%TYPE
)
AS
    fnRestaurantID restaurant.restaurantId%TYPE;
    
    -- Declare cursor to fetch waiter information
    CURSOR waiter_cursor IS
        SELECT w.waiterId, w.waiterName, r.restaurantName,
               r.restaurantStreetAddress, r.restaurantCity,
               r.restaurantState, r.restaurantZip
        FROM waiter w
        JOIN restaurant r ON w.restaurantId = r.restaurantId
        WHERE r.restaurantName = inRestaurantName;

    -- Declare variables to store waiter information
    v_waiterId waiter.waiterId%TYPE;
    v_waiterName waiter.waiterName%TYPE;
    v_restaurantName restaurant.restaurantName%TYPE;
    v_restaurantStreetAddress restaurant.restaurantStreetAddress%TYPE;
    v_restaurantCity restaurant.restaurantCity%TYPE;
    v_restaurantState restaurant.restaurantState%TYPE;
    v_restaurantZip restaurant.restaurantZip%TYPE;
BEGIN
    -- Find restaurant ID with the desired restaurant name using helper function
    fnRestaurantID := FIND_RESTAURANT_ID(inRestaurantName);
    
    -- Open cursor
    OPEN waiter_cursor;

    -- Fetch waiter data into variables
    LOOP
        FETCH waiter_cursor INTO v_waiterId, v_waiterName, v_restaurantName, v_restaurantStreetAddress, v_restaurantCity, v_restaurantState, v_restaurantZip;
        
        -- Exit loop if no more rows to fetch
        EXIT WHEN waiter_cursor%NOTFOUND;
        
        -- Display waiter information
        DBMS_OUTPUT.PUT_LINE('Waiter ID: ' || v_waiterId);
        DBMS_OUTPUT.PUT_LINE('Waiter Name: ' || v_waiterName);
        DBMS_OUTPUT.PUT_LINE('Restaurant Name: ' || v_rest

aurantName);
        DBMS_OUTPUT.PUT_LINE('Address: ' || v_restaurantStreetAddress || ', ' || v_restaurantCity || ', ' || v_restaurantState || ' ' || v_restaurantZip);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    END LOOP;

    -- Close cursor
    CLOSE waiter_cursor;
EXCEPTION
    WHEN OTHERS THEN
        -- Exception handling
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- Procedure to add a menu item
CREATE OR REPLACE PROCEDURE ADD_MENU_ITEM(
    cuisine_name IN cuisine.cuisineName%TYPE,
    menu_item_name IN menu_item.menuItemName%TYPE,
    menu_item_price IN menu_item.menuItemPrice%TYPE
) IS
    cuisine_id cuisine.cuisineId%TYPE;
BEGIN
    -- Call the helper function to find Cuisine ID
    cuisine_id := FIND_CUISINE_TYPE_ID(cuisine_name);
    -- Insert the menu item record
    INSERT INTO menu_item VALUES(menuItemSeq.nextval, cuisine_id, menu_item_name, menu_item_price);
    DBMS_OUTPUT.PUT_LINE('MenuItem with name ' || menu_item_name || ' added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE ('Error in adding menu item: ' || SQLCODE);
END;
/

-- Procedure to populate restaurant inventory for a specific restaurant
CREATE OR REPLACE PROCEDURE POPULATE_INVENTORY(
    restaurant_name IN restaurant.restaurantName%TYPE,
    menu_item_name IN menu_item.menuItemName%TYPE,
    menu_item_quantity IN inventory.quantity%TYPE
)
IS
    restaurant_id restaurant.restaurantId%TYPE;
    menu_item_id menu_item.menuItemId%TYPE;
BEGIN
    -- Call the helper function to find Restaurant ID
    restaurant_id := FIND_RESTAURANT_ID(restaurant_name);
    -- Call the helper function to find Menu Item ID
    menu_item_id := FIND_MENU_ITEM_ID(menu_item_name);

    IF menu_item_id > 0 THEN
        INSERT INTO inventory VALUES(inventorySeq.nextval, restaurant_id, menu_item_id, menu_item_quantity);
        DBMS_OUTPUT.PUT_LINE('Populated restaurant inventory with a menu item ' || menu_item_name || ' of quantity ' || menu_item_quantity || ' successfully');
    ELSE
        -- Output success message
        DBMS_OUTPUT.PUT_LINE('We do not found any proper MenuItem: ' || menu_item_name || '');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE ('Error in adding restaurant inventory record: ' || SQLERRM);
END;
/

-- Procedure to show restaurant inventory
CREATE OR REPLACE PROCEDURE SHOW_RESTAURANT_INVENTORY(
    inRestaurantName IN restaurant.restaurantName%TYPE
)
AS
    -- Declare cursor to fetch restaurant inventory
    CURSOR inventory_cursor IS
        SELECT i.inventoryId, i.restaurantId, i.menuItemId, i.quantity, r.restaurantName
        FROM inventory i
        JOIN restaurant r ON i.restaurantId = r.restaurantId
        WHERE r.restaurantName = inRestaurantName;
    
    -- Declare variables to store inventory information
    v_inventoryId inventory.inventoryId%TYPE;
    v_quantity inventory.quantity%TYPE;
    v_menuItemId inventory.menuItemId%TYPE;
    v_restaurantId inventory.restaurantId%TYPE;
    v_restaurantName restaurant.restaurantName%TYPE;
BEGIN
    -- Open cursor
    OPEN inventory_cursor;
    DBMS_OUTPUT.PUT_LINE('Inventory Id | Restaurant Id | Restaurant Name | Menu Item Id | Quantity ');

    -- Fetch inventory data into variables
    LOOP
        FETCH inventory_cursor INTO v_inventoryId, v_restaurantId, v_menuItemId, v_quantity, v_restaurantName;
        
        -- Exit loop if no more rows to fetch
        EXIT WHEN inventory_cursor%NOTFOUND;
        
        -- Display inventory information
        DBMS_OUTPUT.PUT_LINE(v_inventoryId || ' | ' || v_restaurantId || ' | ' || v_restaurantName || ' | ' || v_menuItemId || ' | ' || v_quantity);
    END LOOP;

    -- Close cursor
    CLOSE inventory_cursor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No inventory found for the specified restaurant.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- Procedure to add a customer
CREATE OR REPLACE PROCEDURE ADD_CUSTOMER(
    inCustomerName IN customer.customerName%TYPE,
    inCustomerEmail IN customer.customerEmail%TYPE,
    inCustomerStreetAddress IN customer.customerStreetAddress%TYPE,
    inCustomerCity IN customer.customerCity%TYPE,
    inCustomerState IN customer.customerState%TYPE,
    inCustomerZip IN customer.customerZip%TYPE,
    inCustomerCreditCardNumber IN customer.customerCreditCardNumber%TYPE
) AS
    customerCount INT; 
    customerNextId INT;
BEGIN
    customerNextId := customerSeq.NEXTVAL;
    -- Check if the customer with the provided email already exists
    SELECT COUNT(*) INTO customerCount FROM customer WHERE customerEmail = inCustomerEmail;
    -- If a customer with the provided email already exists, raise an exception
    IF customerCount > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Customer with the provided email already exists.');
    ELSE
        -- Insert the new customer record into the customer table
        INSERT INTO customer (
            customerId,
            customerName,
            customerEmail,
            customerStreetAddress,
            customerCity,
            customerState,
            customerZip,
            customerCreditCardNumber
        ) VALUES (
            customerNextId,
            inCustomerName,
            inCustomerEmail,
            inCustomerStreetAddress,
            inCustomerCity,
            inCustomerState,
            inCustomerZip,
            inCustomerCreditCardNumber
        );

        -- Output success message
        DBMS_OUTPUT.PUT_LINE('Customer with ID ' || customerNextId || ' Name ' || inCustomerName || ' inserted successfully.');
    END IF;
EXCEPTION
    -- Handle exceptions if any
    WHEN OTHERS THEN
        -- Output error message
        DBMS_OUTPUT.PUT_LINE('Error inserting customer: ' || SQLERRM);
END;
/

-- Procedure to add a customer order
CREATE OR REPLACE PROCEDURE ADD_CUSTOMER_ORDER(
    inCustomerName customer.customerName%TYPE, -- input of customerName
    inRestaurantName restaurant.restaurantName%TYPE, -- input of restaurantName
    inMenuItemName menu_item.menuItemName%TYPE, -- input of MenuItemName
    inWaiterName waiter.waiterName%TYPE, -- input of WaiterName
    inQuantity customer_order.quantity%TYPE, -- input for quantity
    inOrderAmountPaid NUMBER,
    inOrderAt DATE
) AS
    fnCustomerID customer.customerId%TYPE;
    fnRestaurantID restaurant.restaurantId%TYPE;
    fnMenuItemID menu_item.menuItemId%TYPE;
    fnWaiterID waiter.waiterId%TYPE;
    fnAvailableQuantity inventory.quantity%TYPE;
    calculatedOrderTips NUMBER;
    nextOrderId INT;
BEGIN
    nextOrderId := customerOrderSeq.NEXTVAL; -- get next sequenceId for this order
    fnCustomerID := FIND_CUSTOMER_ID(inCustomerName); -- return customerID with the desired customer name using helper function
    fnRestaurantID := FIND_RESTAURANT_ID(inRestaurantName); -- return restaurantID with the desired restaurant name using helper function
    fnMenuItemID := FIND_MENU_ITEM_ID(inMenuItemName); -- return menuItemID with the desired menu item name using helper function
    fnWaiterID := FIND_WAITER_ID(inWaiterName); -- return waiterID with the desired waiter name using helper function
    fnAvailableQuantity := GET_AVAILABLE_QUANTITY(fnMenuItemID, fnRestaurantID);

    IF fnAvailableQuantity >= inQuantity THEN
        -- Insert the new order
        calculatedOrderTips := ROUND(((inOrderAmountPaid / 100) * 20), 2); -- calculate the waiter tips for each order
        INSERT INTO customer_order (orderId, customerId, restaurantId, menuItemId, waiterId, quantity, orderAmountPaid, orderTips, orderAt)
        VALUES (nextOrderId, fnCustomerID, fnRestaurantID, fnMenuItemID, fnWaiterID, inQuantity, inOrderAmountPaid, calculatedOrderTips, inOrderAt);
        -- Output the order ID
        DBMS_OUTPUT.PUT_LINE('Order placed for ' || inQuantity || ' ' || inMenuItemName);
    ELSE
        DBMS_OUTPUT.PUT_LINE('No inventory found for this particular Menu: ' || inMenuItemName || ' Restaurant: ' || inRestaurantName);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- Procedure to get customer orders by restaurant and date
CREATE OR REPLACE PROCEDURE GET_CUSTOMER_ORDERS (
  inRestaurantName IN restaurant.restaurantName%TYPE,
  inOrderAt IN DATE 
) AS
  -- Declare cursor to fetch customer orders
  CURSOR orders_cursor IS
    SELECT c.customerName, o.orderID, mi.menuItemName, o.orderAmountPaid
    FROM customer c
    JOIN customer_order o ON c.customerId = o.customerId
    JOIN menu_item mi ON o.menuItemId = mi.menuItemId
    JOIN restaurant r ON o.restaurantId = r.restaurantId
    WHERE r.restaurantName = inRestaurantName
    AND TRUNC(o.orderAt) = inOrderAt;

  -- Declare variables to store order information
  v_customerName customer.customerName%TYPE;
  v_orderID customer_order.orderId%TYPE

;
  v_menuItemName menu_item.menuItemName%TYPE;
  v_orderAmountPaid customer_order.orderAmountPaid%TYPE;
BEGIN
  -- Open cursor
  OPEN orders_cursor;
  
  -- Fetch order data into variables
  LOOP
    FETCH orders_cursor INTO v_customerName, v_orderID, v_menuItemName, v_orderAmountPaid;
    
    -- Exit loop if no more rows to fetch
    EXIT WHEN orders_cursor%NOTFOUND;
    
    -- Display order information
    DBMS_OUTPUT.PUT_LINE('Customer Name: ' || v_customerName || ', Order ID: ' || v_orderID || ', Item: ' || v_menuItemName || ', Amount Paid: ' || v_orderAmountPaid);
  END LOOP;

  -- Close cursor
  CLOSE orders_cursor;
  
EXCEPTION
  WHEN OTHERS THEN
    -- Exception handling
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- Procedure to add a review
CREATE OR REPLACE PROCEDURE ADD_REVIEW(
  inReviewerEmail IN VARCHAR,
  inRestaurantName IN VARCHAR,
  inReviewText IN VARCHAR,
  inStarsGiven IN NUMBER
) AS
  fnRestaurantID INT;
BEGIN
  -- Find the restaurant ID by name
  fnRestaurantID := FIND_RESTAURANT_ID(inRestaurantName);  
  -- Check if the restaurant exists
  IF fnRestaurantID > 0 THEN
    -- Insert the review
    INSERT INTO review(reviewId, restaurantId, reviewerEmail, reviewerStarsGiven, reviewText)
    VALUES (reviewSeq.NEXTVAL, fnRestaurantID, inReviewerEmail, inStarsGiven, inReviewText);
    DBMS_OUTPUT.PUT_LINE('Review added successfully.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Restaurant not found!');
  END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE ('Error in adding Review record: ' || SQLERRM);
END;
/

-- Procedure to show top and bottom X restaurants by average star rating
CREATE OR REPLACE PROCEDURE Buy_Or_Beware(
  r_x IN NUMBER
) IS
  CURSOR top_restaurants_cur IS
    SELECT AVG(r.reviewerStarsGiven) AS avg_stars,
           r.restaurantId,
           res.restaurantName,
           csn.cuisineName,
           STDDEV(r.reviewerStarsGiven) AS std_dev
    FROM review r
    JOIN restaurant res ON r.restaurantId = res.restaurantId
    JOIN cuisine csn ON res.cuisineId = csn.cuisineId 
    GROUP BY r.restaurantId, res.restaurantName, csn.cuisineName
    ORDER BY avg_stars DESC;
  
  CURSOR beware_restaurants_cur IS
    SELECT AVG(r.reviewerStarsGiven) AS avg_stars,
           r.restaurantId,
           res.restaurantName,
           csn.cuisineName,
           STDDEV(r.reviewerStarsGiven) AS std_dev
    FROM review r
    JOIN restaurant res ON r.restaurantId = res.restaurantId
    JOIN cuisine csn ON res.cuisineId = csn.cuisineId 
    GROUP BY r.restaurantId, res.restaurantName, csn.cuisineName
    ORDER BY avg_stars;

  v_counter NUMBER := 0;  -- Counter to limit the number of rows
BEGIN
  DBMS_OUTPUT.PUT_LINE('Top rated restaurants:');
  FOR top_restaurant_rec IN top_restaurants_cur LOOP
    EXIT WHEN v_counter >= r_x;
    DBMS_OUTPUT.PUT_LINE('Avg Stars: ' || ROUND(top_restaurant_rec.avg_stars, 2) ||
                         ', Restaurant ID: ' || top_restaurant_rec.restaurantId ||
                         ', Restaurant Name: ' || top_restaurant_rec.restaurantName ||
                         ', Cuisine Type: ' || top_restaurant_rec.cuisineName ||
                         ', Std Dev: ' || ROUND(top_restaurant_rec.std_dev, 2));
    v_counter := v_counter + 1;
  END LOOP;

  v_counter := 0;  -- Reset the counter for the next loop
  DBMS_OUTPUT.PUT_LINE('Buyer Beware: Stay Away from…');
  FOR beware_restaurant_rec IN beware_restaurants_cur LOOP
    EXIT WHEN v_counter >= r_x;
    DBMS_OUTPUT.PUT_LINE('Avg Stars: ' || ROUND(beware_restaurant_rec.avg_stars, 2) ||
                         ', Restaurant ID: ' || beware_restaurant_rec.restaurantId ||
                         ', Restaurant Name: ' || beware_restaurant_rec.restaurantName ||
                         ', Cuisine Type: ' || beware_restaurant_rec.cuisineName ||
                         ', Std Dev: ' || ROUND(beware_restaurant_rec.std_dev, 2));
    v_counter := v_counter + 1;
  END LOOP;
END;
/

-- Procedure to display restaurants by cuisine
CREATE OR REPLACE PROCEDURE Display_Restaurant_By_Cuisine (
    P_cuisine_name IN cuisine.cuisineName%TYPE
)
AS
BEGIN
    FOR r IN (SELECT r.restaurantName, r.restaurantStreetAddress, r.restaurantCity
              FROM restaurant r
              JOIN cuisine c ON r.cuisineId = c.cuisineId
              WHERE c.cuisineName = p_cuisine_name)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Restaurant Name: ' || r.restaurantName || ', Address: ' || r.restaurantStreetAddress || ', ' || r.restaurantCity);
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No restaurants found');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unable to display restaurants.');
END;
/

-- Procedure to report income by state
CREATE OR REPLACE PROCEDURE Report_Income_By_State AS
BEGIN
    FOR r IN (SELECT c.cuisineName, r.restaurantState, COUNT(*) AS restaurant_count
              FROM restaurant r
              JOIN cuisine c ON r.cuisineId = c.cuisineId
              GROUP BY c.cuisineName, r.restaurantState)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Cuisine Type: ' || r.cuisineName || ', State: ' || r.restaurantState || ', Restaurant Count: ' || r.restaurant_count);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unable to generate income report.');
END;
/

-- Procedure to calculate waiter tips
CREATE OR REPLACE PROCEDURE CALCULATE_WAITER_TIPS IS
BEGIN
    FOR waiter_rec IN (SELECT w.waiterName, SUM(co.orderTips) AS total_tips
                       FROM waiter w
                       JOIN customer_order co ON w.waiterId = co.waiterId
                       GROUP BY w.waiterName)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Waiter: ' || waiter_rec.waiterName || ', Total Tips: ' || waiter_rec.total_tips);
    END LOOP;
END;
/

-- Procedure to calculate and display total tips earned by waiters per state
CREATE OR REPLACE PROCEDURE CALCULATE_WAITER_TIPS_BY_STATE IS
BEGIN
    FOR state_rec IN (SELECT res.restaurantState, SUM(co.orderTips) AS total_tips
                      FROM restaurant res
                      JOIN waiter w ON res.restaurantId = w.restaurantId
                      JOIN customer_order co ON w.waiterId = co.waiterId
                      GROUP BY res.restaurantState)
    LOOP
        DBMS_OUTPUT.PUT_LINE('State: ' || state_rec.restaurantState || ', Total Tips: ' || state_rec.total_tips);
    END LOOP;
END;
/

-- Procedure to show waiters for a restaurant
CREATE OR REPLACE PROCEDURE SHOW_WAITERS_FOR_RESTAURANT (
    p_restaurant_name IN restaurant.restaurantName%TYPE
)
AS
BEGIN
    FOR waiter_rec IN (
        SELECT w.waiterName
        FROM waiter w
        JOIN restaurant r ON w.restaurantId = r.restaurantId
        WHERE r.restaurantName = p_restaurant_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Waiter: ' || waiter_rec.waiterName);
    END LOOP;
END;
/

-- Trigger to update restaurant inventory every time there is an order of an item
CREATE OR REPLACE TRIGGER UPDATE_INVENTORY_ON_ORDER
AFTER INSERT ON CUSTOMER_ORDER
FOR EACH ROW
DECLARE
    menuitem_quantity inventory.quantity%TYPE;
    updated_menuitem_quantity inventory.quantity%TYPE;
BEGIN
    -- Check if the ordered menu item is available in a particular restaurant to reduce the quantity of that menu item
    IF GET_AVAILABLE_QUANTITY(:NEW.menuItemId, :NEW.restaurantId) >= :NEW.quantity THEN
        -- Store the current quantity value of the menu item in a variable to display
        SELECT quantity INTO menuitem_quantity FROM inventory WHERE restaurantId = :NEW.restaurantId AND menuItemId = :NEW.menuItemId;
        -- Update the restaurant inventory record with updated quantity
        UPDATE inventory SET quantity = quantity - :NEW.quantity WHERE restaurantId = :NEW.restaurantId AND menuItemId = :NEW.menuItemId;
        -- Store the updated quantity of the menu item in a variable to display
        SELECT quantity INTO updated_menuitem_quantity FROM inventory WHERE restaurantId = :NEW.restaurantId AND menuItemId = :NEW.menuItemId;
        DBMS_OUTPUT.PUT_LINE('Menu item quantity in inventory has been updated from ' || menuitem_quantity || ' to ' || updated_menuitem_quantity);
    ELSE
        DBMS_OUTPUT.PUT_LINE('There is an insufficient quantity of the menu item available in inventory to decrease its count.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in updating restaurant inventory record: ' || SQLERRM);
END;
/

-- Procedure to generate a report to show totals of each menu item by type of cuisine
CREATE OR REPLACE PROCEDURE REPORT_MENU_ITEMS AS
    -- Declare cursor to fetch total menu items
    CURSOR menu

_items_cursor IS
        SELECT menu_item.menuItemName, cuisine.cuisineName, SUM(quantity)
        FROM cuisine
        JOIN menu_item ON cuisine.cuisineId = menu_item.cuisineId
        JOIN inventory ON menu_item.menuItemId = inventory.menuItemId
        GROUP BY cuisine.cuisineName, menu_item.menuItemName
        ORDER BY cuisine.cuisineName;
    
    -- Declare variables to store menu items information
    v_menuItemName menu_item.menuItemName%TYPE;
    v_cuisineName cuisine.cuisineName%TYPE;
    v_total inventory.quantity%TYPE;
BEGIN
    -- Open cursor
    OPEN menu_items_cursor;
    DBMS_OUTPUT.PUT_LINE('REPORT OF TOTALS OF EACH MENU ITEM: ');
    DBMS_OUTPUT.PUT_LINE('Cuisine Name | Menu Item Name | Total Menu Items ');
    
    -- Fetch menu items data into variables
    LOOP
        FETCH menu_items_cursor INTO v_menuItemName, v_cuisineName, v_total;
        
        -- Exit loop if no more rows to fetch
        EXIT WHEN menu_items_cursor%NOTFOUND;
        
        -- Display menu items information
        DBMS_OUTPUT.PUT_LINE(v_cuisineName || ' | ' || v_menuItemName || ' | ' || v_total);
    END LOOP;

    -- Close cursor
    CLOSE menu_items_cursor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No menu item found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- Procedure to list orders at a restaurant on a given date
CREATE OR REPLACE PROCEDURE LIST_ORDER_RESTAURANT(
    inRestaurantName IN restaurant.restaurantName%TYPE,-- input restaurantName as string
    inOrderDate IN DATE -- input orderDate as Date
)
AS    
    fnRestaurantID restaurant.restaurantId%TYPE;
    CURSOR order_cursor IS
        SELECT *
        FROM customer_order
        WHERE restaurantId = fnRestaurantID
        AND orderAt = inOrderDate;
    order_rec order_cursor%ROWTYPE;
BEGIN
    fnRestaurantID := FIND_RESTAURANT_ID(inRestaurantName); -- return restaurantID with the desired restaurant name using helper function
    
    DBMS_OUTPUT.PUT_LINE('===========   Report For the ' || inRestaurantName || ' ===========');
    DBMS_OUTPUT.PUT_LINE('Order ID | Customer ID | Menu Item ID | Waiter ID | Order Amount Paid | Order Tips | Order Date');
    OPEN order_cursor;
    LOOP
        FETCH order_cursor INTO order_rec;
        EXIT WHEN order_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(order_rec.orderId || ' | ' || order_rec.customerId 
        || ' | ' || order_rec.menuItemId || ' | ' || order_rec.waiterId 
        || ' | ' || order_rec.orderAmountPaid || ' | ' || order_rec.orderTips || ' | ' || TO_CHAR(order_rec.orderAt, 'YYYY-MM-DD'));
    END LOOP;
    CLOSE order_cursor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No orders found for the given restaurant and date.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);    
END;
/

-- Procedure to get customers by zip code
CREATE OR REPLACE PROCEDURE GET_CUSTOMERS_BY_ZIP(p_zip IN INT) IS
    CURSOR c_customers IS 
        SELECT customerName
        FROM customer
        WHERE customerZip = p_zip;

    v_customerName customer.customerName%TYPE;
BEGIN
    OPEN c_customers;
    DBMS_OUTPUT.PUT_LINE('===========   List of all customers living in ' || p_zip || ' Zip Code ===========');

    LOOP
        FETCH c_customers INTO v_customerName;
        EXIT WHEN c_customers%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Customer Name: ' || v_customerName);
    END LOOP;
    CLOSE c_customers;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No customers found with the given ZIP code.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END;
/

-- Procedure to show top 3 restaurants by total amount paid in each state
CREATE OR REPLACE PROCEDURE TOP_RESTAURANTS IS
  v_counter NUMBER := 0; -- Counter variable 
  CURSOR state_cursor IS
    SELECT DISTINCT restaurantState FROM restaurant;
BEGIN
  FOR state_rec IN state_cursor LOOP

    DBMS_OUTPUT.PUT_LINE('===========   Top 3 Restaurants in ' || state_rec.restaurantState || ' ===========');
    v_counter := 0; -- Reset counter for each state
    
    FOR rest_rec IN (
      SELECT 
        r.restaurantName,
        SUM(co.orderAmountPaid) AS total_amount_paid
      FROM restaurant r
      JOIN customer_order co ON r.restaurantId = co.restaurantId
      WHERE r.restaurantState = state_rec.restaurantState
      GROUP BY r.restaurantName
      ORDER BY SUM(co.orderAmountPaid) DESC
    ) LOOP
      EXIT WHEN v_counter >= 3; -- Exit loop when 3 restaurants are printed
      v_counter := v_counter + 1; -- Increment counter
      DBMS_OUTPUT.PUT_LINE('  ' || rest_rec.restaurantName || ' - Total Amount Paid: $' || TO_CHAR(rest_rec.total_amount_paid, '99999.99'));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
  END LOOP;
END;
/

-- Procedure to calculate and insert recommendations
CREATE OR REPLACE PROCEDURE CALCULATE_RECOMMENDATION(
    customerName IN VARCHAR2,
    cuisineName IN VARCHAR2
)
IS
    v_cuisine_id INT;
    v_restaurant_id INT;
    v_customer_id INT;
BEGIN
    -- Get the cuisine ID based on cuisine name
    v_cuisine_id := FIND_CUISINE_TYPE_ID(cuisineName);
    -- Get the customer ID based on customer name
    v_customer_id := FIND_CUSTOMER_ID(customerName);

    -- Generate recommendation for the restaurant with the highest average review rating in the given cuisine
    SELECT restaurantId INTO v_restaurant_id
    FROM (
        SELECT r.restaurantId, AVG(rv.reviewerStarsGiven) AS avg_rating
        FROM restaurant r
        JOIN review rv ON r.restaurantId = rv.restaurantId
        WHERE r.cuisineId = v_cuisine_id
        GROUP BY r.restaurantId
        ORDER BY avg_rating DESC
    )
    WHERE ROWNUM = 1;

    -- Insert the recommendation into the recommendation table
    INSERT INTO recommendation(recommendationId, customerId, restaurantId, recommendationAt)
    VALUES (RecommendationSeq.NEXTVAL, v_customer_id, v_restaurant_id, SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Recommendation generated successfully.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No restaurant found for the given cuisine.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Procedure to list all recommendations
CREATE OR REPLACE PROCEDURE LIST_RECOMMENDATIONS IS
BEGIN
  FOR recommendation_rec IN (
    SELECT c.customerName AS CustomerName,
           r.restaurantName AS RestaurantName,
           csn.cuisineName AS CuisineType,
           AVG(rev.reviewerStarsGiven) AS AverageStars
    FROM recommendation rec
    JOIN customer c ON rec.customerId = c.customerId
    JOIN restaurant r ON rec.restaurantId = r.restaurantId
    JOIN cuisine csn ON r.cuisineId = csn.cuisineId
    JOIN review rev ON r.restaurantId = rev.restaurantId
    GROUP BY c.customerName, r.restaurantName, csn.cuisineName
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE('Customer: ' || recommendation_rec.CustomerName || ', Recommended Restaurant: ' || recommendation_rec.RestaurantName || ', Cuisine Type: ' || recommendation_rec.CuisineType || ', Average Stars: ' || recommendation_rec.AverageStars);
  END LOOP;
END;
/

-- Start and calling anonymous function for D3
BEGIN

    DBMS_OUTPUT.PUT_LINE ('===============================================');  
    DBMS_OUTPUT.PUT_LINE ('===========   Below are Member 1 Operations ===========');
    DBMS_OUTPUT.PUT_LINE ('===============================================');
    -- For populating data otherwise it will not generate the report. 
    ADD_CUISINE_TYPE('American');
    ADD_CUISINE_TYPE('Italian');
    ADD_CUISINE_TYPE('BBQ');
    ADD_CUISINE_TYPE('Indian');
    ADD_CUISINE_TYPE('Ethiopian');
    ADD_RESTAURANT('Ribs_R_US', 'American', '123 Main St', 'New York', 'NY', '21250');
    ADD_RESTAURANT('Bull Roast', 'BBQ', '123 Main St', 'New York', 'NY', '10013');
    ADD_RESTAURANT('Bella Italia', 'Italian', '123 Main St', 'Ellicott City', 'MD', '21043');
    ADD_RESTAURANT('Roma', 'Italian', '456 Elm St', 'Ellicott City', 'MD', '21043');
    ADD_RESTAURANT('Taj Mahal', 'Indian', '123 Main St', 'New York', 'NY', '10013');
    ADD_RESTAURANT('Selasie', 'Ethiopian', '123 Main St', 'State College', 'PA', '16822');
    ADD_RESTAURANT('Ethiop', 'Ethiopian', '456 Elm St', 'State College', 'PA', '16822');

    DBMS_OUTPUT.PUT_LINE('===== Displaying Italian Restaurants =====');


    Display_Restaurant_By_Cuisine('Italian');
    DBMS_OUTPUT.PUT_LINE('===== Displaying Ethiopian Restaurants =====');
    Display_Restaurant_By_Cuisine('Ethiopian');

    DBMS_OUTPUT.PUT_LINE ('===============================================');  
    DBMS_OUTPUT.PUT_LINE ('===========   Below are Member 2 Operations ===========');
    DBMS_OUTPUT.PUT_LINE ('===============================================');
    -- For populating data otherwise it will not generate the report. 
    HIRE_WAITER('Jack', 'Ribs_R_US');
    HIRE_WAITER('Jill', 'Ribs_R_US');
    HIRE_WAITER('Wendy', 'Ribs_R_US');
    HIRE_WAITER('Hailey', 'Ribs_R_US');
    HIRE_WAITER('Mary', 'Bella Italia');
    HIRE_WAITER('Pat', 'Bella Italia');
    HIRE_WAITER('Michael', 'Bella Italia');
    HIRE_WAITER('Rakesh', 'Bella Italia');
    HIRE_WAITER('Verma', 'Bella Italia');
    HIRE_WAITER('Mike', 'Roma');
    HIRE_WAITER('Judy', 'Roma');
    HIRE_WAITER('Trevor', 'Selasie');
    HIRE_WAITER('Gupta', 'Taj Mahal');  
    HIRE_WAITER('Hannah', 'Bull Roast');  
    HIRE_WAITER('Trisha', 'Ethiop');  

    DBMS_OUTPUT.PUT_LINE ('===========   Waiter list: Bella Italia ===========');
    SHOW_WAITERS_FOR_RESTAURANT('Bella Italia');
    DBMS_OUTPUT.PUT_LINE ('===========   Waiter list: Taj Mahal ===========');
    SHOW_WAITERS_FOR_RESTAURANT('Taj Mahal');

    DBMS_OUTPUT.PUT_LINE ('===============================================');  
    DBMS_OUTPUT.PUT_LINE ('===========   Below are Member 3 Operations ===========');
    DBMS_OUTPUT.PUT_LINE ('===============================================');
    -- For populating data otherwise it will not generate the report. 
    ADD_MENU_ITEM('American', 'burger', 10);
    ADD_MENU_ITEM('American', 'fries', 5);
    ADD_MENU_ITEM('American', 'pasta', 15);
    ADD_MENU_ITEM('American', 'salad', 10);
    ADD_MENU_ITEM('American', 'salmon', 20);

    -- Adding for inconsistent data
    ADD_MENU_ITEM('American', 'burgers mignon', 10);
    -- Ending for inconsistent data

    ADD_MENU_ITEM('Italian', 'lasagna', 15);
    ADD_MENU_ITEM('Italian', 'meatballs', 10);
    ADD_MENU_ITEM('Italian', 'spaghetti', 15);
    ADD_MENU_ITEM('Italian', 'pizza', 20);

    ADD_MENU_ITEM('Ethiopian', 'meat chunks', 12);
    ADD_MENU_ITEM('Ethiopian', 'legume stew', 10);
    ADD_MENU_ITEM('Ethiopian', 'flatbread', 3);

    ADD_MENU_ITEM('BBQ', 'steak', 25);
    ADD_MENU_ITEM('BBQ', 'pork loin', 15);
    ADD_MENU_ITEM('BBQ', 'fillet mignon', 30); 
    
    ADD_MENU_ITEM('Indian', 'dal soup', 10);
    ADD_MENU_ITEM('Indian', 'rice', 5);
    ADD_MENU_ITEM('Indian', 'tandoori chicken', 10); 
    ADD_MENU_ITEM('Indian', 'samosa', 8); 

    POPULATE_INVENTORY('Ribs_R_US', 'burger', 50);
    POPULATE_INVENTORY('Ribs_R_US', 'fries', 150);
    
    POPULATE_INVENTORY('Bella Italia', 'lasagna', 10);
    
    POPULATE_INVENTORY('Bull Roast', 'steak', 15);
    POPULATE_INVENTORY('Bull Roast', 'pork loin', 50);
    POPULATE_INVENTORY('Bull Roast', 'fillet mignon', 5);
    
    POPULATE_INVENTORY('Taj Mahal', 'dal soup', 50);
    POPULATE_INVENTORY('Taj Mahal', 'rice', 500);
    POPULATE_INVENTORY('Taj Mahal', 'samosa', 150);
    
    POPULATE_INVENTORY('Selasie', 'meat chunks', 150);
    POPULATE_INVENTORY('Selasie', 'legume stew', 150);
    POPULATE_INVENTORY('Selasie', 'flatbread', 500);

    POPULATE_INVENTORY('Ethiop', 'meat chunks', 150);
    POPULATE_INVENTORY('Ethiop', 'legume stew', 150);
    POPULATE_INVENTORY('Ethiop', 'flatbread', 500);
    POPULATE_INVENTORY('Bella Italia', 'pizza', 100);
    POPULATE_INVENTORY('Bella Italia', 'spaghetti', 100);

    -- To solve the inconsistent data 
     POPULATE_INVENTORY('Ribs_R_US', 'burgers mignon', 500);
     POPULATE_INVENTORY('Ribs_R_US', 'pork loin', 500);

    DBMS_OUTPUT.PUT_LINE ('===============================================');  
    DBMS_OUTPUT.PUT_LINE ('===========   Below are Member 4 Operations ===========');
    DBMS_OUTPUT.PUT_LINE ('===============================================');
        
    ADD_CUSTOMER('Cust1',   'Cust1@sample.com',    '123 Main St', 'Anytown', 'CA', 21045, '2446653024438274');
    ADD_CUSTOMER('Cust11',  'Cust11@sample.com',   '124 Main St', 'Villa', 'MD', 21045,   '5564892128581441');
    ADD_CUSTOMER('Cust3',   'Cust3@sample.com',    '125 Main St', 'tower', 'MD', 21046,   '3873340052058602');
    ADD_CUSTOMER('Cust111', 'Cust111@sample.com', '135 Main St', 'building', 'CA', 21045, '4916383429570725');

    ADD_CUSTOMER('CustNY1', 'CustNY1@sample.com', '145 Main St', 'Anytown', 'CA', 10045, '4216383429570735');
    ADD_CUSTOMER('CustNY2', 'CustNY2@sample.com', '155 Main St', 'tower', 'CA', 10045,   '4416383429570745'); 
    ADD_CUSTOMER('CustNY3', 'CustNY3@sample.com', '165 Main St', 'Villa', 'CA', 10045,   '4516383429570755');
    ADD_CUSTOMER('CustPA1', 'CustPA1@sample.com', '175 Main St', 'building', 'CA', 16822,'4616383429570765');
    ADD_CUSTOMER('CustPA2', 'CustPA2@sample.com', '185 Main St', 'tower', 'CA', 16822,   '4716383429570775');
    ADD_CUSTOMER('CustPA3', 'CustPA3@sample.com', '195 Main St', 'building', 'CA', 16822,'4816383429570785');      
    ADD_CUSTOMER('CustPA4', 'CustPA4@sample.com', '196 Main Ct', 'building', 'CA', 16822,'4816383429570786');  
    ADD_CUSTOMER('CustPA5', 'CustPA5@sample.com', '197 Main St', 'building', 'CA', 16822,'4816383429570787');  
    ADD_CUSTOMER('CustPA6', 'CustPA6@sample.com', '198 Main Ct', 'building', 'CA', 16822,'4816383429570788');  

    GET_CUSTOMERS_BY_ZIP(21045);

    ADD_CUSTOMER_ORDER('Cust1',  'Bella Italia', 'pizza',      'Mary', 1, 20, DATE '2024-03-10');
    ADD_CUSTOMER_ORDER('Cust11', 'Bella Italia', 'spaghetti',  'Mary', 2, 30, DATE '2024-03-15');
    ADD_CUSTOMER_ORDER('Cust11', 'Bella Italia', 'pizza',      'Mary', 1, 20, DATE '2024-03-15');

    ADD_CUSTOMER_ORDER('CustNY1', 'Bull Roast', 'fillet mignon', 'Hannah', 2, 60, DATE '2024-04-01');
    ADD_CUSTOMER_ORDER('CustNY1', 'Bull Roast', 'fillet mignon', 'Hannah', 2, 60, DATE '2024-04-01');
    ADD_CUSTOMER_ORDER('CustNY1', 'Bull Roast', 'fillet mignon', 'Hannah', 2, 60, DATE '2024-04-02');
    ADD_CUSTOMER_ORDER('CustNY2', 'Bull Roast', 'pork loin', 'Hannah', 1, 15, DATE '2024-04-01'); 

    ADD_CUSTOMER_ORDER('CustPA1', 'Ethiop', 'meat chunks', 'Trisha', 10, 120, DATE '2024-04-01');

    ADD_CUSTOMER_ORDER('CustNY2', 'Selasie', 'meat chunks', 'Trevor', 1, 48, DATE '2024-04-01');

    ADD_CUSTOMER_ORDER('CustNY1', '

Ribs_R_US', 'burgers mignon', 'Jack', 4, 60, DATE '2024-04-01');
    ADD_CUSTOMER_ORDER('CustNY1', 'Ribs_R_US', 'burgers mignon', 'Jill', 4, 60, DATE '2024-04-02');
    ADD_CUSTOMER_ORDER('CustNY2', 'Bull Roast', 'pork loin', 'Hannah', 1, 15, DATE '2024-04-01');
    
    ADD_CUSTOMER_ORDER('CustNY2', 'Selasie', 'meat chunks', 'Trevor', 1, 48, DATE '2024-04-01');

    ADD_CUSTOMER_ORDER('CustPA1', 'Ethiop', 'meat chunks', 'Trisha', 10, 120, DATE '2024-05-01'); 
    ADD_CUSTOMER_ORDER('CustPA1', 'Ethiop', 'meat chunks', 'Trisha', 10, 120, DATE '2024-05-10'); 
    ADD_CUSTOMER_ORDER('CustPA2', 'Selasie', 'legume stew', 'Trevor', 10, 100, DATE '2024-05-01'); 
    ADD_CUSTOMER_ORDER('CustPA2', 'Selasie', 'legume stew', 'Trevor', 10, 100, DATE '2024-05-11'); 

    ADD_CUSTOMER_ORDER('CustPA2', 'Taj Mahal', 'samosa', 'Gupta', 100, 80, DATE '2024-05-01'); 

    LIST_ORDER_RESTAURANT('Selasie',   DATE '2024-04-01');
    LIST_ORDER_RESTAURANT('Ribs_R_US', DATE '2024-04-01');
    TOP_RESTAURANTS;

    DBMS_OUTPUT.PUT_LINE ('===============================================');  
    DBMS_OUTPUT.PUT_LINE ('===========   Below are Member 3 - Dependent Operations of M4 ===========');
    DBMS_OUTPUT.PUT_LINE ('===============================================');
    -- Run a SQL query to Generate a report to show totals of each menu item by type of cuisine
    REPORT_MENU_ITEMS();
    -- Run a SQL query to update restaurant inventory every time there is an order of an item
    ADD_CUSTOMER_ORDER('CustNY2', 'Taj Mahal', 'rice', 'Gupta', 25, 120, DATE '2024-04-01'); 
    ADD_CUSTOMER_ORDER('Cust11', 'Selasie', 'meat chunks', 'Trevor', 50, 10, DATE '2024-01-23');
    ADD_CUSTOMER_ORDER('Cust1', 'Bull Roast', 'fillet mignon', 'Mike', 2, 10, DATE '2024-02-15');
        
    DBMS_OUTPUT.PUT_LINE ('-------------- Initial Inventory for Ethiop restaurant -------------------');
    SHOW_RESTAURANT_INVENTORY('Ethiop');
    ADD_CUSTOMER_ORDER('CustPA1', 'Ethiop', 'meat chunks', 'Judy', 30, 120, DATE '2024-05-06'); 
    ADD_CUSTOMER_ORDER('CustPA2', 'Ethiop', 'meat chunks', 'Judy', 30, 120, DATE '2024-05-06');
    ADD_CUSTOMER_ORDER('Cust3', 'Ethiop', 'legume stew', 'Verma', 20, 120, DATE '2024-05-06'); 
    DBMS_OUTPUT.PUT_LINE ('-------------- Final Inventory for Ethiop restaurant -------------------');
    SHOW_RESTAURANT_INVENTORY('Ethiop');

    DBMS_OUTPUT.PUT_LINE ('===============================================');  
    DBMS_OUTPUT.PUT_LINE ('===========   Below are Member 5 Operations ===========');
    DBMS_OUTPUT.PUT_LINE ('===============================================');
    -- For populating data otherwise it will not generate the report. 
    ADD_REVIEW('cust1@gmail.com', 'Ribs_R_US',    'Wonderful place, but expensive.', 4);
    ADD_REVIEW('cust1@gmail.com', 'Bella Italia', 'Very bad food. I’m Italian and Bella Italia does NOT give you authentic Italian food.', 2);
    ADD_REVIEW('abc@abc.com',     'Ribs_R_US',    'I liked the food. Good experience.',  4);
    ADD_REVIEW('dce@abc.com',     'Ribs_R_US',    'Excellent.', 5);
    ADD_REVIEW('abc@abc.com',     'Bella Italia', 'So-so',  3);
    ADD_REVIEW('abc@abc.com',     'Selasie', 'I liked the food. Authentic Ethiopian experience', 4);
    ADD_REVIEW('cust1@gmail.com', 'Selasie', 'Excellent flavor. Highly recommended', 5);
    ADD_REVIEW('abc@abc.com',     'Ribs_R_US', 'so-so. Low quality beef', 2);
    ADD_REVIEW('abc@abc.com',   'Taj Mahal', 'Best samosas ever', 5);
    ADD_REVIEW('cust1@gmail.com',  'Taj Mahal',   'I enjoyed their samosas, but did not like the dal', 4);
    ADD_REVIEW('zzz@abc.com',  'Taj Mahal',  'Excellent samosas', 5);
    ADD_REVIEW('surajit@abc.com',   'Taj Mahal',  'Not really authentic',  3);
    ADD_REVIEW('dce@abc.com', 'Bull Roast',  'Excellent', 5);
    ADD_REVIEW('abc@abc.com', 'Bull Roast', 'Just fine', 3);
    ADD_REVIEW('abc@abc.com', 'Bull Roast', 'I Liked the food', 4);

    Buy_Or_Beware(3);
    BUY_OR_BEWARE(5);

    -- Execute the recommendation for customer Cust111
    CALCULATE_RECOMMENDATION('Cust111', 'BBQ');
    CALCULATE_RECOMMENDATION('Cust111', 'Indian');
    
    -- List all the recommendations
    LIST_RECOMMENDATIONS;

    DBMS_OUTPUT.PUT_LINE ('===============================================');  
    DBMS_OUTPUT.PUT_LINE ('===========   Below are Member 1 Operations ===========');
    DBMS_OUTPUT.PUT_LINE ('===============================================');
    Report_Income_By_State;

    DBMS_OUTPUT.PUT_LINE ('===============================================');  
    DBMS_OUTPUT.PUT_LINE ('===========   Below are Member 2 Operations ===========');
    DBMS_OUTPUT.PUT_LINE ('===============================================');
    CALCULATE_WAITER_TIPS;
    CALCULATE_WAITER_TIPS_BY_STATE;

END;
-- End anonymous function
```