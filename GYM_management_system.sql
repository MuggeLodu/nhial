create database GYM_management_system;
show databases;
use GYM_management_system;
-- Create a new database user
CREATE USER 'gym_user'@'localhost' IDENTIFIED BY 'securepassword';
-- Grant all privileges on the gym_management database to the gym_user
GRANT ALL PRIVILEGES ON gym_management.* TO 'gym_user'@'localhost';

-- Apply the changes
FLUSH PRIVILEGES;

-- Use the GYM_management_system database
USE GYM_management_system;

-- Create the Membership Plans table
CREATE TABLE Membership_Plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(50),
    duration INT,
    price DECIMAL(10, 2)
);

-- Create the Members table
CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone_number VARCHAR(15),
    join_date DATE,
    membership_plan_id INT,
    FOREIGN KEY (membership_plan_id) REFERENCES Membership_Plans(plan_id)
);

-- Create the Trainers table
CREATE TABLE Trainers (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialty VARCHAR(100),
    phone_number VARCHAR(15)
);

-- Create the Classes table
CREATE TABLE Classes (
    class_id INT PRIMARY KEY AUTO_INCREMENT,
    class_name VARCHAR(50),
    schedule DATETIME,
    trainer_id INT,
    time INT,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id)
);

-- Create the Attendance table
CREATE TABLE Attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    class_id INT,
    date DATE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (class_id) REFERENCES Classes(class_id)
);

-- Create the Payments table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    amount DECIMAL(10, 2),
    date DATE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);

-- Create the Trainer Schedules table
CREATE TABLE Trainer_Schedules (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT,
    day_of_week VARCHAR(10),
    start_time TIME,
    end_time TIME,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id)
);

-- Insert data into Membership_Plans table
INSERT INTO Membership_Plans (plan_name, duration, price)
VALUES 
('Monthly', 30, 50.00),
('Quarterly', 90, 135.00),
('Annual', 365, 500.00);

-- Insert data into Members table
INSERT INTO Members (first_name, last_name, email, phone_number, join_date, membership_plan_id)
VALUES 
('John', 'Doe', 'john@example.com', '123-456-7890', '2023-01-15', 1),
('Jane', 'Smith', 'jane@example.com', '098-765-4321', '2023-02-20', 2);

-- Insert data into Trainers table
INSERT INTO Trainers (first_name, last_name, specialty, phone_number)
VALUES 
('Alex', 'Johnson', 'Yoga', '234-567-8901'),
('Chris', 'Lee', 'Weightlifting', '876-543-2109');

-- Insert data into Classes table
INSERT INTO Classes (class_name, schedule, trainer_id, time)
VALUES 
('Morning Yoga', '2023-03-01 07:00:00', 1, 60),
('Evening Weightlifting', '2023-03-01 18:00:00', 2, 90);

-- Insert data into Attendance table
INSERT INTO Attendance (member_id, class_id, date)
VALUES 
(1, 1, '2023-03-01'),
(2, 2, '2023-03-01');

-- Insert data into Payments table
INSERT INTO Payments (member_id, amount, date)
VALUES 
(1, 50.00, '2023-01-15'),
(2, 135.00, '2023-02-20');

-- Insert data into Trainer_Schedules table
INSERT INTO Trainer_Schedules (trainer_id, day_of_week, start_time, end_time)
VALUES 
(1, 'Monday', '07:00:00', '08:00:00'),
(2, 'Wednesday', '08:00:00','10:00:00');

-- Create a view for active members
CREATE VIEW Active_Members AS
SELECT m.member_id, m.first_name, m.last_name, mp.plan_name
FROM Members m
JOIN Membership_Plans mp ON m.membership_plan_id = mp.plan_id
WHERE m.join_date IS NOT NULL;

-- Create an index on Members email
CREATE INDEX idx_email ON Members(email);
Creating Triggers: Automate actions such as updating or validating data.


-- Create a trigger to update join_date to current date if it's NULL upon insertion
DELIMITER //
CREATE TRIGGER before_member_insert
BEFORE INSERT ON Members
FOR EACH ROW
BEGIN
    IF NEW.join_date IS NULL THEN
        SET NEW.join_date = CURDATE();
    END IF;
END;
//
DELIMITER ;

-- Create a stored procedure to add a new member
DELIMITER //
CREATE PROCEDURE AddMember(
    IN first_name VARCHAR(50),
    IN last_name VARCHAR(50),
    IN email VARCHAR(100),
    IN phone_number VARCHAR(15),
    IN membership_plan_id INT
)
BEGIN
    INSERT INTO Members (first_name, last_name, email, phone_number, join_date, membership_plan_id)
    VALUES (first_name, last_name, email, phone_number, CURDATE(), membership_plan_id);
END;
//
DELIMITER ;


-- Create a function to calculate the total payments made by a member
DELIMITER //
CREATE FUNCTION TotalPayments(member_id INT) RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(amount) INTO total FROM Payments WHERE Payments.member_id = member_id;
    RETURN total;
END;


-- Call the stored procedure to add a new member
CALL AddMember('Alice', 'Brown', 'alice@example.com', '555-123-4567', 1);
-- Verify the new member is added
SELECT * FROM Members WHERE email = 'alice@example.com';


-- Insert a member without specifying join_date to test the trigger
INSERT INTO Members (first_name, last_name, email, phone_number, membership_plan_id)
VALUES ('Bob', 'White', 'bob@example.com', '555-234-5678', 2);
-- Verify the join_date is automatically set to the current date
SELECT * FROM Members WHERE email = 'bob@example.com';


-- Calculate total payments made by a specific member
SELECT TotalPayments(1) AS
