-- Counting Instances in Text
-- https://platform.stratascratch.com/coding/9814-counting-instances-in-text?code_type=1

-- Step 1
-- Emit one row per occurrence of 'bull' across all documents

SELECT 
    'bull' AS word
FROM google_file_store,
     LATERAL REGEXP_MATCHES(LOWER(CONTENTS), '\m(bull)\M', 'g')
     -- LATERAL: Allow REGEXP_MATCHES() to reference CONTENTS from google_file_store
     -- REGEXP_MATCHES(): Set-returning function — emits one row per match found
     -- LOWER(): Normalize to lowercase 
     -- '\m(bull)\M': Match exact whole word only, using word boundaries (\m = start, \M = end)
     -- 'g': Global flag — find all matches per document, not just the first

-- Step 2
-- Count all emitted rows to get total occurrences of 'bull'

SELECT 
    'bull' AS word,
     COUNT(*) AS nentry
FROM google_file_store,
     LATERAL REGEXP_MATCHES(LOWER(CONTENTS), '\m(bull)\M', 'g')

-- Step 3
-- Repeat for 'bear'

SELECT 
    'bear' AS word,
    COUNT(*) AS nentry
FROM google_file_store,
     LATERAL REGEXP_MATCHES(LOWER(CONTENTS), '\m(bear)\M', 'g') 

-- Step 4
-- Show both word counts

SELECT 
    'bull' AS word,
    COUNT(*) AS nentry
FROM google_file_store,
     LATERAL REGEXP_MATCHES(LOWER(CONTENTS), '\m(bull)\M', 'g')
UNION ALL 
SELECT 
    'bear' AS word,
    COUNT(*) AS nentry
FROM google_file_store,
     LATERAL REGEXP_MATCHES(LOWER(CONTENTS), '\m(bear)\M', 'g');