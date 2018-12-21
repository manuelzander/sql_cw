-- Q1 returns (name,father,mother)

SELECT name, father, mother
FROM person
WHERE dod IS NOT NULL
AND name IN (SELECT person.name
             FROM person AS parents
             WHERE person.father=parents.name
             AND person.dod<parents.dod
             )
AND name IN (SELECT person.name
             FROM person AS parents
             WHERE person.mother=parents.name
             AND person.dod<parents.dod
             )
ORDER BY name
;

-- Q2 returns (name)

SELECT name
FROM monarch
WHERE house IS NOT NULL
UNION
SELECT name
FROM prime_minister
ORDER BY name
;

-- Q3 returns (name)

SELECT monarch.name
FROM monarch JOIN person ON monarch.name=person.name
WHERE person.dod > SOME (SELECT monarch_2.accession
                         FROM monarch AS monarch_2
                         WHERE monarch_2.accession>monarch.accession
                         )
AND house IS NOT NULL
ORDER BY name
;

-- Q4 returns (house,name,accession)

SELECT house, name, accession
FROM monarch
WHERE monarch.accession < ALL (SELECT monarch_2.accession
                               FROM monarch AS monarch_2
                               WHERE monarch_2.house=monarch.house
                               AND monarch_2.accession<>monarch.accession
                               )
AND house IS NOT NULL
ORDER BY accession
;

-- Q5 returns (first_name,popularity)

SELECT first.first_name,
       COUNT(first.first_name) AS popularity
FROM (SELECT SUBSTRING(name FROM 1 FOR POSITION (' ' IN name)) AS first_name
      FROM person
      WHERE name like '% %'
      UNION ALL
      SELECT name
      FROM person
      WHERE name NOT like '% %') AS first
GROUP BY first.first_name
HAVING COUNT(first.first_name) > 1
ORDER BY popularity DESC, first.first_name ASC
;

-- Q6 returns (house,seventeenth,eighteenth,nineteenth,twentieth)

SELECT house,
       SUM(CASE WHEN accession > '1601-01-01' AND
                     accession < '1700-12-31' THEN 1 ELSE 0 END) AS seventeenth,
       SUM(CASE WHEN accession > '1701-01-01' AND
                     accession < '1800-12-31' THEN 1 ELSE 0 END) AS eighteenth,
       SUM(CASE WHEN accession > '1801-01-01' AND
                     accession < '1900-12-31' THEN 1 ELSE 0 END) AS nineteenth,
       SUM(CASE WHEN accession > '1901-01-01' AND
                     accession < '2000-12-31' THEN 1 ELSE 0 END) AS twentieth
FROM monarch
WHERE house IS NOT NULL
GROUP BY house
ORDER BY house
;

-- Q7 returns (father,child,born)

SELECT name AS father,
       ranking.child AS child,
       born
FROM person LEFT JOIN
     (SELECT name AS child, father,
             RANK() OVER (PARTITION BY father ORDER BY dob ASC) AS born
     FROM person
     WHERE father IS NOT NULL) AS ranking ON person.name = ranking.father
WHERE gender = 'M'
ORDER BY father, born
;

-- Q8 returns (monarch,prime_minister)

SELECT DISTINCT m.name AS monarch,
                p.name AS prime_minister
FROM monarch AS m CROSS JOIN prime_minister AS p
WHERE ((p.entry >= m.accession
AND p.entry <= ALL (SELECT monarch_2.accession
                    FROM monarch AS monarch_2
                    WHERE monarch_2.accession > m.accession
                    ))
OR (m.accession >= p.entry
AND p.entry >= ALL (SELECT MAX(prime_minister2.entry)
                    FROM prime_minister AS prime_minister2
                    WHERE prime_minister2.entry < m.accession
                    )))
AND house IS NOT NULL
ORDER BY monarch, prime_minister
;
