#!/bin/bash

# StreamTalk Data Verification Script
# This script queries BigQuery to verify the row counts in all tables.
# Ensure you are authenticated with Google Cloud and have the correct project set.

echo "Verifying data in BigQuery tables..."
echo "Running query to count rows in each table..."
echo ""

bq query --use_legacy_sql=false \
"SELECT 'users'    AS table_name, COUNT(*) AS rows FROM streamtalk.users    UNION ALL
 SELECT 'streams',                COUNT(*)          FROM streamtalk.streams  UNION ALL
 SELECT 'sessions',               COUNT(*)          FROM streamtalk.sessions UNION ALL
 SELECT 'events',                 COUNT(*)          FROM streamtalk.events   UNION ALL
 SELECT 'gifts',                  COUNT(*)          FROM streamtalk.gifts"

echo ""
echo "Verification complete. Check the row counts above."