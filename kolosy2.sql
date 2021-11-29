-- 1)Dla każdego klienta znajdź wartość wszystkich złożonych zamówień (weź pod uwagę koszt przesyłki)
--z wiki
SELECT C.CustomerID,C.CompanyName,ISNULL(SUM([O D].UnitPrice*[O D].Quantity*(1-[O D].Discount)),0)+
                                  ISNULL(SUM(O.Freight),0)
FROM Customers AS C
LEFT JOIN Orders O on C.CustomerID = O.CustomerID
LEFT JOIN [Order Details] as [O D] on O.OrderID = [O D].OrderID
GROUP BY C.CustomerID, C.CompanyName



--moje
SELECT C.CustomerID,C.CompanyName,ISNULL(KOSZT.suma+wysyłka.suma,0)
FROM Customers AS C
LEFT JOIN (SELECT O.CustomerID, ISNULL(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),0) As suma
    FROM [Order Details] AS OD
    LEFT JOIN Orders O on OD.OrderID = O.OrderID
    GROUP BY O.CustomerID
    ) AS KOSZT on C.CustomerID=KOSZT.CustomerID
LEFT JOIN ( SELECT O.CustomerID,ISNULL(SUM(O.Freight),0) as suma
    FROM Orders AS O
    GROUP BY O.CustomerID
    ) AS wysyłka on wysyłka.CustomerID=C.CustomerID


SELECT C.CustomerID,C.CompanyName,
       (SELECT ISNULL(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),0) FROM [Order Details] AS OD
         LEFT JOIN Orders O on O.OrderID = OD.OrderID WHERE O.CustomerID=C.CustomerID)+
        (SELECT ISNULL(SUM(O.Freight),0) FROM Orders AS O WHERE O.CustomerID=C.CustomerID)
FROM Customers AS C

-- 2)Czy są jacyś klienci, którzy nie złożyli żadnego zamówienia w 1997 roku? Jeśli tak, wyświetl ich dane
-- adresowe. Wykonaj za pomocą operatorów:
-- a)join b)in c)exist
--join

SELECT C.CustomerID, C.CompanyName,C.Address,C.PostalCode,C.City,C.Country
FROM Customers AS C
LEFT JOIN Orders O on C.CustomerID = O.CustomerID AND YEAR(OrderDate)=1997
WHERE O.OrderID IS NULL

--in
SELECT C.CustomerID, C.CompanyName,C.Address,C.PostalCode,C.City,C.Country
FROM Customers AS C
WHERE C.CustomerID NOT IN (
    SELECT O.CustomerID FROM Orders AS O WHERE YEAR(O.OrderDate)=1997
    )

--exist
SELECT C.CustomerID, C.CompanyName,C.Address,C.PostalCode,C.City,C.Country
FROM Customers AS C
WHERE NOT EXISTS (
    SELECT * FROM Orders AS O WHERE O.CustomerID=C.CustomerID and  YEAR(O.OrderDate)=1997
    )

-----------------------------------------------------------------------------------------------
-- 4)Dla każdej kategorii produktów wypisz po miesiącach wartość sprzedanych z niej produktów.
-- Interesują nas tylko lata 1996-1997

SELECT C.CategoryName,YEAR(O.OrderDate),MONTH(O.OrderDate),SUM([O D].UnitPrice*(1-Discount)*Quantity)
FROM Categories AS C
INNER JOIN Products P on C.CategoryID = P.CategoryID
INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
INNER JOIN Orders O on O.OrderID = [O D].OrderID
WHERE YEAR(O.OrderDate)=1996 or YEAR(O.OrderDate)=1997
GROUP BY  C.CategoryName, MONTH(O.OrderDate),YEAR(O.OrderDate)
ORDER BY 1,2,3
--------------------------------------------------------------------------------------------------------
--GRUPA A

-- Dla każdego produktu podaj nazwę jego kategorii, nazwę produktu, cenę, średnią cenę wszystkich
-- produktów danej kategorii, różnicę między ceną produktu a średnią ceną wszystkich produktów
-- danej kategorii, dodatkowo dla każdego produktu podaj wartośc jego sprzedaży w marcu 1997

SELECT P.ProductID,P.ProductName,C.CategoryName,P.UnitPrice,
       (SELECT AVG(P2.UnitPrice) FROM Products AS P2 WHERE P2.CategoryID=P.CategoryID),
       (P.UnitPrice-(SELECT AVG(P2.UnitPrice) FROM Products AS P2 WHERE P2.CategoryID=P.CategoryID)),
       (SELECT ISNULL(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),0)
           FROM [Order Details] AS OD
           INNER JOIN Orders O on O.OrderID = OD.OrderID
           WHERE OD.ProductID=P.ProductID AND YEAR(O.OrderDate)=1997 AND MONTH(O.OrderDate)=3)
FROM Products AS P
INNER JOIN Categories C on C.CategoryID = P.CategoryID


----------------------------------------------------------------
-- Dla każdego pracownika (imie i nazwisko) podaj łączną wartość zamówień obsłużonych
-- przez tego pracownika (z ceną za przesyłkę). Uwzględnij tylko pracowników, którzy mają podwładnych.

SELECT E.EmployeeID,E.FirstName,E.LastName,
      (SELECT ISNULL(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),0)
          FROM [Order Details] AS OD
          LEFT JOIN Orders O on O.OrderID = OD.OrderID
          WHERE E.EmployeeID=O.EmployeeID)
    +(SELECT ISNULL(SUM(O.Freight),0) FROM Orders AS O
        WHERE E.EmployeeID=O.EmployeeID)
FROM Employees AS E
INNER JOIN Employees E2 on E2.ReportsTo = E.EmployeeID
WHERE E2.EmployeeID IS NOT NULL
GROUP BY E.EmployeeID, E.FirstName, E.LastName


--3
-- Czy są jacyś klienci, którzy nie złożyli żadnego zamówienia w 1997, jeśli tak pokaż
--ich nazwy i dane adresowe (3 wersje - join, in, exists).
SELECT  C.CustomerID,C.CompanyName,C.Country,C.City,C.Address,C.PostalCode
FROM Customers AS C
LEFT JOIN Orders O on C.CustomerID = O.CustomerID AND YEAR(O.OrderDate)=1997
WHERE O.OrderID IS NULL

SELECT C.CustomerID,C.CompanyName,C.Country,C.City,C.Address,C.PostalCode
FROM Customers AS C
WHERE C.CustomerID NOT IN (SELECT O.CustomerID FROM Orders AS O WHERE YEAR(O.OrderDate)=1997)

SELECT C.CustomerID,C.CompanyName,C.Country,C.City,C.Address,C.PostalCode
FROM Customers AS C
WHERE NOT EXISTS (SELECT * FROM Orders AS O WHERE YEAR(O.OrderDate)=1997 AND O.CustomerID=C.CustomerID)
------------------------------------------------------------------------------------------
--2)
-- Dla każdego pracownika (imie i nazwisko) podaj łączną wartość zamówień obsłużonych
-- przez tego pracownika (z ceną za przesyłkę). * Uwzględnij tylko pracowników, którzy nie mają podwładnych.
SELECT E.LastName,E.FirstName,
       (SELECT ISNULL(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),0) FROM [Order Details] AS OD
           LEFT JOIN Orders O on O.OrderID = OD.OrderID AND O.EmployeeID=E.EmployeeID) +
        (SELECT ISNULL(SUM(O.Freight),0) FROM Orders AS O WHERE O.EmployeeID=E.EmployeeID)
FROM Employees AS E
LEFT JOIN Employees AS E2 on E2.ReportsTo=E.EmployeeID
WHERE E2.EmployeeID IS NULL

--3)
-- Czy są jacyś klienci, którzy nie złożyli żadnego zamówienia w 1997, jeśli tak pokaż
-- ich nazwy i dane adresowe (3 wersje - join, in, exists).
SELECT DISTINCT C.CustomerID,C.CompanyName,C.Address,C.City,C.PostalCode,C.Country
FROM Customers AS C
LEFT JOIN Orders O on C.CustomerID = O.CustomerID AND YEAR(O.OrderDate)=1997
WHERE O.OrderID IS NULL

SELECT C.CustomerID,C.CompanyName,C.Address,C.City,C.PostalCode,C.Country
FROM Customers AS C
WHERE C.CustomerID NOT IN (SELECT O.CustomerID FROM Orders AS O WHERE YEAR(O.OrderDate)=1997)

SELECT C.CustomerID,C.CompanyName,C.Address,C.City,C.PostalCode,C.Country
FROM Customers AS C
WHERE NOT EXISTS( SELECT * FROM Orders AS O WHERE YEAR(O.OrderDate)=1997 AND O.CustomerID=C.CustomerID)


--????????????????????????????????- 1) Dla każdego pracownika, który ma podwładnego podaj wartość obsłużonych przez niego przesyłek w grudniu 1997. Uwzględnij rabat i opłatę za przesyłkę.
SELECT DISTINCT E.EmployeeID,E.LastName,E.FirstName,
       (SELECT ISNULL(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),0) FROM [Order Details] AS OD
           LEFT JOIN Orders O on O.OrderID = OD.OrderID AND O.EmployeeID=E.EmployeeID AND YEAR(O.OrderDate)=1997 AND MONTH(O.OrderDate)=12)+
        (SELECT ISNULL(SUM(Freight),0)  FROM Orders AS O WHERE O.EmployeeID=E.EmployeeID AND YEAR(O.OrderDate)=1997 AND MONTH(O.OrderDate)=12)
FROM Employees AS E
INNER JOIN Employees AS E2 on E2.ReportsTo=E.EmployeeID

--z wiki
SELECT b.EmployeeID, b.LastName, b.FirstName,
	(SELECT SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) + SUM(o.Freight)
		FROM [Order Details] as od JOIN Orders AS o ON od.OrderID = o.OrderID
		WHERE o.EmployeeID = b.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(O.OrderDate) = 12) AS 'WartoscZamowien'
	 FROM Employees AS e JOIN Employees AS b ON e.ReportsTo = b.EmployeeID
	 GROUP BY b.EmployeeID, b.LastName, b.FirstName

-----------------------------------------------------------------------------------------------------------------------------

-- 4) Podaj nazwy produktów, które nie były sprzedawane w marcu 1997.
SELECT P.ProductName
FROM Products AS P
WHERE P.ProductID NOT IN ( SELECT DISTINCT OD.ProductID FROM [Order Details] AS OD
                            INNER JOIN Orders O on O.OrderID = OD.OrderID AND YEAR(O.OrderDate)=1997 AND MONTH(O.OrderDate)=3)

--------------------------------------------------------------------------------
--Zamówienia z Freight większym niż AVG danego roku
SELECT O.OrderID,O.Freight
FROM Orders AS O
WHERE O.Freight > (SELECT AVG(O2.Freight) FROM Orders AS O2 WHERE YEAR(O2.OrderID)=YEAR(O.OrderID))

--3. Klienci, którzy nie zamówili nigdy nic z kategorii 'Seafood' w trzech wersjach
SELECT C.CustomerID,C.CompanyName
FROM Customers AS C
WHERE C.CustomerID NOT IN (SELECT O.CustomerID FROM Orders AS O
                            INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
                            INNER JOIN Products P on P.ProductID = [O D].ProductID
                            INNER JOIN Categories C2 on C2.CategoryID = P.CategoryID AND C2.CategoryName='Seafood'
    )

--4. Dla każdego klienta najczęściej zamawianą kategorię w dwóch wersjach.
SELECT C3.CustomerID,C3.CompanyName,(SELECT TOP 1 C2.CategoryName
FROM Customers AS C
INNER JOIN Orders O on C.CustomerID = O.CustomerID
INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
INNER JOIN Products P on P.ProductID = [O D].ProductID
INNER JOIN Categories C2 on C2.CategoryID = P.CategoryID
WHERE C3.CustomerID=C.CustomerID
GROUP BY C.CustomerID, C.CompanyName, C2.CategoryName
ORDER BY COUNT(*) DESC)
FROM Customers AS C3

--1. Podział na company, year month i suma freight
SELECT C.CustomerID,C.CompanyName,YEAR(O.OrderDate),MONTH(O.OrderDate),
       (SELECT ISNULL(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),0) FROM [Order Details] AS OD
           LEFT JOIN Orders O2 on O2.OrderID = OD.OrderID and O2.CustomerID=C.CustomerID AND YEAR(O2.OrderDate)=YEAR(O.OrderDate) AND MONTH(O2.OrderDate)=MONTH(O.OrderDate))
        +(SELECT ISNULL(SUM(O3.Freight),0) FROM Orders AS O3 WHERE O3.CustomerID=C.CustomerID AND YEAR(O3.OrderDate)=YEAR(O.OrderDate) AND MONTH(O3.OrderDate)=MONTH(O.OrderDate))
FROM Customers AS C
INNER JOIN Orders O on C.CustomerID = O.CustomerID
ORDER BY 1,3,4,5

-------------------------------------------------------------------------------------------
--Najczęściej wybierana kategoria w 1997 dla każdego klienta

SELECT C3.CompanyName,(SELECT TOP 1 C2.CategoryName
FROM Customers AS C
INNER JOIN Orders O on C.CustomerID = O.CustomerID and YEAR(O.OrderDate)=1997
INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
INNER JOIN Products P on P.ProductID = [O D].ProductID
INNER JOIN Categories C2 on C2.CategoryID = P.CategoryID
WHERE C3.CustomerID=C.CustomerID
GROUP BY C.CustomerID, C.CompanyName, C2.CategoryName
ORDER BY COUNT(*) DESC)
FROM Customers AS C3

select CompanyName,
       (select top 1 CategoryName
        from Customers C
                 join Orders O on C.CustomerID = O.CustomerID
                 join [Order Details] [O D] on O.OrderID = [O D].OrderID
                 join Products P on P.ProductID = [O D].ProductID
                 join Categories C2 on C2.CategoryID = P.CategoryID
        where year(OrderDate) = 1997 and C1.CustomerID = C.CustomerID
        group by CompanyName, CategoryName
        order by count(*) desc
       )
from Customers C1
order by CompanyName

------------------------------------------------------------------

-- 3. Kategorie które w roku 1997 grudzień były obsłużone wyłącznie przez ‘United
-- Package’

SELECT DISTINCT C.CategoryID,C.CategoryName,S.CompanyName
FROM Categories AS C
INNER JOIN Products P on C.CategoryID = P.CategoryID
INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
INNER JOIN Orders O on O.OrderID = [O D].OrderID AND YEAR(o.ShippedDate)=1997 AND MONTH(O.ShippedDate)=12
INNER JOIN Shippers S on S.ShipperID = O.ShipVia AND S.CompanyName='United Package'
WHERE C.CategoryID NOT IN (
    SELECT DISTINCT C2.CategoryID
    FROM Categories AS C2
    INNER JOIN Products P on C2.CategoryID = P.CategoryID
    INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
    INNER JOIN Orders O on O.OrderID = [O D].OrderID AND YEAR(o.ShippedDate)=1997 AND MONTH(O.ShippedDate)=12
    INNER JOIN Shippers S on S.ShipperID = O.ShipVia AND S.CompanyName!='United Package'
    )


--Wybierz klientów, którzy kupili przedmioty wyłącznie z jednej kategorii w marcu
--1997 i wypisz nazwę tej kategorii

SELECT t.CustomerID,C2.CategoryName
FROM
(SELECT C.CustomerID
FROM Customers AS C
INNER JOIN Orders O on C.CustomerID = O.CustomerID AND YEAR(O.OrderDate)=1997 AND MONTH(O.OrderDate)=3
INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
INNER JOIN Products P on P.ProductID = [O D].ProductID
INNER JOIN Categories C2 on C2.CategoryID = P.CategoryID
GROUP BY C.CustomerID,C.CompanyName
HAVING COUNT(P.CategoryID)=1) as t
INNER JOIN  Orders O on t.CustomerID = O.CustomerID AND YEAR(O.OrderDate)=1997 AND MONTH(O.OrderDate)=3
INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
INNER JOIN Products P on P.ProductID = [O D].ProductID
INNER JOIN Categories C2 on C2.CategoryID = P.CategoryID


--------------------------------------------------------------
--2. Wybierz kategorię, która w danym roku 1997 najwięcej zarobiła, podział na miesiące
SELECT C.CategoryName,MONTH(O.OrderDate),ISNULL(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),0)
FROM Categories AS C
INNER JOIN Products P on C.CategoryID = P.CategoryID
INNER JOIN [Order Details] OD on P.ProductID = OD.ProductID
INNER JOIN Orders O on O.OrderID = OD.OrderID AND YEAR(O.OrderDate)=1997
WHERE C.CategoryName IN (SELECT t.CategoryName FROM
      (SELECT TOP 1 C2.CategoryName,ISNULL(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),0) as suma
        FROM Categories AS C2
        INNER JOIN Products P on C2.CategoryID = P.CategoryID
        INNER JOIN [Order Details] OD on P.ProductID = OD.ProductID
        INNER JOIN Orders O on O.OrderID = OD.OrderID AND YEAR(O.OrderDate)=1997
        GROUP BY  C2.CategoryName
        ORDER BY suma DESC ) as t)
GROUP BY C.CategoryName,MONTH(O.OrderDate)

