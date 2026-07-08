import mysql.connector
import pandas as pd

# 1. Read your desktop file cleanly using pandas
csv_path = r"Market_Basket_Optimisation.csv"
print("Reading CSV file...")

# header=None tells pandas that your CSV doesn't have column names at the top
df = pd.read_csv(csv_path, header=None)

# 2. Connect to your local MySQL server
print("Connecting to local MySQL server...")
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Password",  # <-- Put your real password here
    database="retail_db"
)
cursor = conn.cursor()

print("Streaming data into MySQL order_items table...")

# 3. Dynamic row-by-row data streaming matrix
# We loop over every row, treating the index as the order_id, and split items
for order_id, row in df.iterrows():
    # Loop through every single column item in that specific receipt row
    for item in row:
        # Check if the item isn't blank (NaN)
        if pd.notna(item) and str(item).strip() != "":
            cursor.execute(
                "INSERT INTO order_items (order_id, product_name) VALUES (%s, %s)",
                (int(order_id + 1), str(item).strip().lower())
            )

conn.commit()
cursor.close()
conn.close()
print("\n SUCCESS! All rows loaded completely without any format errors!")
