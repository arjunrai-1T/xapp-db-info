--SQL Query to Exclude Deleted Categories With Showing IS_DELETED
SELECT 
    uc1.CATEGORY_NAME AS Category,
    uc2.CATEGORY_NAME AS Subcategory,
    uc1.IS_DELETED AS Is_Deleted_Category,
    uc2.IS_DELETED AS Is_Deleted_Subcategory
FROM 
    USER_CATEGORIES uc1
LEFT JOIN 
    USER_CATEGORIES uc2 ON uc1.CATEGORY_NAME = uc2.PARENT_CATEGORY_NAME
WHERE 
    uc1.IS_DELETED = FALSE  -- Only include active categories
ORDER BY 
    uc1.CATEGORY_NAME, uc2.CATEGORY_NAME;
    
--SQL Query to Exclude Deleted Categories Without Showing IS_DELETED
SELECT 
    uc1.CATEGORY_NAME AS Category,
    uc2.CATEGORY_NAME AS Subcategory
FROM 
    USER_CATEGORIES uc1
LEFT JOIN 
    USER_CATEGORIES uc2 ON uc1.CATEGORY_NAME = uc2.PARENT_CATEGORY_NAME
WHERE 
    uc1.IS_DELETED = FALSE  -- Only include active categories
    AND (uc2.IS_DELETED = FALSE OR uc2.IS_DELETED IS NULL)  -- Include active subcategories or NULL
ORDER BY 
    uc1.CATEGORY_NAME, uc2.CATEGORY_NAME;

--SQL Query to Display Categories with Permissions
SELECT 
    uc.CATEGORY_NAME AS Category,
    rp.PERMISSION_ID,
    p.PERMISSION_NAME
FROM 
    USER_CATEGORIES uc
LEFT JOIN 
    ROLE_PERMISSIONS rp ON uc.CATEGORY_NAME = rp.ROLE_NAME
LEFT JOIN 
    PERMISSIONS p ON rp.PERMISSION_ID = p.PERMISSION_ID
WHERE 
    uc.IS_DELETED = FALSE  -- Only include active categories
ORDER BY 
    uc.CATEGORY_NAME, p.PERMISSION_NAME;


--SQL Query to List Admin Permissions as JSON Format
SELECT 
    uc.CATEGORY_NAME AS Role,
    JSON_AGG(p.PERMISSION_NAME) AS Permissions
FROM 
    USER_CATEGORIES uc
JOIN 
    ROLE_PERMISSIONS rp ON uc.CATEGORY_NAME = rp.ROLE_NAME
JOIN 
    PERMISSIONS p ON rp.PERMISSION_ID = p.PERMISSION_ID
WHERE 
    uc.CATEGORY_NAME = 'Admin'  -- Filter for the Admin role
    AND uc.IS_DELETED = FALSE    -- Ensure the category is active
GROUP BY 
    uc.CATEGORY_NAME;

--SQL Query to List All Roles with Their Permissions as JSON Format
SELECT 
    uc.CATEGORY_NAME AS Role,
    JSON_AGG(p.PERMISSION_NAME) AS Permissions
FROM 
    USER_CATEGORIES uc
JOIN 
    ROLE_PERMISSIONS rp ON uc.CATEGORY_NAME = rp.ROLE_NAME
JOIN 
    PERMISSIONS p ON rp.PERMISSION_ID = p.PERMISSION_ID
WHERE 
    uc.IS_DELETED = FALSE  -- Ensure the category is active
GROUP BY 
    uc.CATEGORY_NAME
ORDER BY 
    uc.CATEGORY_NAME;

--SQL Query to List All Roles with Their Permissions, Including Roles Without Permissions as JSON Format
SELECT 
    uc.CATEGORY_NAME AS Role,
    COALESCE(JSON_AGG(p.PERMISSION_NAME) FILTER (WHERE p.PERMISSION_NAME IS NOT NULL), '[]') AS Permissions
FROM 
    USER_CATEGORIES uc
LEFT JOIN 
    ROLE_PERMISSIONS rp ON uc.CATEGORY_NAME = rp.ROLE_NAME
LEFT JOIN 
    PERMISSIONS p ON rp.PERMISSION_ID = p.PERMISSION_ID
WHERE 
    uc.IS_DELETED = FALSE  -- Ensure the category is active
GROUP BY 
    uc.CATEGORY_NAME
ORDER BY 
    uc.CATEGORY_NAME;
