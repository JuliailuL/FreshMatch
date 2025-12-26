-- ##############################################################################################################
-- FreshMatch Database Schema
-- This file contains the schema for tables, indexes, views, and triggers used in the FreshMatch project.
-- ##############################################################################################################


-- ##############################################################################################################
-- TABLES
-- ##############################################################################################################

-- Create tables for the different food groups:
CREATE TABLE food(
    id INTEGER,
    name TEXT NOT NULL UNIQUE,
    category TEXT CHECK(category IN ('dairy', 'dry', 'veggie', 'fruit', 'meat', 'fish')) NOT NULL DEFAULT 'dry',
    amount REAL DEFAULT 1,
    bbDate DATE,
    price REAL,
    instock INTEGER CHECK( instock IN (0,1)) NOT NULL DEFAULT 1, --because sqlite doesn't have a boolean
    PRIMARY KEY (id)
);

-- Create a table with recipes:
CREATE TABLE recipe(
    id INTEGER,
    name TEXT UNIQUE NOT NULL,
    instructions TEXT,
    PRIMARY KEY (id)
);

-- Create a junction table to establish a relation between food and recipe:
CREATE TABLE ingredients(
    recipe_id INTEGER,
    food_id INTEGER,
    amount REAL DEFAULT 1,
    PRIMARY KEY (recipe_id, food_id),
    FOREIGN KEY (recipe_id) REFERENCES recipe(id),
    FOREIGN KEY (food_id) REFERENCES food(id)
);

-- This table will later be filled by adding items or with the trigger 'cooked':
CREATE TABLE shoppingList(
    id INTEGER,
    name TEXT NOT NULL,
    amount REAL DEFAULT 1,
    category TEXT CHECK( category IN ('dairy', 'dry', 'veggie', 'fruit', 'meat', 'fish'))NOT NULL DEFAULT 'dry',
    PRIMARY KEY (id)
);

-- This table will later be filled with the trigger 'wasted':
CREATE TABLE bin(
    id INTEGER,
    name TEXT,
    amount REAL,
    price REAL,
    PRIMARY KEY (id)
);


-- ##############################################################################################################
-- INDEXES
-- ##############################################################################################################

-- To improve performance in queries involving the ingredients table:
CREATE INDEX recipeIndex  ON ingredients(recipe_id);
CREATE INDEX foodIndex ON ingredients(food_id);


-- ##############################################################################################################
-- VIEWS
-- ##############################################################################################################

-- A view for groceries that will spoil during the next five days:
CREATE VIEW comingUp AS
    SELECT name, amount, bbDate
    FROM food
    WHERE bbDate BETWEEN date() AND date('now', '+5 days')
    AND instock = 1
    ORDER BY bbDate, name;

-- A view for groceries already past their best-before date:
CREATE VIEW pastDue AS
    SELECT name, amount, bbDate
    FROM food
    WHERE bbDate < date()
    AND instock = 1
    ORDER BY bbDate, name;

-- A view to show recipes for items about to expire:
CREATE VIEW showRecipe_ApproachBB AS
    SELECT r.name AS "recipe", f.name AS "ingredient", i.amount AS "amount in recipe",
    f.amount AS "amount in stock"
    FROM recipe AS r, food AS f, ingredients AS i
    WHERE f.id = i.food_id AND r.id = i.recipe_id
    AND f.bbDate BETWEEN date() AND date('now', '+5 days')
    AND f.instock = 1
    ORDER BY f.bbDate;

-- A view that shows the shopping list ordered by grocery type:
CREATE VIEW groceryList AS
    SELECT name, amount, category
    FROM shoppingList
    ORDER BY category, name;


-- ##############################################################################################################
-- TRIGGERS
-- ##############################################################################################################

-- When a spoiled item is deleted it will be added to trashed and instock is set to 0
CREATE TRIGGER expired
    BEFORE DELETE ON food
    FOR EACH ROW
    WHEN OLD.bbDate < date()
    BEGIN
        INSERT INTO bin (name, amount, price)
        VALUES (OLD.name, OLD.amount, OLD.price);
        UPDATE food SET instock = 0
        WHERE  id = OLD.id;
        SELECT RAISE(IGNORE);
END;

-- When an item is deleted before its expiration date, it will be added to a shopping list
-- and instock is set to 0
CREATE TRIGGER cooked
    BEFORE DELETE ON food
    FOR EACH ROW
    WHEN OLD.bbDate >= date()
    BEGIN
        INSERT INTO shoppingList (name, amount, category)
        VALUES (OLD.name, OLD.amount, OLD.category);
        UPDATE food SET instock = 0
        WHERE id = OLD.id;
        SELECT RAISE(IGNORE);
    END;
