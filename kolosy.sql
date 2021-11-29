--zadanie 3
-- 3)Dla każdego dziecka zapisanego w bibliotece wyświetl jego imię i nazwisko,
-- adres zamieszkania, imię i nazwisko rodzica (opiekuna) oraz liczbę wypożyczonych
-- książek w grudniu 2001 roku przez dziecko i opiekuna. *) Uwzględnij tylko te dzieci,
-- dla których liczba wypożyczonych książek jest większa od 1

SELECT m.member_no,m.firstname,m.lastname,j.adult_member_no,a.member_no,m2.firstname,m2.lastname,
       (SELECT COUNT(*) FROM loanhist AS l
       WHERE m.member_no=l.member_no and YEAR(l.out_date)=2001 and MONTH(l.out_date)=12
        GROUP BY l.member_no) +
        ISNULL((SELECT COUNT(*) FROM loanhist AS l
       WHERE m2.member_no=l.member_no and YEAR(l.out_date)=2001 and MONTH(l.out_date)=12
        GROUP BY l.member_no),0)
FROM juvenile as j
INNER JOIN member m on m.member_no = j.member_no
INNER JOIN adult a on a.member_no = j.adult_member_no
INNER JOIN member m2 on m2.member_no = a.member_no
WHERE (SELECT COUNT(*) FROM loanhist AS l
       WHERE m.member_no=l.member_no and YEAR(l.out_date)=2001 and MONTH(l.out_date)=12
        GROUP BY l.member_no) >1

SELECT ch.member_no, ch.firstname, ch.lastname, j.adult_member_no, par.member_no, par.firstname, par.lastname,

	(ISNULL((SELECT COUNT (*) FROM loanhist as lh
		WHERE lh.member_no = ch.member_no AND YEAR(lh.out_date) = 2001 AND MONTH(lh.out_date) = 12
	    GROUP BY member_no), 0) + ISNULL((SELECT COUNT (*)
		FROM loanhist as lh WHERE lh.member_no = par.member_no AND YEAR(lh.out_date) = 2001 AND MONTH(lh.out_date) = 12 GROUP BY member_no), 0)) as total

	FROM juvenile AS j JOIN member AS ch ON j.member_no = ch.member_no
	JOIN adult as a ON j.adult_member_no = a.member_no
	JOIN member as par ON a.member_no = par.member_no

	WHERE (SELECT COUNT (*) FROM loanhist as lh
		WHERE lh.member_no = ch.member_no AND YEAR(lh.out_date) = 2001 AND MONTH(lh.out_date) = 12 GROUP BY member_no) > 1

-- Podaj listę członków biblioteki (imię, nazwisko) mieszkających w Arizonie (AZ), którzy mają
-- więcej niż dwoje dzieci zapisanych do biblioteki oraz takich, którzy mieszkają w Kalifornii (CA)
-- i mają więcej niż troje dzieci zapisanych do bibliotek. Dla każdej z tych osób podaj liczbę książek
-- przeczytanych (oddanych) przez daną osobę i jej dzieci w grudniu 2001 (użyj operatora union).

SELECT m.member_no,m.firstname,m.lastname,
       (SELECT COUNT(*) FROM juvenile AS j WHERE j.adult_member_no=a.member_no),
       (SELECT COUNT(*) FROM loanhist AS l WHERE (l.member_no=a.member_no OR l.member_no IN
           (SELECT j.member_no FROM juvenile AS j WHERE j.adult_member_no=a.member_no)) AND
                YEAR(l.in_date)=2001 AND MONTH(l.in_date)=12)
FROM adult AS a
INNER JOIN member m on m.member_no = a.member_no
WHERE (SELECT COUNT(*) FROM juvenile AS j WHERE j.adult_member_no=m.member_no)>2 AND a.state='AZ'
UNION
SELECT m.member_no,m.firstname,m.lastname,
       (SELECT COUNT(*) FROM juvenile AS j WHERE j.adult_member_no=a.member_no),
       (SELECT COUNT(*) FROM loanhist AS l WHERE ( l.member_no=a.member_no OR l.member_no IN
           (SELECT j.member_no FROM juvenile AS j WHERE j.adult_member_no=a.member_no)) AND
                YEAR(l.in_date)=2001 AND MONTH(l.in_date)=12)
FROM adult AS a
INNER JOIN member m on m.member_no = a.member_no
WHERE (SELECT COUNT(*) FROM juvenile AS j WHERE j.adult_member_no=a.member_no)>3 AND a.state='CA'


---------------------------------------------------------------------------------------------


--1)
-- Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki. Interesuje nas imię, nazwisko,
-- data urodzenia dziecka, adres zamieszkania, imię i nazwisko rodzica oraz liczba aktualnie wypożyczonych książek.

SELECT j.member_no,m.lastname,m.firstname,j.birth_date,a.street,a.state,a.city,m2.firstname,m2.lastname,
       (SELECT COUNT(*) FROM loan AS l where l.member_no=j.member_no)
FROM juvenile AS j
INNER JOIN member m on m.member_no = j.member_no
INNER JOIN adult a on a.member_no = j.adult_member_no
INNER JOIN member m2 on m2.member_no = a.member_no


--4)
-- Podaj listę człownków biblioteki (imię, nazwisko) mieszkających w Arizonie (AZ), którzy mają
-- więcej niż dwoje dzieci zapisanych do biblioteki oraz takich, którzy mieszkają w Kalifornii (CA)
-- i mają więcej niż troje dzieci zapisanych do bibliotek. Dla każdej z tych osób podaj liczbę książek
-- przeczytanych (oddanych) przez daną osobę i jej dzieci w grudniu 2001 (bez użycia union).

SELECT a.member_no,m.firstname,m.lastname,COUNT(*),(SELECT COUNT(*) FROM loanhist AS l WHERE (l.member_no=a.member_no OR l.member_no IN
                                                (SELECT j.member_no FROM juvenile AS j WHERE j.adult_member_no=a.member_no)) AND YEAR(l.in_date)=2001 AND MONTH(l.in_date)=12 )
FROM adult as a
INNER JOIN member m on m.member_no = a.member_no
INNER JOIN juvenile j on a.member_no = j.adult_member_no
GROUP BY a.member_no, m.lastname, m.firstname
HAVING (max(a.state)='AZ' and COUNT(*)>2) OR (max(a.state)='CA' and COUNT(*)>3)


-- 2) Podaj listę wszystkich dorosłych, którzy mieszkają w Arizonie i mają dwójkę dzieci zapisanych do biblioteki oraz listę dorosłych, mieszkających w Kalifornii
-- i mają 3 dzieci. Dla każdej z tych osób podaj liczbę książek przeczytanych w grudniu 2001 przez tę osobę i jej dzieci. (Arizona - 'AZ', Kalifornia - 'CA'

SELECT m.firstname,m.lastname,(SELECT COUNT(*) FROM loanhist AS l
                            WHERE (l.member_no=m.member_no OR l.member_no IN (SELECT j.member_no FROM juvenile AS J where j.adult_member_no=m.member_no))
                              AND YEAR(in_date)=2001 AND MONTH(in_date)=12)
FROM adult AS a
INNER JOIN member m on m.member_no = a.member_no
INNER JOIN juvenile j on a.member_no = j.adult_member_no
WHERE a.state='AZ'
GROUP BY m.member_no,m.firstname, m.lastname
HAVING COUNT(*) = 2
UNION
SELECT m.firstname,m.lastname,(SELECT COUNT(*) FROM loanhist AS l
                            WHERE (l.member_no=m.member_no OR l.member_no IN (SELECT j.member_no FROM juvenile AS J where j.adult_member_no=m.member_no))
                              AND YEAR(in_date)=2001 AND MONTH(in_date)=12)
FROM adult AS a
INNER JOIN member m on m.member_no = a.member_no
INNER JOIN juvenile j on a.member_no = j.adult_member_no
WHERE a.state='CA'
GROUP BY m.member_no,m.firstname, m.lastname
HAVING COUNT(*) = 3


--. Wypisz wszystkich członków biblioteki z adresami i info czy jest dzieckiem czy nie i
--ilość wypożyczeń w poszczególnych latach i miesiącach.

SELECT m.member_no,m.firstname,m.lastname,a.state,a.city,a.street,'Jestem dorosły' as czy_dziecko,YEAR(l2.out_date),MONTH(l2.out_date),ISNULL(COUNT(l2.out_date),0)
FROM adult AS a
INNER JOIN member m on m.member_no = a.member_no
LEFT JOIN loanhist l2 on a.member_no = l2.member_no
GROUP BY m.member_no, m.firstname, m.lastname, YEAR(l2.out_date), MONTH(l2.out_date),a.state,a.city,a.street
UNION
SELECT m.member_no,m.firstname,m.lastname,a.state,a.city,a.street,'Jestem dzieckiem' as czy_dziecko,YEAR(l2.out_date),MONTH(l2.out_date),ISNULL(COUNT(l2.out_date),0)
FROM juvenile AS j
INNER JOIN member m on m.member_no = j.member_no
INNER JOIN adult a on a.member_no = j.adult_member_no
LEFT JOIN loanhist l2 on j.member_no = l2.member_no
GROUP BY m.member_no, m.firstname, m.lastname, YEAR(l2.out_date), MONTH(l2.out_date),a.state,a.city,a.street


--------------
-- . Wypisać wszystkich czytelników, którzy nigdy nie wypożyczyli książki dane
-- adresowe i podział czy ta osoba jest dzieckiem (joiny, in, exists)

SELECT m.member_no, m.lastname,m.firstname
FROM member AS m
left join loan l on m.member_no = l.member_no
left join loanhist l2 on m.member_no = l2.member_no
WHERE l2.member_no is null and l.member_no is null

SELECT m.member_no,m.lastname,m.firstname
FROM member AS m
WHERE m.member_no NOT IN (SELECT DISTINCT lh.member_no FROM loanhist AS lh UNION SELECT l.member_no FROM loan AS l)

SELECT m.member_no,m.lastname,m.firstname
FROM member AS m
WHERE NOT EXISTS (SELECT lh.member_no FROM loanhist AS lh WHERE lh.member_no=m.member_no UNION SELECT l.member_no FROM loan AS l WHERE l.member_no=m.member_no )

-- 4. Dla każdego czytelnika imię nazwisko, suma książek wypożyczony przez tą osobę i
-- jej dzieci, który żyje w Arizona ma mieć więcej niż 2 dzieci lub kto żyje w Kalifornii
-- ma mieć więcej niż 3 dzieci
SELECT m.member_no,m.firstname,m.lastname,(SELECT COUNT(*) FROM loanhist WHERE m.member_no=loanhist.member_no OR
                                            loanhist.member_no IN (SELECT juvenile.member_no FROM juvenile WHERE juvenile.adult_member_no=m.member_no))+
                                          (SELECT COUNT(*) FROM loan WHERE loan.member_no=m.member_no OR
                                            loan.member_no IN (SELECT juvenile.member_no FROM juvenile WHERE juvenile.adult_member_no=m.member_no))
FROM member AS m
INNER JOIN adult a on m.member_no = a.member_no
WHERE (a.state='AZ' and (SELECT COUNT(*) FROM juvenile AS j WHERE j.adult_member_no=m.member_no)>2) OR
(a.state='CA' and (SELECT COUNT(*) FROM juvenile AS j WHERE j.adult_member_no=m.member_no)>3)


--1. Jaki był najpopularniejszy autor wśród dzieci w Arizonie w 2001
SELECT TOP 1 t.author,COUNT(*)
FROM juvenile AS j
INNER JOIN adult a on a.member_no = j.adult_member_no and a.state='AZ'
INNER JOIN loanhist l on j.member_no = l.member_no AND YEAR(out_date)=2001
INNER JOIN title t on l.title_no = t.title_no
GROUP BY t.author
ORDER BY 2 desc

--. Dla każdego dziecka wybierz jego imię nazwisko, adres, imię i nazwisko rodzica i ilość książek, które oboje przeczytali w 2001
SELECT m.lastname,m.firstname,a.state,a.street,a.city, m2.firstname,m2.lastname,
       (SELECT COUNT(*) FROM loanhist AS lh WHERE lh.member_no=m2.member_no OR lh.member_no=m.member_no AND YEAR(in_date)=2001)
FROM juvenile AS j
INNER JOIN member m on m.member_no = j.member_no
INNER JOIN adult a on a.member_no = j.adult_member_no
INNER JOIN member m2 on m2.member_no = a.member_no

-- 1. Wybierz dzieci wraz z adresem, które nie wypożyczyły książek w lipcu 2001
-- autorstwa ‘Jane Austin’

SELECT DISTINCT m.member_no,m.lastname,m.firstname,a.city,a.street,a.state
FROM juvenile AS J
INNER JOIN adult a on a.member_no = J.adult_member_no
INNER JOIN member m on m.member_no = a.member_no
WHERE m.member_no NOT IN (SELECT lh.member_no FROM juvenile AS j2
                            INNER JOIN loanhist lh on j2.member_no = lh.member_no
                            AND YEAR(lh.out_date)=2001 AND MONTH(lh.out_date)=7
                            INNER JOIN title t on t.title_no = lh.title_no AND t.author='Jane Austin')

--4. Wybierz tytuły książek, gdzie ilość wypożyczeń książki jest większa od średniej ilości wypożyczeń książek tego samego autora.
SELECT t2.title
FROM loanhist as lh
INNER JOIN title t2 on t2.title_no = lh.title_no
join
    (SELECT tab.author,AVG(tab.suma) as suma2
    FROM
        (SELECT t.author,t.title,COUNT(*) as suma
        FROM loanhist as lh
        INNER JOIN title t on t.title_no = lh.title_no
        GROUP BY t.author, t.title) as tab
    GROUP BY tab.author) as tab2 on tab2.author=t2.author
WHERE tab2.suma2 < (SELECT COUNT(*)
                    FROM loanhist as lh2
                    where lh2.title_no=lh.title_no
                    GROUP BY lh2.title_no)


;with uwu as (
    SELECT t.author,t.title,COUNT(*) as suma
        FROM loanhist as lh
        INNER JOIN title t on t.title_no = lh.title_no
        GROUP BY t.author, t.title
),
uwu2 as (
    SELECT author,AVG(suma) as avg
    FROM uwu
    GROUP BY author
)
SELECT title
FROM uwu
join uwu2 on uwu.author=uwu2.author
WHERE avg<suma



