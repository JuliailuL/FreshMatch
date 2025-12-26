# FreshMatch
A relational database for managing food inventory, reducing waste, and linking ingredients to recipes.
[Watch the project overview video](https://youtu.be/rdAv_ZFppDM)

## Purpose
FreshMatch is a database project designed to reduce food waste by tracking food inventory, expiration dates, and linking stocked foods to recipes.
It also helps manage shopping lists and records discarded items to analyze wasted money and foods.

## Folder Structure
```bash
├── docs
│   ├── DESIGN.md
│   └── schema_diagram.png
├── queries
│   └── user_queries.sql
└── schema
    └── schema.sql
```

## Setup Instructions
Run the SQL schema file in `schema/` first, then populate the database using `queries/user_queries.sql`.

## Features
- Track food items and their expiration dates.
- Automatically move expired items to the `bin` table (via trigger).
- Automatically add non-expired deleted items to the shopping list (via trigger).
- View groceries that are expiring soon.
- See recipes using soon-to-expire ingredients.
- Calculate money spent on discarded items.
