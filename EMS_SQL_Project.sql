CREATE DATABASE EmployeeManagementSystem;

USE EmployeeManagementSystem;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);


DESC JobDepartment;
DESC SalaryBonus;
DESC Employee;
DESC Qualification;
DESC Leaves;
DESC Payroll;


SELECT * FROM JobDepartment;
SELECT * FROM SalaryBonus;
SELECT * FROM Employee;
SELECT * FROM Qualification;
SELECT * FROM Leaves;
SELECT * FROM Payroll;

-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
SELECT COUNT(DISTINCT emp_id) as Total_Employees
FROM Employee;

-- Which departments have the highest number of employees?
SELECT jd.jobdept as Department,COUNT(e.emp_id) as Employee_Count
FROM Employee as e
JOIN JobDepartment as jd ON e.job_id=jd.job_id
GROUP BY jd.jobdept ORDER BY Employee_Count DESC;

-- What is the average salary per department?
SELECT jd.jobdept as Department,ROUND(AVG(sb.amount),2) as Avg_Salary 
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.job_id=jd.job_id
GROUP BY jd.jobdept;

-- Who are the top 5 highest-paid employees?
SELECT e.emp_id,concat(e.firstname,' ',e.lastname) as Emp_Name,sb.amount as Salary
FROM Employee e
JOIN Payroll p ON e.emp_id=p.emp_id
JOIN SalaryBonus sb ON p.salary_id=sb.salary_id
ORDER BY Salary DESC
LIMIT 5;

-- What is the total salary expenditure across the company?
SELECT SUM(amount) as Total_Salary_Expenditure
FROM SalaryBonus;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
SELECT jobdept as Department,COUNT(job_id) as Job_Roles
FROM JobDepartment
GROUP BY Jobdept;

-- What is the average salary range per department?
SELECT jd.jobdept as Department,ROUND(AVG(sb.amount),2) as Avg_Salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.job_id=jd.job_id
GROUP BY jd.jobdept;

-- Which job roles offer the highest salary?
SELECT jd.name as Job_Role,MAX(sb.amount) as Highest_Salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.job_id=sb.job_id
GROUP BY jd.name
ORDER BY Highest_Salary DESC
LIMIT 10;

-- Which departments have the highest total salary allocation?
SELECT jd.jobdept as Department,SUM(sb.amount) as Highest_Total_Salary_Allocation
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.job_id=sb.job_id
GROUP BY jd.jobdept
ORDER BY Highest_Total_Salary_Allocation DESC;


-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT emp_id) as Employees_With_Qualification
FROM Qualification;

-- Which positions require the most qualifications?
SELECT Position,Count(*) as Qualification_Count
FROM Qualification
GROUP BY Position
ORDER BY Qualification_Count DESC;

-- Which employees have the highest number of qualifications?
SELECT e.emp_id,concat(e.firstname,' ',e.lastname) as Emp_Name,
		count(QualID) as Highest_Qualifications
FROM Qualification q
JOIN Employee e ON q.emp_id=e.emp_id
GROUP BY e.emp_id
ORDER BY Highest_Qualifications DESC;


-- 4. LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?
SELECT year(date) as Leave_Year,
		COUNT(DISTINCT emp_id) as Employees_On_Leave
FROM Leaves
GROUP BY Leave_Year
ORDER BY Employees_On_Leave DESC;

-- What is the average number of leave days taken by its employees per department?
SELECT jd.jobdept AS Department,
       ROUND(COUNT(l.leave_ID) / COUNT(DISTINCT e.emp_ID), 2) AS Avg_Leave_Days
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY jd.jobdept;

-- Which employees have taken the most leaves?
SELECT e.emp_id,concat(e.firstname,' ',e.lastname) as Emp_Name,
		COUNT(leave_id) as Leaves
FROM Employee e
JOIN Leaves l ON e.emp_id=l.emp_id
GROUP BY e.emp_id
ORDER BY Leaves DESC;

-- What is the total number of leave days taken company-wide?
SELECT COUNT(*) as Leave_Days
FROM Leaves;

-- How do leave days correlate with payroll amounts?
SELECT e.emp_id,concat(e.firstname,' ',e.lastname) as Emp_Name,
		COUNT(l.leave_id) as Leave_Count,SUM(p.total_amount) as Total_Pay
FROM Employee e
LEFT JOIN Leaves l ON e.emp_id=l.emp_id
LEFT JOIN Payroll p ON e.emp_id=p.emp_id
GROUP BY e.emp_id
ORDER BY Leave_Count DESC;


-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
SELECT YEAR(date) as Year,
       MONTH(date) AS Month,
       SUM(total_amount) AS Monthly_Payroll
FROM Payroll
GROUP BY Year,Month
ORDER BY Year,Month;

-- What is the average bonus given per department?
SELECT jd.jobdept as Department,ROUND(AVG(sb.bonus),2) as Avg_Bonus 
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.job_id=jd.job_id
GROUP BY jd.jobdept;

-- Which department receives the highest total bonuses?
SELECT jd.jobdept as Department,SUM(sb.bonus) as Total_Bonus 
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.job_id=jd.job_id
GROUP BY jd.jobdept
ORDER BY Total_Bonus DESC;

-- What is the average value of total_amount after considering leave deductions?
SELECT ROUND(AVG(total_amount),2) as Avg_Payroll
FROM Payroll;
