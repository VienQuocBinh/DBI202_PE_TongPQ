CREATE DATABASE EmploymentManagement

CREATE TABLE Department(
	DepartmentID CHAR(5) PRIMARY KEY,
	Name VARCHAR(50)
);

CREATE TABLE Employee(
	EmployeeID CHAR(5) PRIMARY KEY,
	Name VARCHAR(50),
	DepartmentFK CHAR(5) FOREIGN KEY (DepartmentFK) REFERENCES Department(DepartmentID),
	BirthDate DATETIME DEFAULT '1970-12-10'
);

INSERT INTO Department
VALUES (1, 'IT')
INSERT INTO Department
VALUES (2, 'Human resource')
INSERT INTO Department
VALUES (3, 'Research')
INSERT INTO Department
VALUES (4, 'Business')

INSERT INTO Employee
VALUES (1, 'Micheal John', 1, '1970-04-21')
INSERT INTO Employee
VALUES (2, 'Anna Lombard', 2, '1972-01-02')
INSERT INTO Employee
VALUES (3, 'Peter Dawson', 3, '1990-07-12')
INSERT INTO Employee
VALUES (4, 'Leonard', 4, '1981-05-25')
INSERT INTO Employee
VALUES (5, 'Elizabeth', 3, '1970-03-14')
--4
SELECT EmployeeID, Name, (YEAR(GETDATE())- YEAR(BirthDate)) AS 'AGE' FROM Employee 
WHERE YEAR(BirthDate) > 1975
--5
SELECT e.EmployeeID, e.Name, d.DepartmentID, d.Name FROM Employee e
JOIN Department d ON e.DepartmentFK = d.DepartmentID AND d.Name = N'Research'
--6
SELECT d.DepartmentID, d.Name, COUNT(e.EmployeeID) AS 'TOTAL' FROM Employee e
JOIN Department d ON e.DepartmentFK = d.DepartmentID AND d.Name = N'Research'
GROUP BY d.DepartmentID, d.Name
--7
UPDATE Employee SET
DepartmentFK = (SELECT d.DepartmentID FROM Department d WHERE d.Name = 'Research')
WHERE DepartmentFK = (SELECT d.DepartmentID FROM Department d WHERE d.Name = 'Business')
--8
DELETE FROM Employee
WHERE DepartmentFK = (SELECT d.DepartmentID FROM Employee e
JOIN Department d ON e.DepartmentFK = d.DepartmentID
WHERE d.Name = N'IT' AND YEAR(e.BirthDate) = 1970)

--9
IF OBJECT_ID('ViewEmployees', 'V') IS NOT NULL
	DROP VIEW ViewEmployees
GO

CREATE VIEW ViewEmployees AS
SELECT e.EmployeeID, e.Name AS 'empName', e.BirthDate, d.Name AS 'depName' 
FROM Employee e 
JOIN Department d ON e.DepartmentFK = d.DepartmentID
GO

SELECT * FROM ViewEmployees
ORDER BY depName

-- 10 
IF OBJECT_ID('ProcDeleteDepartment', 'P') IS NOT NULL
	DROP PROCEDURE ProcDeleteDepartment
GO
CREATE PROCEDURE ProcDeleteDepartment 
@departmentId CHAR(5)
AS
	UPDATE Employee
	SET DepartmentFK = NULL
	WHERE DepartmentFK = @departmentId
	DELETE FROM Department
	WHERE DepartmentID = @departmentId
GO
EXEC ProcDeleteDepartment 3;

-- 11
IF OBJECT_ID('TriggerInsertEmp', 'TR') IS NOT NULL
	DROP TRIGGER TriggerInsertEmp
GO
CREATE TRIGGER TriggerInsertEmp ON Employee
AFTER INSERT
AS
	DECLARE @Birthdate DATETIME, @age INT
	SELECT @Birthdate = BirthDate
	FROM inserted
	SET @age=YEAR(GETDATE()) - YEAR(@Birthdate)
	IF(@age < 30)
	BEGIN
		RAISERROR('Age must be more than 30 years old',16,1)
		ROLLBACK TRANSACTION
	END
GO

INSERT INTO Employee
VALUES(555, 'Micheal John', 1, '2000-04-21')
