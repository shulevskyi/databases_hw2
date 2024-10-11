import mysql.connector
from faker import Faker
import random
from datetime import datetime, timedelta

# Connect to the database
db = mysql.connector.connect(
    host="localhost",
    user="root",
    passwd="fifadg13",
    database="db_new_hw2"
)
cursor = db.cursor()

# Instance of Faker
fake = Faker()

# Populate the customers table
used_emails = set()

# Populate the customers table
while len(used_emails) < 10000:
    email = fake.email()
    if email not in used_emails:
        used_emails.add(email)
        cursor.execute("INSERT INTO customers (first_name, last_name, email) VALUES (%s, %s, %s)",
                       (fake.first_name(), fake.last_name(), email))


# Populate the products table
for _ in range(10000):
    cursor.execute("INSERT INTO products (product_name, price) VALUES (%s, %s)",
                   (fake.word(), random.uniform(10.0, 500.0)))

# Commit after each table is populated to avoid locks
db.commit()

# Populate the orders table
start_date = datetime.now() - timedelta(days=365)
for _ in range(10000):
    order_date = start_date + timedelta(days=random.randint(0, 365))
    cursor.execute("INSERT INTO orders (product_id, customer_id, order_date, quantity) VALUES (%s, %s, %s, %s)",
                   (random.randint(1, 10000), random.randint(1, 10000), order_date.strftime('%Y-%m-%d'), random.randint(1, 10)))

# Final commit and close
db.commit()
cursor.close()
db.close()

print("Data populated successfully!")
