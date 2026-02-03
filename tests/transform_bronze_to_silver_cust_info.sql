INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_gndr,
    cst_material_status,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    -- Standardization Logic for Gender
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
    -- Standardization Logic for Marital Status
    CASE 
        WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married' 
        ELSE 'n/a'
    END AS cst_material_status,
    CAST(cst_create_date AS DATE) AS cst_create_date
FROM (
    SELECT
        *,
        -- Deduplication Logic: Keeps the most recent entry per cst_id
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flaglast
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE flaglast = 1; -- Filter only the most recent unique records
