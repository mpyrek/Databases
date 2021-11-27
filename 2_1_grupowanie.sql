-- 1. Napisz polecenie, które oblicza wartość sprzedaży dla każdego zamówienia
-- w tablicy order details i zwraca wynik posortowany w malejącej kolejności
-- (wg wartości sprzedaży).

SELECT OrderID,SUM(Quantity*(1-Discount)*UnitPrice)
FROM [Order Details]
GROUP BY OrderID
ORDER BY 2 DESC

-- 2. Zmodyfikuj zapytanie z poprzedniego punktu, tak aby zwracało pierwszych
-- 10 wierszy
SELECT TOP 10 OrderID,SUM(Quantity*(1-Discount)*UnitPrice)
FROM [Order Details]
GROUP BY OrderID
ORDER BY 2 DESC

----------------------------------------------------------------------------------------------
-- 1. Podaj liczbę zamówionych jednostek produktów dla produktów, dla których
-- productid < 3
SELECT SUM(Quantity)
FROM [Order Details]
WHERE ProductID<3
GROUP BY ProductID

-- 2. Zmodyfikuj zapytanie z poprzedniego punktu, tak aby podawało liczbę
-- zamówionych jednostek produktu dla wszystkich produktów
SELECT ProductID,SUM(Quantity)
FROM [Order Details]
GROUP BY ProductID
ORDER BY 1

-- 3. Podaj nr zamówienia oraz wartość zamówienia, dla zamówień, dla których
-- łączna liczba zamawianych jednostek produktów jest > 250
SELECT OrderID,SUM(Quantity*(1-Discount)*UnitPrice)
FROM [Order Details]
GROUP BY OrderID
HAVING SUM(Quantity) > 250

----------------------------------------------------------------------------------------------
-- 1. Dla każdego pracownika podaj liczbę obsługiwanych przez niego zamówień
SELECT O.EmployeeID,E.FirstName,E.LastName,COUNT(*) AS total_value
FROM Orders AS O
INNER JOIN Employees E on E.EmployeeID = O.EmployeeID
GROUP BY E.FirstName, O.EmployeeID, E.LastName


-- 2. Dla każdego spedytora/przewoźnika podaj wartość "opłaty za przesyłkę"
-- przewożonych przez niego zamówień
SELECT ShipVia,S.CompanyName,SUM(Freight) AS 'opłaty za przesyłkę'
FROM Orders
INNER JOIN Shippers S on S.ShipperID = Orders.ShipVia
GROUP BY ShipVia,S.CompanyName
ORDER BY 1


-- 3. Dla każdego spedytora/przewoźnika podaj wartość "opłaty za przesyłkę"
-- przewożonych przez niego zamówień w latach o 1996 do 1997
SELECT ShipVia,S.CompanyName,SUM(Freight) AS 'opłaty za przesyłkę'
FROM Orders
INNER JOIN Shippers S on S.ShipperID = Orders.ShipVia
WHERE YEAR(OrderDate) BETWEEN 1996 AND 1997
GROUP BY ShipVia,S.CompanyName
ORDER BY 1

-------------------------------------------------------------------------------
-- 1. Dla każdego pracownika podaj liczbę obsługiwanych przez niego zamówień z
-- podziałem na lata i miesiące
SELECT EmployeeID,YEAR(OrderDate)AS YEAR ,MONTH(OrderDate) AS MONTH,Count(*)
FROM Orders
GROUP BY EmployeeID,YEAR(OrderDate),MONTH(OrderDate)
WITH ROLLUP

-- 2. Dla każdej kategorii podaj maksymalną i minimalną cenę produktu w tej
-- kategorii
SELECT CategoryID,MAX(UnitPrice),MIN(UnitPrice)
FROM Products
GROUP BY CategoryID

----------------------------------------------------------------------------------
