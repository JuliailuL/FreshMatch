-- ##############################################################################################################
-- FreshMatch Typical Queries
-- This file contains example inserts, updates, selects, and deletions for testing and using the database.
-- ##############################################################################################################


-- ##############################################################################################################
-- INSERTS
-- ##############################################################################################################

-- Add items to the food table, here with some example data:
INSERT INTO food (name, amount, bbDate, price, category)
    VALUES ('joghurt', 10, date('now', '+3 days'), 2.99, 'dairy'),
    ('apple', 2, date('now', '+1 days'), 0, 'fruit'),
    ('rice', 1, date('now', '-5 days'), 2, 'dry'),
    ('banana', 3, date('now', '+3 days'), 2, 'fruit'),
    ('chicken', 6, date('now', '+4 days'), 6.50, 'meat'),
    ('broccoli', 3, date(), 4, 'veggie'),
    ('spaghetti', 2, date('now', '+2 months'), 1.88, 'dry'),
    ('almonds', 5, '2025-10-05', 3.65, 'dry'),
    ('flour', 2, '2025-12-24', 1.99, 'dry')
;

-- Add recipes:
INSERT INTO recipe (name, instructions)
    VALUES ('banana bread', 'bake it with love'),
    ('chicken alfredo', 'you know how')
;

-- Fill the Primary Keys from tables recipe and food into the junction table ingredients:
INSERT INTO ingredients (recipe_id, food_id, amount)
    VALUES (1, 4, 2),
    (1, 9, 0.4),
    (2, 5, 2),
    (2, 7, 1)
;

-- Add an item to the shopping list
INSERT INTO shoppingList (name, amount, category)
    VALUES ('milk', 2, 'dairy');


-- ##############################################################################################################
-- UPDATES
-- ##############################################################################################################

-- Add to the food storage by name / Update the amount by name
UPDATE food
SET amount = 3, instock = 1
WHERE name = 'flour';

-- Add to the food storage by id / Update the amount by id
UPDATE food
SET amount = 3, instock = 1
WHERE id = 3;


-- ##############################################################################################################
-- DELETES
-- ##############################################################################################################

-- Delete a row from the food list, if not expired the item will be added to the shopping list via trigger
DELETE FROM food WHERE name = 'apple';

-- Delete items that already expired, also triggers them being added to the 'wasted' list
DELETE FROM food WHERE bbDate < date();


-- ##############################################################################################################
-- SELECTS
-- ##############################################################################################################

-- Show all food items ordered by date:
SELECT name, amount, bbDate FROM food ORDER BY bbDate;

-- Query from view: Show bbDate, name and amount of groceries that are approaching their
-- expiration date within 5 days, ordered by date, then alphabetically
SELECT * FROM comingUp;

-- Query from view: Show best-before date, name and amount of groceries that are past their expiration dates
SELECT * FROM pastDue;

-- Query from view: Show a list of recipes with items approaching their best before date
SELECT * FROM showRecipe_ApproachBB;

-- Query from view: Show the shopping list ordered by categories
SELECT * FROM shoppingList;


-- ##############################################################################################################
-- AGGREGATES / SUMMARIES
-- ##############################################################################################################

-- Show money spent on all thrown out groceries
SELECT SUM(amount * price) AS "money not well spent" from bin;

-- Show number of expired items
SELECT SUM(amount) AS "number of thrown out groceries" from bin;
