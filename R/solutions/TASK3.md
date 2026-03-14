---
output: html_document
---
<img src="../../input/health_db_schema.jpg" alt="Health Record DB" style="display: block; margin: 0 auto;" width="300" height="300">
  
  Notes on the schema:
  patient.lga_code and facility.lga_code both reference a Local Government Area but there is no formal lga lookup table in this schema (see Q1).
  separation_mode encodes how the admission ended: ‘discharge’[text](TASK4.md) [text](TASK3.md), ‘death’, ‘transfer’, ‘left_against_advice’.
  drg_code is an AR-DRG code (Australian Refined Diagnosis Related Group).
  remoteness in facility uses the 5-category ARIA classification.
  all dates are stored as DATE type (YYYY-MM-DD).

Q1. In this schema, patient.lga_code and facility.lga_code both reference a Local Government Area, but there is no formal LGA lookup table in the database. What are the risks/consequences of this design decision, and what would you do about it in an analytical context?

_Respond_:
If there exists no LGA lookup table in the database, there could be a couple of things that can happen. 
1. `patient.lga_code` and `facility.lga_code`will be considered as unrelated to one another where no enforce integrity and may not guarantee consistency.
2. There could be values that exists in patient for lga_code but not in facility and introduce null values when joining.
3. Any spelling mismatch will break the joins.
4. Joining the two databases must be done manually.

In Analytical context, I will introduce **a lookup table** from the **unique values of the two tables** and create their values and enforce **referential constraint** between primary keys of my lookup table and foreign keys from both tables.

Q2. An epidemiologist who runs queries against this database to **filter** admissions by admission_date reports to you that her queries are running slowly on a table with 5 million rows. What could you do to speed up these queries and why?

_Respond_:This is common when accessing a big database as illustrated. I would introduce a **chunksize** and **an index** that **iterate over the database** to fetch the data sequentially (**pagination**) to ensure the management of the data fetch and more granular processing before jumping to massive data. This way, we would not cause **severe memory exhaustion** that may lead to **crashing of R sessions** or **worst silent data corruption if network is interrupted**.

Q3. If you were asked: “How many admissions in 2023 occurred in Very Remote Queensland facilities?” Conceptually, outline which tables are involved and what considerations would you need to be careful about? (No need to write SQL — just explain your reasoning).

_Respond_: The tables that will be involve are the `admission` and `facility` using their `admission.facility_id` and `facility.facility_id` with the condition of the facility.remoteness is the "Very Remote" and facility.state is "Queensland" to get the list of facility_id that belongs to the condition. Using the result of this, I would then **COUNT** the number of admission under the `admission.facility_id` in `facility.facility_id`.
