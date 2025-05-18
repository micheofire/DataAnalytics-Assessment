# DataAnalytics-Assessment

## Assumptions

1. After reviewing the distinct values in the `transaction_status` column of the `savings_savingsaccount` table, I assumed that transactions with a status of **"success"** or **"successful"** should be considered valid and completed.

2. I assumed the `is_deleted` field in the `plans_plan` table indicates the status of a plan. Only plans where `is_deleted = 0` are considered **active** and included in the analysis. Deleted plans (`is_deleted = 1`) are treated as **inactive** and excluded.

3. I also assumed that all monetary values (e.g., amount fields) should be reported in **Naira**.

---

## Assessment 1

**Goal:** Identify customers with at least one funded **savings plan** and one funded **investment plan**, sorted by total deposits.

**Approach:**
I first retrieved all active plans per user and their associated deposits. I filtered for only successful deposits using the `transaction_status` field and included only active plans (`is_deleted = 0`).
Next, I used `GROUP BY` to aggregate savings and investment plan counts (`savings_count`, `investment_count`) along with total deposits for each user. The result was then sorted by total deposits in descending order.

---

## Assessment 2

**Goal:** Calculate the average number of transactions per customer per month, and categorize users into **High**, **Medium**, and **Low** frequency segments.

**Approach:**
I began by retrieving all user transactions grouped by month. For each user, I calculated the **average monthly transaction count**, then classified users into frequency segments based on predefined thresholds for high, medium, and low activity.

---

## Assessment 3

**Goal:** Identify active accounts (savings or investments) that have had **no transactions in the last 365 days**.

**Approach:**
I retrieved all deposit records linked to savings and investment plans. I ensured the query covered both transacting and non-transacting plans.
For each plan, I computed the most recent transaction date and calculated the number of **days since last activity**. For plans/accounts that haven't performed a transaction yet, I used the `created_on` column from the `plans_plan` table to compute their `last_transaction_date` and `inactivity_days`. I then filtered for plans with **inactivity greater than 365 days**, considering only active plans (`is_deleted = 0`).

---

## Assessment 4

**Goal:** Compute **account tenure**, **total transactions**, and an estimated **Customer Lifetime Value (CLV)**.

**Approach:**
I started by extracting basic user data and their transaction history, ensuring to include users with **no transaction history**.
I then calculated each user’s:

* **Tenure in months** (based on account creation date),
* **Total number of transactions**,
* **Average profit per transaction** (in Naira).

Using these values, I estimated each user’s **Customer Lifetime Value** and structured the final output accordingly.

---

## Challenges

The major challenge I encountered was the lack of clarity around what constitutes an "active plan." After inspecting the schema, I inferred that the `is_deleted` flag is the best indicator of plan status. I based all filtering logic on this assumption, which I believe aligns with best practices for this analysis.
