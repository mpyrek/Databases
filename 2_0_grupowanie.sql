-- 1. Podaj liczbę produktów o cenach mniejszych niż 10$ lub większych niż
-- 20$
SELECT COUNT(*)
FROM Products
WHERE UnitPrice NOT BETWEEN 10 AND 20

-- 2. Podaj maksymalną cenę produktu dla produktów o cenach poniżej 20$
SELECT MAX(UnitPrice)
FROM Products
WHERE UnitPrice<20

-- 3. Podaj maksymalną i minimalną i średnią cenę produktu dla produktów o
-- produktach sprzedawanych w butelkach (‘bottle’)
SELECT MAX(UnitPrice),MIN(UnitPrice),AVG(UnitPrice)
FROM Products
WHERE QuantityPerUnit LIKE '%bottle%'

-- 4. Wypisz informację o wszystkich produktach o cenie powyżej średniej
SELECT *
FROM Products
WHERE UnitPrice < (SELECT AVG(UnitPrice) FROM Products)

-- 5. Podaj sumę/wartość zamówienia o numerze 10250
SELECT SUM(Quantity*(1-Discount)*UnitPrice)
FROM [Order Details]
WHERE OrderID=10250

------------------------------------------------------------------------------------
-- Napisz polecenie, które zwraca informacje o zamówieniach z tablicy order
-- details. Zapytanie ma grupować i wyświetlać identyfikator każdego
-- produktu a następnie obliczać ogólną zamówioną ilość. Ogólna ilość jest
-- sumowana funkcją agregującą SUM i wyświetlana jako jedna wartość dla
-- każdego produktu.
SELECT ProductID,SUM(Quantity) as total_quantity
FROM [Order Details]
GROUP BY ProductID

----------------------------------------------------------------------------------
-- 1. Podaj maksymalną cenę zamawianego produktu dla każdego zamówienia
SELECT OrderID,MAX(UnitPrice)
FROM [Order Details]
GROUP BY OrderID

-- 2. Posortuj zamówienia wg maksymalnej ceny produktu
SELECT OrderID, MAX(UnitPrice)
FROM [Order Details]
GROUP BY OrderID
ORDER BY 2

-- 3. Podaj maksymalną i minimalną cenę zamawianego produktu dla każdego
-- zamówienia
SELECT OrderID,MAX(UnitPrice),MIN(UnitPrice)
FROM [Order Details]
GROUP BY OrderID

-- 4. Podaj liczbę zamówień dostarczanych przez poszczególnych spedytorów
-- (przewoźników)
SELECT ShipVia,COUNT(OrderID)
FROM Orders
GROUP BY ShipVia

-- 5. Który z spedytorów był najaktywniejszy w 1997 roku
SELECT TOP 1 ShipVia,COUNT(OrderID)
FROM Orders
WHERE YEAR(OrderDate)=1997
GROUP BY ShipVia
ORDER BY 2 DESC

------------------------------------------------------------------------------------
-- 1. Wyświetl zamówienia dla których liczba pozycji zamówienia jest większa niż 5
SELECT OrderID
FROM [Order Details]
GROUP BY OrderID
HAVING COUNT(*)>5

-- 2. Wyświetl klientów dla których w 1998 roku zrealizowano więcej niż 8 zamówień
-- (wyniki posortuj malejąco wg łącznej kwoty za dostarczenie zamówień dla
-- każdego z klientów)

SELECT CustomerID
FROM Orders
WHERE YEAR(OrderDate)=1998
GROUP BY CustomerID
HAVING COUNT(*)>8
ORDER BY SUM(Freight) DESC

