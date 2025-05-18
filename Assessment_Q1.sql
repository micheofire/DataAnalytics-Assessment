/*
    1. High-Value Customers with Multiple Products
        Scenario: The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
        Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.
*/

-- Get all successful deposit transactions, enriched with user and plan info
WITH all_deposits AS (
	SELECT 
		deposit.owner_id
		, deposit.confirmed_amount/100 AS confirmed_amount_naira     -- Convert amount from kobo to naira
		, CONCAT(users.first_name, ' ', users.last_name) AS name
		, plans.is_a_fund AS investment_plan
		, plans.is_regular_savings AS savings_plan
	FROM adashi_staging.savings_savingsaccount AS deposit
	LEFT JOIN adashi_staging.users_customuser AS users ON deposit.owner_id = users.id 
	LEFT JOIN adashi_staging.plans_plan AS plans ON deposit.plan_id = plans.id
	WHERE 
		deposit.transaction_status IN ('success', 'successful')    -- Only successful transactions
		AND plans.is_deleted = 0   -- Exclude deleted plans
)

-- Aggregate deposits and product usage per customer
SELECT 
	owner_id
    , name
    , SUM(savings_plan) AS savings_count   -- Count of savings plans
    , SUM(investment_plan) AS investment_count   -- Count of investment plans
    , ROUND(SUM(confirmed_amount_naira), 2) AS total_deposits   -- Total deposits in naira
FROM all_deposits
group by 
    owner_id
    , name
HAVING
	savings_count >= 1   -- Must have at least one savings plan
    AND investment_count >= 1   -- Must have at least one investment plan
ORDER BY
	total_deposits DESC;