-- Signup Activation Rate
-- https://datalemur.com/questions/signup-confirmation-rate

-- Step 1
-- Join tables for records with successful confirmations
-- LEFT JOIN because we want to keep all emails

SELECT texts.email_id, emails.email_id
FROM emails
LEFT JOIN texts
  ON emails.email_id = texts.email_id
  AND texts.signup_action = 'Confirmed';

-- LEFT JOIN ensures all rows from emails are kept 
-- AND includs only matching confirmed texts 

-- Step 2
-- Calculate the signup activation rate for specified user, where activation rate = total confirmed text events / total (unique) users

SELECT 
  COUNT(texts.email_id)
    / COUNT(DISTINCT emails.email_id) AS activation_rate
FROM emails
LEFT JOIN texts
  ON emails.email_id = texts.email_id
  AND texts.signup_action = 'Confirmed';

-- Step 3
-- Convert COUNT to DECIMAL to avoid integer division

SELECT 
  COUNT(texts.email_id)::DECIMAL
  ---- This works too ----
  -- CAST(COUNT(texts.email_id)) AS DECIMAL
    / COUNT(DISTINCT emails.email_id) AS activation_rate
FROM emails
LEFT JOIN texts
  ON emails.email_id = texts.email_id
  AND texts.signup_action = 'Confirmed';

-- Step 4
-- Round the signup activation rate 

SELECT 
  ROUND(COUNT(texts.email_id)::DECIMAL
    / COUNT(DISTINCT emails.email_id), 2) AS activation_rate
FROM emails
LEFT JOIN texts
  ON emails.email_id = texts.email_id
  AND texts.signup_action = 'Confirmed';  