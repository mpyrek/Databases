-- 1. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza
-- library). Interesuje nas imię, nazwisko i data urodzenia dziecka.
SELECT m.lastname,m.firstname,m.middleinitial,j.birth_date
FROM juvenile as j
INNER JOIN member m on m.member_no = j.member_no

-- 2. Napisz polecenie, które podaje tytuły aktualnie wypożyczonych książek
SELECT DISTINCT title
FROM copy
INNER JOIN title t on copy.title_no = t.title_no
WHERE on_loan='Y'

-- 3. Podaj informacje o karach zapłaconych za przetrzymywanie książki o tytule ‘Tao
-- Teh King’. Interesuje nas data oddania książki, ile dni była przetrzymywana i jaką
-- zapłacono karę
SELECT in_date,DATEDIFF(day,in_date,due_date),ISNULL(fine_paid,0)
FROM loanhist
INNER JOIN title t on t.title_no = loanhist.title_no and t.title='Tao Teh King'
WHERE DATEDIFF(day,in_date,due_date) > 0

-- 4. Napisz polecenie które podaje listę książek (mumery ISBN) zarezerwowanych
-- przez osobę o nazwisku: Stephen A. Graff
SELECT r.isbn
FROM reservation AS r
INNER JOIN member m on m.member_no = r.member_no
WHERE m.lastname='Graff' AND m.middleinitial='A' and m.firstname='Stephen'
-------------------------------------------------------------------------------------
-- 1. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza
-- library). Interesuje nas imię, nazwisko, data urodzenia dziecka i adres
-- zamieszkania dziecka.
SELECT m.firstname,m.lastname,birth_date,a.state,a.city,a.street
FROM juvenile
INNER JOIN member m on m.member_no = juvenile.member_no
INNER JOIN adult a on a.member_no = juvenile.adult_member_no

-- 2. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza
-- library). Interesuje nas imię, nazwisko, data urodzenia dziecka, adres
-- zamieszkania dziecka oraz imię i nazwisko rodzica.

SELECT m.firstname,m.lastname,birth_date,a.state,a.city,a.street,m2.lastname,m2.firstname
FROM juvenile
INNER JOIN member m on m.member_no = juvenile.member_no
INNER JOIN adult a on a.member_no = juvenile.adult_member_no
INNER JOIN member m2 on m2.member_no = a.member_no

-------------------------------------------------------------------------------------
-- 3. Napisz polecenie, które wyświetla adresy członków biblioteki, którzy mają dzieci
-- urodzone przed 1 stycznia 1996
SELECT DISTINCT a.member_no,a.street,a.city,a.state
FROM adult AS a
INNER JOIN juvenile j on a.member_no = j.adult_member_no
WHERE j.birth_date< '1996/01/01'

-- 4. Napisz polecenie, które wyświetla adresy członków biblioteki, którzy mają dzieci
-- urodzone przed 1 stycznia 1996. Interesują nas tylko adresy takich członków
-- biblioteki, którzy aktualnie nie przetrzymują książek.
SELECT DISTINCT a.member_no,a.street,a.city,a.state
FROM adult AS a
INNER JOIN juvenile j on a.member_no = j.adult_member_no
INNER JOIN member m on m.member_no = a.member_no
INNER JOIN loan l on m.member_no = l.member_no
WHERE j.birth_date< '1996/01/01' AND  DATEDIFF(day,due_date,GETDATE())>=0

-----------------------------------------------------------------------------------------
-- 1. Napisz polecenie które zwraca imię i nazwisko (jako pojedynczą kolumnę –
-- name), oraz informacje o adresie: ulica, miasto, stan kod (jako pojedynczą
-- kolumnę – address) dla wszystkich dorosłych członków biblioteki
SELECT m.firstname+' '+m.firstname AS name,state+' '+street+' '+city as adress
FROM adult
INNER JOIN member m on m.member_no = adult.member_no

-- 2. Napisz polecenie, które zwraca: isbn, copy_no, on_loan, title, translation, cover,
-- dla książek o isbn 1, 500 i 1000. Wynik posortuj wg ISBN
SELECT c.isbn,c.copy_no,c.on_loan,t.title,i.translation,i.cover
FROM copy AS c
INNER JOIN title t on t.title_no = c.title_no
INNER JOIN item i on i.isbn = c.isbn
WHERE c.isbn in (1,500,1000)
ORDER BY c.isbn

-- 3. Napisz polecenie które zwraca o użytkownikach biblioteki o nr 250, 342, i 1675
-- (dla każdego użytkownika: nr, imię i nazwisko członka biblioteki), oraz informację
-- o zarezerwowanych książkach (isbn, data)
SELECT m.member_no,m.firstname,m.lastname,r2.isbn,r2.log_date
FROM member as m
INNER JOIN reservation r2 on m.member_no = r2.member_no
WHERE m.member_no=250 or m.member_no=1675 or m.member_no=342

-- 4. Podaj listę członków biblioteki mieszkających w Arizonie (AZ) mają więcej niż
-- dwoje dzieci zapisanych do biblioteki
SELECT a.member_no,m.lastname,m.firstname,COUNT(j.member_no)
FROM adult as a
INNER JOIN member m on m.member_no = a.member_no
INNER JOIN juvenile j on a.member_no = j.adult_member_no
WHERE a.state='AZ'
GROUP BY a.member_no, m.lastname, m.firstname
HAVING COUNT(j.member_no)>2

-- Podaj listę członków biblioteki mieszkających w Arizonie (AZ) którzy mają więcej
-- niż dwoje dzieci zapisanych do biblioteki oraz takich którzy mieszkają w Kaliforni
-- (CA) i mają więcej niż troje dzieci zapisanych do biblioteki

SELECT a.member_no,m.lastname,m.firstname,COUNT(j.member_no)
FROM adult as a
INNER JOIN member m on m.member_no = a.member_no
INNER JOIN juvenile j on a.member_no = j.adult_member_no
GROUP BY a.member_no, m.lastname, m.firstname
HAVING (COUNT(j.member_no)>2 and max(state)='AZ') OR  (COUNT(j.member_no)>3 and max(state)='CA')