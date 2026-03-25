#!/bin/bash

# StreamTalk Data Ingestion Script
# This script loads CSV data into BigQuery tables for the StreamTalk analytics project.
# Ensure you are authenticated with Google Cloud and have the correct project set.

echo "Starting data ingestion into BigQuery..."

echo "Uploading users data..."
bq load --source_format=CSV --skip_leading_rows=1 \
  streamtalk-analytics:streamtalk.users scripts/data/users.csv \
  "user_id:STRING,role:STRING,country:STRING,signup_date:DATE,acq_source:STRING"

echo "Uploading streams data..."
bq load --source_format=CSV --skip_leading_rows=1 \
  streamtalk-analytics:streamtalk.streams scripts/data/streams.csv \
  "stream_id:STRING,creator_id:STRING,started_at:TIMESTAMP,ended_at:TIMESTAMP,category:STRING,peak_viewers:INTEGER"

echo "Uploading sessions data..."
bq load --source_format=CSV --skip_leading_rows=1 \
  streamtalk-analytics:streamtalk.sessions scripts/data/sessions.csv \
  "session_id:STRING,user_id:STRING,stream_id:STRING,session_start:TIMESTAMP,session_end:TIMESTAMP,watch_seconds:INTEGER"

echo "Uploading events data..."
bq load --source_format=CSV --skip_leading_rows=1 \
  streamtalk-analytics:streamtalk.events scripts/data/events.csv

echo "Uploading gifts data..."
bq load --source_format=CSV --skip_leading_rows=1 \
  streamtalk-analytics:streamtalk.gifts scripts/data/gifts.csv \
  "gift_id:STRING,sender_id:STRING,recipient_id:STRING,stream_id:STRING,sent_at:TIMESTAMP,gift_value_coins:INTEGER"

echo "Data ingestion completed successfully."