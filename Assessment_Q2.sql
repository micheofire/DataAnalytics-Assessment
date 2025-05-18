/*
2. Transaction Frequency Analysis
Scenario: The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).

Task: Calculate the average number of transactions per customer per month and categorize them:
    "High Frequency" (≥10 transactions/month)
    "Medium Frequency" (3-9 transactions/month)
    "Low Frequency" (≤2 transactions/month)
*/

-- Get all transactions per user per month including users with no transactions
WITH transactions_per_user_per_month AS (
	SELECT DISTINCT
		users.id AS customer_id
		, tnx.transaction_month
		, COALESCE(tnx.transaction_count, 0) AS transaction_count 
	FROM adashi_staging.users_customuser AS users 
	LEFT JOIN (
		SELECT 
			owner_id
			, DATE_FORMAT(transaction_date, '%M %Y') AS transaction_month
			, COUNT(DISTINCT id) AS transaction_count 
		FROM adashi_staging.savings_savingsaccount AS savings
		WHERE transaction_status IN ('success', 'successful')
		GROUP BY
			owner_id
			, DATE_FORMAT(transaction_date, '%M %Y')
	) AS tnx ON users.id = tnx.owner_id
)

-- Get the average transaction per user per month
, average_transaction_per_user AS (
	SELECT 
		customer_id
		, ROUND(AVG(transaction_count)) AS average_transaction_per_month
	FROM transactions_per_user_per_month 
	GROUP BY customer_id
)

-- Categorize users based on average transaction per month
, categorized_users AS (
	SELECT 
		customer_id
		, CASE 
			WHEN average_transaction_per_month >= 10 THEN 'High Frequency'
            WHEN  average_transaction_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            WHEN average_transaction_per_month <= 2 THEN 'Low Frequency'
		END AS frequency_category
        , average_transaction_per_month
	FROM average_transaction_per_user
)

SELECT
	frequency_category
    , COUNT(DISTINCT customer_id) AS customer_count
    , ROUND(AVG(average_transaction_per_month), 1) AS average_transactions_per_month
FROM categorized_users
GROUP BY frequency_category
ORDER BY
	FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');




