/*
    Account Inactivity Alert

    MY ASSUMPTIONS;
    - active accounts are plans that are not deleted (plan.is_deleted = 0)
*/

-- Step 1: Get all active plan details and their associated successful deposit if any
WITH plans_and_deposits AS (
	SELECT 
		plans.id AS plan_id
		, plans.owner_id
		, CASE 
			WHEN plans.is_a_fund = 1 THEN 'Investment'
			WHEN plans.is_regular_savings = 1 THEN 'Savings'
		END AS type
		, coalesce(deposit.transaction_date, plans.created_on) as transaction_date   -- Using plan.created_on for users that haven't made a deposit yet in order to compute inactivity
		, deposit.transaction_id
	FROM adashi_staging.plans_plan AS plans
	LEFT JOIN ( 
		SELECT 
			plan_id
			, transaction_date
			, id AS transaction_id
		FROM adashi_staging.savings_savingsaccount 
		WHERE transaction_status IN ('success', 'successful')
	) AS deposit 
        ON plans.id = deposit.plan_id
	WHERE 
		plans.is_deleted = 0  -- Exclude deleted plans. Assumming deleted plans are inactive
		AND (plans.is_a_fund = 1 OR plans.is_regular_savings = 1) -- Filter for only investment and savings plans
)

-- Step 2: Aggregate plan and filter out inactive plans/accounts
SELECT  
	plan_id
    , owner_id
    , type
    , MAX(transaction_date) AS last_transaction_date
    , DATEDIFF(CURDATE(), MAX(transaction_date)) AS inactivity_days
FROM plans_and_deposits
GROUP BY 
    plan_id
    , owner_id
    , type
HAVING inactivity_days > 365; -- Requirement: no inflow transactions for over one year.
