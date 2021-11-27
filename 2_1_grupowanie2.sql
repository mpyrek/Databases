-- 1. Ilu jest dorosłych członków biblioteki
SELECT COUNT(*)
FROM adult

-- 2. Ile jest dzieci zapisanych do biblioteki
SELECT COUNT(*)
FROM  juvenile

-- 3. Ilu z dorosłych członków biblioteki mieszka w Arizonie (AZ)
SELECT COUNT(*)
FROM adult
WHERE state='AZ'

-- 4. Dla każdego członka biblioteki podaj ile ma dzieci zapisanych do biblioteki
SELECT adult_member_no,COUNT(*)
FROM juvenile
GROUP BY adult_member_no

-- 5. Dla każdego tytułu podaj liczbę egzemplarzy
SELECT c.title_no,t.title,COUNT(*)
FROM copy AS c
INNER JOIN title t on t.title_no = c.title_no
GROUP BY  c.title_no,title

----------------------------------------------------------------------------------------
-- 1. Dla każdego członka biblioteki podaj liczbę zarezerwowanych przez niego
-- książek
SELECT member_no,COUNT(*)
FROM reservation
GROUP BY member_no

-- 2. Dla każdego członka biblioteki podaj liczbę wypożyczonych przez niego książek
SELECT member_no,COUNT(*)
FROM loan
GROUP BY member_no

-- 3. Dla każdego członka biblioteki podaj liczbę książek zwróconych przez niego w
-- 2001
SELECT member_no,COUNT(*)
FROM loanhist
WHERE YEAR(in_date)=2001
GROUP BY member_no

--------------------------------------------------------------------------------------------
-- 1. Na jak długo średnio są aktualnie wypożyczane książki
SELECT AVG(DATEDIFF(day ,out_date,in_date))
FROM loanhist

-- 2. Na jak długo średnio są aktualnie wypożyczane poszczególne tytuły
SELECT title_no, AVG(DATEDIFF(day ,out_date,in_date))
FROM loanhist
GROUP BY title_no
ORDER BY 1

-- 3. Na jak długo średnio były wypożyczane książki w maju 2001
SELECT CONCAT(ISNULL(AVG(DATEDIFF(day ,out_date,in_date)),0),' days')
FROM loanhist
WHERE MONTH(out_date)=5 AND YEAR(out_date)=2001
-------------------------------------------------------------------------------------
-- 1. Dla każdego czytelnika podaj łączną karę, którą zapłacił w 2001
SELECT member_no,SUM(ISNULL(fine_paid,0))
FROM loanhist
WHERE YEAR(out_date)=2001
GROUP BY member_no

-- 2. Który z tytułów był najczęściej wypożyczany w 2001r
SELECT TOP 1 title_no,COUNT(*)
FROM loanhist
WHERE YEAR(out_date)=2001
GROUP BY title_no
ORDER BY 2 DESC

-- 3. Który z tytułów był najczęściej oddawany po termini
SELECT TOP 1 title_no,COUNT(*)
FROM loanhist
WHERE  in_date > due_date
GROUP BY title_no
ORDER BY 2 DESC
