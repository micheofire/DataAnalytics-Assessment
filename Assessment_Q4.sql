-- First step is to get all customers basic demographics data and deposit details
WITH all_customers as (
	SELECT DISTINCT
		users.id AS customer_id
		, coalesce(concat(users.first_name, ' ', 'User'), users.username) AS name
		, users.date_joined     
		, deposit.transaction_id 
		, (deposit.confirmed_amount/100) * 0.001 AS profit_per_transaction
	FROM adashi_staging.users_customuser AS users
	LEFT JOIN (
		SELECT 
			owner_id
			, id as transaction_id
			, confirmed_amount
		FROM adashi_staging.savings_savingsaccount
		WHERE transaction_status IN ('success', 'successful')
	) AS deposit 
		ON users.id = deposit.owner_id
)

-- Second step is to aggregate the customer data to get CLV
, all_customer_aggregate AS (
	SELECT 
		customer_id
		, name
		, MIN(date_joined) AS signup_date
        , COUNT(DISTINCT transaction_id) AS total_transactions
		, TIMESTAMPDIFF(MONTH, MIN(date_joined), NOW()) AS tenure_months
		, COALESCE(AVG(profit_per_transaction), 0) AS avg_profit_per_transaction
	FROM all_customers
	GROUP BY 
        customer_id
        , name
)

-- Calculate CLV
SELECT
	customer_id
    , name
    , tenure_months
    , total_transactions
    , COALESCE(ROUND((total_transactions/tenure_months) * 12 * avg_profit_per_transaction, 2), 0) AS estimated_clv
FROM all_customer_aggregate
ORDER BY estimated_clv DESC;
