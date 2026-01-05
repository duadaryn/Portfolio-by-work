# 1. список клиентов с непрерывной историей за год, то есть каждый месяц на регулярной основе без пропусков за указанный
# годовой период, средний чек за период с 01.06.2015 по 01.06.2016, средняя сумма покупок за месяц, количество 
# всех операций по клиенту за период;

SELECT
t.ID_client
FROM transactions t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY t.ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) = 12;

SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    AVG(Sum_payment) AS avg_check,
    COUNT(Id_check) AS total_operations,
    COUNT(DISTINCT ID_client) AS active_clients
FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month
ORDER BY month;

#2. информацию в разрезе месяцев:
#средняя сумма чека в месяц;

SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    AVG(Sum_payment) AS avg_check
FROM transactions
GROUP BY month
ORDER BY month;

#среднее количество операций в месяц;

SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(Id_check) AS operations_count
FROM transactions
GROUP BY month
ORDER BY month;

#среднее количество клиентов, которые совершали операции;

SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(DISTINCT ID_client) AS active_clients
FROM transactions
GROUP BY month
ORDER BY month;

#долю от общего количества операций за год ;

SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(Id_check) /
    (SELECT COUNT(*) 
     FROM transactions
     WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS operations_share
FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month;

# и долю в месяц от общей суммы операций

SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    SUM(Sum_payment) /
    (SELECT SUM(Sum_payment)
     FROM transactions
     WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS revenue_share
FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month;

# вывести % соотношение M/F/NA в каждом месяце с их долей затрат;

SELECT
    DATE_FORMAT(t.date_new, '%Y-%m') AS month,
    IFNULL(c.Gender, 'NA') AS gender,
    COUNT(DISTINCT t.ID_client) AS clients_cnt,
    SUM(t.Sum_payment) AS total_spend,
    SUM(t.Sum_payment) /
        SUM(SUM(t.Sum_payment)) OVER (PARTITION BY DATE_FORMAT(t.date_new, '%Y-%m')) AS spend_share
FROM transactions t
LEFT JOIN customers_final c ON t.ID_client = c.Id_client
GROUP BY month, gender
ORDER BY month, gender;

# 3. возрастные группы клиентов с шагом 10 лет и отдельно клиентов, у которых нет данной информации, 


SELECT
    CASE
        WHEN c.Age IS NULL THEN 'NA'
        WHEN c.Age < 10 THEN '0-9'
        WHEN c.Age < 20 THEN '10-19'
        WHEN c.Age < 30 THEN '20-29'
        WHEN c.Age < 40 THEN '30-39'
        WHEN c.Age < 50 THEN '40-49'
        WHEN c.Age < 60 THEN '50-59'
        ELSE '60+'
    END AS age_group
    
FROM transactions t
LEFT JOIN customers_final c
ON t.ID_client = c.Id_client
GROUP BY age_group;

# с параметрами сумма и количество операций за весь период

SELECT
    CASE
        WHEN c.Age IS NULL THEN 'NA'
        WHEN c.Age < 10 THEN '0-9'
        WHEN c.Age < 20 THEN '10-19'
        WHEN c.Age < 30 THEN '20-29'
        WHEN c.Age < 40 THEN '30-39'
        WHEN c.Age < 50 THEN '40-49'
        WHEN c.Age < 60 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    COUNT(t.Id_check) AS operations,
    SUM(t.Sum_payment) AS total_sum
FROM transactions t
LEFT JOIN customers_final c 
    ON t.ID_client = c.Id_client
GROUP BY age_group;

# и поквартально - средние показатели и %.
SELECT
    CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter,
    CASE
        WHEN c.Age IS NULL THEN 'NA'
        WHEN c.Age < 10 THEN '0-9'
        WHEN c.Age < 20 THEN '10-19'
        WHEN c.Age < 30 THEN '20-29'
        WHEN c.Age < 40 THEN '30-39'
        WHEN c.Age < 50 THEN '40-49'
        WHEN c.Age < 60 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    AVG(t.Sum_payment) AS avg_check,
    COUNT(t.Id_check) AS operations,
    SUM(t.Sum_payment) /
      SUM(SUM(t.Sum_payment)) OVER (PARTITION BY CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new))) AS revenue_share
FROM transactions t
LEFT JOIN customers_final c ON t.ID_client = c.Id_client
GROUP BY quarter, age_group
ORDER BY quarter, age_group;
