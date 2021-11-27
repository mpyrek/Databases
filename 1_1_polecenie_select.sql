-- 1. Wybierz nazwy i adresy wszystkich klientów
SELECT CompanyName,Address,City,Region,PostalCode,Country
FROM Customers

-- 2. Wybierz nazwiska i numery telefonów pracowników
SELECT LastName,HomePhone
FROM Employees

-- 3. Wybierz nazwy i ceny produktów
SELECT ProductName,UnitPrice
FROM Products

-- 4. Pokaż wszystkie kategorie produktów (nazwy i opisy)
SELECT CategoryName,Description
FROM Categories

-- 5. Pokaż nazwy i adresy stron www dostawców
SELECT CompanyName,HomePage
FROM Suppliers

------------------------------------
-- 1. Wybierz nazwy i adresy wszystkich klientów mających siedziby w Londynie
SELECT CompanyName,Address,PostalCode,City,Region,Country
FROM Customers
WHERE City='London'

-- 2. Wybierz nazwy i adresy wszystkich klientów mających siedziby we Francji lub w
-- Hiszpanii
SELECT CompanyName,Address,PostalCode,City,Region,Country
FROM Customers
WHERE Country='France' or Country='Spain'

-- 3. Wybierz nazwy i ceny produktów o cenie jednostkowej pomiędzy 20.00 a 30.00
SELECT ProductName,UnitPrice
FROM Products
WHERE UnitPrice BETWEEN 20.00 AND 30.00

-- 4. Wybierz nazwy i ceny produktów z kategorii ‘meat’
SELECT ProductName,UnitPrice
FROM Products
WHERE CategoryID = (SELECT CategoryID FROM Categories WHERE CategoryName LIKE '%meat%')


-- 5. Wybierz nazwy produktów oraz inf. o stanie magazynu dla produktów
-- dostarczanych przez firmę ‘Tokyo Traders’
SELECT ProductName,UnitsInStock
FROM Products
WHERE SupplierID = (SELECT S.SupplierID FROM Suppliers  AS S WHERE S.CompanyName = 'Tokyo Traders' )

-- 6. Wybierz nazwy produktów których nie ma w magazynie
SELECT ProductName
FROM Products
WHERE UnitsInStock=0 OR UnitsInStock IS NULL

-------------------------------------------------------------------------------
-- 1. Szukamy informacji o produktach sprzedawanych w butelkach (‘bottle’)
SELECT *
FROM Products
WHERE QuantityPerUnit LIKE '%bottle%'

-- 2. Wyszukaj informacje o stanowisku pracowników, których nazwiska zaczynają się
-- na literę z zakresu od B do L
SELECT EmployeeID,LastName,Title
FROM Employees
WHERE LastName LIKE '[B-L]%'

-- 3. Wyszukaj informacje o stanowisku pracowników, których nazwiska zaczynają się
-- na literę B lub L
SELECT EmployeeID,LastName,Title
FROM Employees
WHERE LastName LIKE '[BL]%'

-- 4. Znajdź nazwy kategorii, które w opisie zawierają przecinek
SELECT CategoryName
FROM Categories
WHERE Description LIKE '%,%'

-- 5. Znajdź klientów, którzy w swojej nazwie mają w którymś miejscu słowo ‘Store’
SELECT CompanyName
FROM Customers
WHERE CompanyName LIKE '%Store%'

-------------------------------------------------------------------------------------------
-- 1. Szukamy informacji o produktach o cenach mniejszych niż 10 lub większych niż 20
SELECT *
FROM Products
WHERE UnitPrice NOT BETWEEN 10 AND 20

-- 2. Wybierz nazwy i ceny produktów o cenie jednostkowej pomiędzy 20.00 a 30.00
SELECT ProductName,UnitPrice
FROM Products
WHERE UnitPrice BETWEEN 20 AND 30

---------------------------------------------------------------------------------------------
-- 1. Wybierz nazwy i kraje wszystkich klientów mających siedziby w Japonii (Japan)
-- lub we Włoszech (Italy)
SELECT CompanyName,Country
FROM Customers
WHERE Country='Japan' or Country='Italy'

---------------------------------------------------------------------------------------------
-- Napisz instrukcję select tak aby wybrać numer zlecenia, datę zamówienia, numer
-- klienta dla wszystkich niezrealizowanych jeszcze zleceń, dla których krajem
-- odbiorcy jest Argentyna
SELECT OrderID,OrderDate,CustomerID
FROM Orders
WHERE  (ShippedDate IS NULL OR ShippedDate > GETDATE()) AND ShipCountry='Argentina'

----------------------------------------------------------------------------------------------
-- 1. Wybierz nazwy i kraje wszystkich klientów, wyniki posortuj według kraju, w
-- ramach danego kraju nazwy firm posortuj alfabetycznie
SELECT CompanyName,Country
FROM Customers
ORDER BY 2,1

-- 2. Wybierz informację o produktach (grupa, nazwa, cena), produkty posortuj wg
-- grup a w grupach malejąco wg ceny
SELECT CategoryID,ProductName,UnitPrice
FROM Products
ORDER BY 1,3 DESC

-- 3. Wybierz nazwy i kraje wszystkich klientów mających siedziby w Japonii (Japan)
-- lub we Włoszech (Italy), wyniki posortuj tak jak w pkt 1
SELECT CompanyName,Country
FROM Customers
WHERE Country='Italy' or Country='Japan'
ORDER BY 2,1

-----------------------------------------------------------------------------------------------
-- 1. Napisz polecenie, które oblicza wartość każdej pozycji zamówienia o numerze
-- 10250
SELECT Quantity*(1-Discount)*UnitPrice
FROM [Order Details]
WHERE OrderID=10250

-- 2. Napisz polecenie które dla każdego dostawcy (supplier) pokaże pojedynczą
-- kolumnę zawierającą nr telefonu i nr faksu w formacie
-- (numer telefonu i faksu mają być oddzielone przecinkiem
SELECT SupplierID,CompanyName, ISNULL(Phone,'')+ISNULL(','+Fax,'')
FROM Suppliers

