-- 1. Wybierz nazwy i ceny produktów (baza northwind) o cenie jednostkowej
-- pomiędzy 20.00 a 30.00, dla każdego produktu podaj dane adresowe dostawcy
SELECT DISTINCT ProductName,UnitPrice,S.Address,S.PostalCode,S.City,S.Country
FROM Products
INNER JOIN Suppliers S on S.SupplierID = Products.SupplierID
WHERE UnitPrice BETWEEN 20.00 AND 30.00

-- 2. Wybierz nazwy produktów oraz inf. o stanie magazynu dla produktów
-- dostarczanych przez firmę ‘Tokyo Traders’
SELECT DISTINCT ProductName,UnitsInStock
FROM Products
INNER JOIN Suppliers S on S.SupplierID = Products.SupplierID
WHERE S.CompanyName='Tokyo Traders'

-- 3. Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku, jeśli tak
-- to pokaż ich dane adresowe
SELECT DISTINCT C.CustomerID, C.Address,C.PostalCode,C.City,C.Country
FROM Customers AS C
LEFT JOIN Orders O on C.CustomerID = O.CustomerID and YEAR(O.OrderDate)=1997
WHERE O.OrderID IS NULL

-- 4. Wybierz nazwy i numery telefonów dostawców, dostarczających produkty,
-- których aktualnie nie ma w magazynie
SELECT DISTINCT ProductName, S.Phone,UnitsInStock
FROM Products
INNER JOIN Suppliers S on S.SupplierID = Products.SupplierID
WHERE UnitsInStock=0

------------------------------------------------------------------------------------------
-- Napisz polecenie, wyświetlające CROSS JOIN między shippers i
-- suppliers. użyteczne dla listowania wszystkich możliwych
-- sposobów w jaki dostawcy mogą dostarczać swoje produkty
SELECT S.ShipperID,S.CompanyName,S2.SupplierID,S2.CompanyName
FROM Shippers AS S
CROSS JOIN Suppliers AS S2
------------------------------------------------------------------------------------
-- 1• Napisz polecenie zwracające listę produktów zamawianych w dniu
-- 1996-07-08.
SELECT DISTINCT P.ProductName
FROM Orders
INNER JOIN [Order Details] [O D] on Orders.OrderID = [O D].OrderID
INNER JOIN Products P on P.ProductID = [O D].ProductID
WHERE OrderDate='1996/07/08'

--------------------------------------------------------------------------------------
-- 1. Wybierz nazwy i ceny produktów (baza northwind) o cenie jednostkowej
-- pomiędzy 20.00 a 30.00, dla każdego produktu podaj dane adresowe dostawcy,
-- interesują nas tylko produkty z kategorii ‘Meat/Poultry’
SELECT ProductName,UnitPrice,S.City,S.Address,S.PostalCode,S.Country
FROM Products
INNER JOIN Categories C on C.CategoryID = Products.CategoryID AND C.CategoryName='Meat/Poultry'
INNER JOIN Suppliers S on S.SupplierID = Products.SupplierID
WHERE UnitPrice BETWEEN 20 AND 30

-- 2. Wybierz nazwy i ceny produktów z kategorii ‘Confections’ dla każdego produktu
-- podaj nazwę dostawcy.
SELECT P.ProductName,P.UnitPrice,S.CompanyName
FROM Products AS P
INNER JOIN Categories C on C.CategoryID = P.CategoryID AND C.CategoryName='Confections'
INNER JOIN Suppliers S on S.SupplierID = P.SupplierID

-- 3. Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki
-- dostarczała firma ‘United Package’
SELECT DISTINCT C.CompanyName,C.Phone
FROM Customers AS C
INNER JOIN Orders O on C.CustomerID = O.CustomerID
INNER JOIN Shippers S on S.ShipperID = O.ShipVia AND S.CompanyName='United Package'
WHERE YEAR(ShippedDate)=1997

-- 4. Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii
-- ‘Confections’
SELECT DISTINCT C.CompanyName,C.Phone
FROM Customers AS C
INNER JOIN Orders O on C.CustomerID = O.CustomerID
INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
INNER JOIN Products P on P.ProductID = [O D].ProductID
INNER JOIN Categories C2 on C2.CategoryID = P.CategoryID AND C2.CategoryName='Confections'

---------------------------------------------------------------------------------------
-- Napisz polecenie, które pokazuje pary pracowników zajmujących
-- to samo stanowisko.
SELECT E.LastName+' '+E.FirstName, E2.LastName+' '+E2.FirstName
FROM Employees AS E
INNER JOIN Employees AS E2 on E2.Title=E.Title AND E2.EmployeeID>E.EmployeeID

----------------------------------------------------------------------------------------
-- 1. Napisz polecenie, które wyświetla pracowników oraz ich podwładnych (baza
-- northwind)
SELECT E.FirstName+' '+E.LastName, E2.LastName+' '+E2.FirstName
FROM Employees AS E
LEFT JOIN Employees AS E2 on E2.ReportsTo=E.EmployeeID

--mają podwłądnych
SELECT DISTINCT E.FirstName+' '+E.LastName
FROM Employees AS E
LEFT JOIN Employees AS E2 on E2.ReportsTo=E.EmployeeID
WHERE E2.EmployeeID IS NOT NULL


-- 2. Napisz polecenie, które wyświetla pracowników, którzy nie mają podwładnych
-- (baza northwind)
SELECT DISTINCT E.FirstName+' '+E.LastName
FROM Employees AS E
LEFT JOIN Employees AS E2 on E2.ReportsTo=E.EmployeeID
WHERE E2.EmployeeID IS  NULL

