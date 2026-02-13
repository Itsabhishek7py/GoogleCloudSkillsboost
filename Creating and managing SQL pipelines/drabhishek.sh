# drabhishek ki code copy karleta hu kyuki wo to mere malik hai 

#!/bin/bash

PROJECT_ID=$(gcloud config get-value project)

# Spinner function
spinner() {
    pid=$!
    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r[%c] Processing..." "${spin:$i:1}"
        sleep .1
    done
    printf "\r[✓] Done!            \n"
}

clear
echo "==============================================="
echo "  Welcome to Dr Abhishek Tutorials 🚀"
echo "  Do LIKE the video and SUBSCRIBE the channel"
echo "  https://www.youtube.com/@drabhishek.5460/videos"
echo "==============================================="
echo ""
echo "Using Project: $PROJECT_ID"
echo ""

############################################
echo "Task 1: Creating Dataset..."
bq --location=US mk --dataset ${PROJECT_ID}:thelook_ecommerce >/dev/null 2>&1 &
spinner

############################################
echo "Task 2: Creating Tables..."
bq query --use_legacy_sql=false >/dev/null 2>&1 <<EOF &
CREATE OR REPLACE TABLE \`thelook_ecommerce.product_orders_fulfillment\` (
 order_id INT64,
 user_id INT64,
 status STRING,
 product_id INT64,
 created_at TIMESTAMP,
 returned_at TIMESTAMP,
 shipped_at TIMESTAMP,
 delivered_at TIMESTAMP,
 cost NUMERIC,
 sale_price NUMERIC,
 retail_price NUMERIC,
 category STRING,
 name STRING,
 brand STRING,
 department STRING,
 sku STRING,
 distribution_center_id INT64
);

CREATE OR REPLACE TABLE \`thelook_ecommerce.centers\` (
 id INT64,
 name STRING,
 latitude FLOAT64,
 longitude FLOAT64,
 point_location GEOGRAPHY
);

CREATE OR REPLACE TABLE \`thelook_ecommerce.customers\` (
 id INT64,
 first_name STRING,
 last_name STRING,
 email STRING,
 age INT64,
 gender STRING,
 state STRING,
 street_address STRING,
 postal_code STRING,
 city STRING,
 country STRING,
 traffic_source STRING,
 created_at TIMESTAMP,
 latitude FLOAT64,
 longitude FLOAT64,
 point_location GEOGRAPHY
);
EOF
spinner

############################################
echo "Task 3: Loading & Transforming Data..."
bq query --use_legacy_sql=false >/dev/null 2>&1 <<EOF &
CREATE OR REPLACE TABLE \`thelook_ecommerce.centers\` AS
SELECT
 id,
 name,
 latitude,
 longitude,
 ST_GEOGPOINT(longitude, latitude) AS point_location
FROM \`bigquery-public-data.thelook_ecommerce.distribution_centers\`;

CREATE OR REPLACE TABLE \`thelook_ecommerce.customers\` AS
SELECT
 id,
 first_name,
 last_name,
 email,
 age,
 gender,
 state,
 street_address,
 postal_code,
 city,
 country,
 traffic_source,
 created_at,
 latitude,
 longitude,
 ST_GEOGPOINT(longitude, latitude) AS point_location
FROM \`bigquery-public-data.thelook_ecommerce.users\`;
EOF
spinner

############################################
echo "Task 4: Creating Stored Procedure..."
bq query --use_legacy_sql=false >/dev/null 2>&1 <<EOF &
CREATE OR REPLACE PROCEDURE \`thelook_ecommerce.sp_create_load_tables\`()
BEGIN
CREATE OR REPLACE TABLE \`thelook_ecommerce.product_orders_fulfillment\` AS
SELECT
  items.*,
  products.id AS product_id_products,
  products.name AS product_name,
  products.category AS product_category
FROM \`bigquery-public-data.thelook_ecommerce.order_items\` AS items
JOIN \`bigquery-public-data.thelook_ecommerce.products\` AS products
ON items.product_id = products.id;
END;
EOF
spinner

############################################
echo "Running Stored Procedure..."
bq query --use_legacy_sql=false "CALL \`thelook_ecommerce.sp_create_load_tables\`();" >/dev/null 2>&1 &
spinner

############################################
echo "Calculating Distance to Closest Center..."
bq query --use_legacy_sql=false "
SELECT
 customers.id AS customer_id,
 (
   SELECT MIN(ST_DISTANCE(centers.point_location, customers.point_location))/1000
   FROM \`thelook_ecommerce.centers\` AS centers
 ) AS distance_to_closest_center
FROM \`thelook_ecommerce.customers\` AS customers
LIMIT 10;
"

echo ""
echo "==============================================="
echo "🎉 All Tasks Completed Successfully!"
echo "Subscribe for more Google Cloud Labs 🚀"
echo "==============================================="
