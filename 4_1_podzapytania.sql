-- 1. Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki
-- dostarczała firma United Package.
SELECT DISTINCT C.CompanyName,C.Phone
FROM Customers AS C
INNER JOIN Orders O on C.CustomerID = O.CustomerID
INNER JOIN Shippers S on S.ShipperID = O.ShipVia
WHERE S.CompanyName='United Package' AND YEAR(O.ShippedDate)=1997
--exist
SELECT CompanyName,Phone
FROM Customers
WHERE EXISTS(SELECT * FROM Orders AS O WHERE O.CustomerID=Customers.CustomerID AND YEAR(O.ShippedDate)=1997 AND
            EXISTS(SELECT * FROM Shippers WHERE O.ShipVia=Shippers.ShipperID AND Shippers.CompanyName='United Package'))

--in
SELECT CompanyName,Phone
FROM Customers
WHERE CustomerID IN
      (SELECT O.CustomerID FROM Orders AS O WHERE O.CustomerID = Customers.CustomerID AND YEAR(O.ShippedDate) = 1997 AND
      O.ShipVia IN (SELECT ShipperID FROM Shippers WHERE O.ShipVia=Shippers.ShipperID AND Shippers.CompanyName='United Package'))



-- 2. Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii
-- Confections.
SELECT DISTINCT C.CustomerID,C.CompanyName,C.Phone
FROM Customers AS C
INNER JOIN Orders O on C.CustomerID = O.CustomerID
INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
INNER JOIN Products P on P.ProductID = [O D].ProductID
INNER JOIN Categories C2 on C2.CategoryID = P.CategoryID and C2.CategoryName='Confections'

SELECT C.CustomerID,C.CompanyName,C.Phone
FROM Customers AS C
WHERE EXISTS(SELECT * FROM Orders AS O WHERE O.CustomerID=C.CustomerID AND
            EXISTS(SELECT * FROM [Order Details] AS OD WHERE OD.OrderID=O.OrderID AND
                    EXISTS(SELECT * FROM Products AS P WHERE P.ProductID=OD.ProductID AND
                        EXISTS(SELECT * FROM Categories AS C2 WHERE C2.CategoryID=P.CategoryID AND C2.CategoryName='Confections'))))


--in

SELECT C.CustomerID,C.CompanyName,C.Phone
FROM Customers AS C
WHERE CustomerID In (SELECT O.CustomerID FROM Orders AS O
                    WHERE O.OrderID IN (SELECT [Order Details].OrderID FROM [Order Details]
                        WHERE [Order Details].ProductID IN (SELECT ProductID FROM Products
                        WHERE Products.CategoryID IN (Select CategoryID FROM Categories WHERE CategoryName='Confections'))))

-- 3. Wybierz nazwy i numery telefonów klientów, którzy nie kupowali produktów z
-- kategorii Confections
SELECT C.CompanyName,C.Phone,COUNT(C2.CategoryID)
FROM Customers AS C
LEFT JOIN Orders O on C.CustomerID = O.CustomerID
LEFT JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
LEFT JOIN Products P on P.ProductID = [O D].ProductID
LEFT JOIN Categories C2 on C2.CategoryID = P.CategoryID AND C2.CategoryName='Confections'
GROUP BY C.CustomerID, C.CompanyName, C.Phone
HAVING COUNT(C2.CategoryID)=0

SELECT C.CustomerID,C.CompanyName,C.Phone
FROM Customers AS C
WHERE NOT EXISTS(SELECT * FROM Orders AS O WHERE O.CustomerID=C.CustomerID AND
            EXISTS(SELECT * FROM [Order Details] AS OD WHERE OD.OrderID=O.OrderID AND
                    EXISTS(SELECT * FROM Products AS P WHERE P.ProductID=OD.ProductID AND
                        EXISTS(SELECT * FROM Categories AS C2 WHERE C2.CategoryID=P.CategoryID AND C2.CategoryName='Confections'))))

SELECT C.CustomerID,C.CompanyName,C.Phone
FROM Customers AS C
WHERE CustomerID NOT In (SELECT O.CustomerID FROM Orders AS O
                    WHERE O.OrderID IN (SELECT [Order Details].OrderID FROM [Order Details]
                        WHERE [Order Details].ProductID IN (SELECT ProductID FROM Products
                        WHERE Products.CategoryID IN (Select CategoryID FROM Categories WHERE CategoryName='Confections'))))

----------------------------------------------------------------------------------------------
-- 1. Dla każdego produktu podaj maksymalną liczbę zamówionych jednostek
SELECT P.ProductID,P.ProductName,MAX(Quantity)
FROM Products AS P
INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
GROUP BY P.ProductID, P.ProductName
ORDER BY 1

SELECT ProductID,ProductName,
       (SELECT MAX(Quantity) FROM [Order Details] WHERE Products.ProductID=[Order Details].ProductID)
FROM Products

-- 2. Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu
SELECT ProductID
FROM Products
WHERE UnitPrice < (SELECT AVG(P2.UnitPrice) FROM Products AS P2)

-- 3. Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu
-- danej kategorii
SELECT ProductID FROM
(SELECT P1.ProductID,P1.UnitPrice-(SELECT AVG(P2.UnitPrice) FROM Products AS P2  WHERE P1.CategoryID=P2.CategoryID) as average
FROM Products AS P1) tmp
WHERE average <0

SELECT ProductID
FROM Products
JOIN (SELECT CategoryID,AVG(P2.UnitPrice) as average FROM Products AS P2 GROUP BY CategoryID)
    AS P2 on Products.CategoryID=P2.CategoryID
WHERE P2.average-Products.UnitPrice > 0


--------------------------------------------------------------------------------------------
-- 1. Dla każdego produktu podaj jego nazwę, cenę, średnią cenę wszystkich
-- produktów oraz różnicę między ceną produktu a średnią ceną wszystkich
-- produktów
SELECT ProductID,UnitPrice,(SELECT AVG(UnitPrice) FROM Products) as average,UnitPrice-(SELECT AVG(UnitPrice) FROM Products) as diff
FROM Products

-- 2. Dla każdego produktu podaj jego nazwę k
-- ategorii, nazwę produktu, cenę, średnią
-- cenę wszystkich produktów danej kategorii oraz różnicę między ceną produktu a
-- średnią ceną wszystkich produktów danej kategori
SELECT ProductID,ProductName,C.CategoryID,C.CategoryName,UnitPrice,
       (SELECT AVG(UnitPrice)
       FROM Products AS P2
       WHERE C.CategoryID=P2.CategoryID
       GROUP BY P2.CategoryID) as average,
       UnitPrice-(SELECT AVG(UnitPrice) FROM Products AS P2 WHERE C.CategoryID=P2.CategoryID
       GROUP BY P2.CategoryID) as diff
FROM Products
INNER JOIN Categories C on C.CategoryID = Products.CategoryID

----------------------------------------------------------------------------------------------------------------
-- 1. Podaj łączną wartość zamówienia o numerze 1025 (uwzględnij cenę za przesyłkę)
SELECT SUM(Quantity*(1-Discount)*UnitPrice) +
    (SELECT Freight FROM Orders WHERE [Order Details].OrderID=Orders.OrderID)
FROM [Order Details]
WHERE OrderID=10250
GROUP BY OrderID

SELECT SUM(Quantity*(1-Discount)*UnitPrice)+O.Freight
FROM [Order Details]
INNER JOIN Orders O on O.OrderID = [Order Details].OrderID
WHERE O.OrderID=10250
GROUP BY O.OrderID,O.Freight

-- 2. Podaj łączną wartość zamówień każdego zamówienia (uwzględnij cenę za
-- przesyłkę)
SELECT SUM(Quantity*(1-Discount)*UnitPrice)+O.Freight
FROM [Order Details]
INNER JOIN Orders O on O.OrderID = [Order Details].OrderID
GROUP BY O.OrderID,O.Freight

SELECT SUM(Quantity*(1-Discount)*UnitPrice) +
    (SELECT Freight FROM Orders WHERE [Order Details].OrderID=Orders.OrderID)
FROM [Order Details]
GROUP BY OrderID


-- 3. Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku, jeśli tak
-- to pokaż ich dane adresowe
SELECT DISTINCT C.CustomerID,C.Address,C.City,C.PostalCode,C.Country
FROM Customers AS C
LEFT JOIN Orders O on C.CustomerID = O.CustomerID and YEAR(OrderDate)=1997
WHERE O.OrderID IS NULL

SELECT C.CustomerID,C.Address,C.City,C.PostalCode,C.Country
FROM Customers AS C
WHERE C.CustomerID NOT IN (SELECT O.CustomerID FROM Orders AS O WHERE YEAR(OrderDate)=1997)

SELECT C.CustomerID,C.Address,C.City,C.PostalCode,C.Country
FROM Customers AS C
WHERE NOT EXISTS(SELECT * FROM Orders WHERE YEAR(OrderDate)=1997 AND C.CustomerID=Orders.CustomerID)

---złożyli
SELECT DISTINCT C.CustomerID,C.Address,C.City,C.PostalCode,C.Country
FROM Customers AS C
INNER JOIN Orders O on C.CustomerID = O.CustomerID and YEAR(OrderDate)=1997

SELECT C.CustomerID,C.Address,C.City,C.PostalCode,C.Country
FROM Customers AS C
WHERE C.CustomerID IN (SELECT O.CustomerID FROM Orders AS O WHERE YEAR(OrderDate)=1997)

SELECT C.CustomerID,C.Address,C.City,C.PostalCode,C.Country
FROM Customers AS C
WHERE EXISTS(SELECT * FROM Orders WHERE YEAR(OrderDate)=1997 AND C.CustomerID=Orders.CustomerID)

-- 4. Podaj produkty kupowane przez więcej niż jednego klienta
SELECT P.ProductID,P.ProductName, COUNT(DISTINCT CustomerID) as How_munny_clients
FROM Products AS P
INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
INNER JOIN Orders O on O.OrderID = [O D].OrderID
GROUP BY P.ProductID, P.ProductName
HAVING COUNT(DISTINCT CustomerID)>1


SELECT P.ProductID,P.ProductName,
(SELECT COUNT(DISTINCT CustomerID)
FROM Orders
INNER JOIN [Order Details] [O D] on Orders.OrderID = [O D].OrderID
WHERE P.ProductID=[O D].ProductID
GROUP BY [O D].ProductID)
FROM Products AS P
WHERE
(SELECT COUNT(DISTINCT CustomerID)
FROM Orders
INNER JOIN [Order Details] [O D] on Orders.OrderID = [O D].OrderID
WHERE P.ProductID=[O D].ProductID
GROUP BY [O D].ProductID) >1


-----------------------------------------------------------------------------------
-- 1. Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień
-- obsłużonych przez tego pracownika (przy obliczaniu wartości zamówień
-- uwzględnij cenę za przesyłkę
SELECT E.EmployeeID,E.FirstName+' '+E.LastName as name,
       (SELECT SUM(Quantity*(1-Discount)*UnitPrice) FROM [Order Details]
           INNER JOIN Orders O on O.OrderID = [Order Details].OrderID and O.EmployeeID=E.EmployeeID)
        +(SELECT SUM(Freight) FROM Orders WHERE E.EmployeeID=Orders.EmployeeID)
FROM Employees AS E

SELECT E.EmployeeID,E.FirstName+' '+E.LastName as name, zysk.suma+przeysłka.suma
FROM Employees AS E
JOIN
(SELECT O.EmployeeID,SUM(OD.Quantity*(1-OD.Discount)*OD.UnitPrice) as suma
FROM [Order Details] AS OD
INNER JOIN Orders O on OD.OrderID = O.OrderID
GROUP BY O.EmployeeID) as zysk on zysk.EmployeeID= E.EmployeeID
JOIN
(SELECT O.EmployeeID,SUM(O.Freight) as suma
FROM Orders AS O
GROUP BY O.EmployeeID) as przeysłka on E.EmployeeID=przeysłka.EmployeeID


-- 2. Który z pracowników obsłużył najaktywniejszy (obsłużył zamówienia o
-- największej wartości) w 1997r, podaj imię i nazwisko takiego pracownika
SELECT TOP 1 E.EmployeeID,E.FirstName+' '+E.LastName as name,
       (SELECT SUM(Quantity*(1-Discount)*UnitPrice) FROM [Order Details]
           INNER JOIN Orders O on O.OrderID = [Order Details].OrderID and O.EmployeeID=E.EmployeeID)
        +(SELECT SUM(Freight) FROM Orders WHERE E.EmployeeID=Orders.EmployeeID)
FROM Employees AS E
ORDER BY 3 DESC

-- 3. Ogranicz wynik z pkt 1 tylko do pracowników
-- a) którzy mają podwładnych
SELECT DISTINCT E.EmployeeID,E.FirstName+' '+E.LastName as name,
       (SELECT SUM(Quantity*(1-Discount)*UnitPrice) FROM [Order Details]
           INNER JOIN Orders O on O.OrderID = [Order Details].OrderID and O.EmployeeID=E.EmployeeID)
        +(SELECT SUM(Freight) FROM Orders WHERE E.EmployeeID=Orders.EmployeeID)
FROM Employees AS E
INNER JOIN Employees as E2 on E2.ReportsTo=E.EmployeeID


-- b) którzy nie mają podwładnych
SELECT DISTINCT E.EmployeeID,E.FirstName+' '+E.LastName as name,
       (SELECT SUM(Quantity*(1-Discount)*UnitPrice) FROM [Order Details]
           INNER JOIN Orders O on O.OrderID = [Order Details].OrderID and O.EmployeeID=E.EmployeeID)
        +(SELECT SUM(Freight) FROM Orders WHERE E.EmployeeID=Orders.EmployeeID)
FROM Employees AS E
LEFT JOIN Employees as E2 on E.EmployeeID=E2.ReportsTo
WHERE E2.EmployeeID IS NULL

-- 4. Zmodyfikuj rozwiązania z pkt 3 tak aby dla pracowników pokazać jeszcze datę
-- ostatnio obsłużonego zamówienia
-- a) którzy mają podwładnych
SELECT DISTINCT E.EmployeeID,E.FirstName+' '+E.LastName as name,
       (SELECT SUM(Quantity*(1-Discount)*UnitPrice) FROM [Order Details]
           INNER JOIN Orders O on O.OrderID = [Order Details].OrderID and O.EmployeeID=E.EmployeeID)
        +(SELECT SUM(Freight) FROM Orders WHERE E.EmployeeID=Orders.EmployeeID), (SELECT MAX(OrderDate) FROM Orders WHERE E.EmployeeID=Orders.EmployeeID)
FROM Employees AS E
INNER JOIN Employees as E2 on E2.ReportsTo=E.EmployeeID

-- b) którzy nie mają podwładnych
SELECT DISTINCT E.EmployeeID,E.FirstName+' '+E.LastName as name,
       (SELECT SUM(Quantity*(1-Discount)*UnitPrice) FROM [Order Details]
           INNER JOIN Orders O on O.OrderID = [Order Details].OrderID and O.EmployeeID=E.EmployeeID)
        +(SELECT SUM(Freight) FROM Orders WHERE E.EmployeeID=Orders.EmployeeID), (SELECT MAX(OrderDate) FROM Orders WHERE E.EmployeeID=Orders.EmployeeID)
FROM Employees AS E
LEFT JOIN Employees as E2 on E.EmployeeID=E2.ReportsTo
WHERE E2.EmployeeID IS NULL
