-- SQL Code that creates tables and inserts test cases, written by Shay Pearson

-- Creating tables:
-- For instances where length of a string will not change, CHAR is used to inrease speed over VARCHAR. 
-- Where the length is likely to vary I have used VARCHAR instead as this saves memory.

-- Defines Table 'Student'
CREATE TABLE Student(
	StudentID CHAR(9) UNIQUE NOT NULL,
	Password VARCHAR(20),
	-- Specifies primary key
	CONSTRAINT Student_Primary_key PRIMARY KEY (StudentID));
	
-- Defines Table 'Module'
CREATE TABLE Module(
	ModuleCode CHAR(6) UNIQUE NOT NULL,
	ModuleTitle VARCHAR(20),
	-- Specifies primary key
	CONSTRAINT Module_Primary_Key PRIMARY KEY (ModuleCode));

-- Defines Weak Entity 'Enrolment'
CREATE TABLE Enrolment(
	StudentID CHAR(9) NOT NULL,
	ModuleCode CHAR(6) NOT NULL,
	-- Specifies primary composite key
	CONSTRAINT Enrolment_Primary_Key PRIMARY KEY (StudentID, ModuleCode),
	-- Specifies foreign keys
	CONSTRAINT Student_Foreign_Key FOREIGN KEY (StudentID) REFERENCES Student (StudentID),
	CONSTRAINT Module_Foreign_Key FOREIGN KEY (ModuleCode) REFERENCES Module (ModuleCode));

-- Defines Table 'Assessment'
CREATE TABLE Assessment(
	AssessmentID SERIAL UNIQUE NOT NULL,
	Description VARCHAR(30),
	-- CHECK to ensure Deadline set is after certain date
	Deadline TIMESTAMP CHECK (Deadline > '2019-09-15'),
	-- Specifies primary key
	CONSTRAINT Assessment_Primary_Key PRIMARY KEY (AssessmentID));

-- Creates Weak Entity 'ModuleAssessments'
CREATE TABLE ModuleAssessments(
	ModuleCode CHAR(6) NOT NULL,
	AssessmentID INT UNIQUE NOT NULL,
	-- Specifies primary composite key
	CONSTRAINT Module_Assessment_Primary_Key PRIMARY KEY (ModuleCode, AssessmentID),
	-- Specifies foreign keys
	CONSTRAINT Module_Foreign_Key FOREIGN KEY (ModuleCode) REFERENCES Module (ModuleCode),
	CONSTRAINT Assessment_Foreign_Key FOREIGN KEY (AssessmentID) REFERENCES Assessment (AssessmentID));
	
-- Defines Table 'Session'
CREATE TABLE Session(
	-- SERIAL creates auto-incrementing value
	SessionID SERIAL UNIQUE NOT NULL,
	ModuleCode CHAR(6) NOT NULL,
	SessionType VARCHAR(10),
	-- CHECK that session is allocated within Uni lecture hours
	Time TIME CHECK (Time BETWEEN '09:00:00' AND '20:00:00'),
	DayOfWeek VARCHAR(10),
	Room CHAR(6),
	Duration TIME,
	-- Specifies primary key
	CONSTRAINT Session_Primary_Key PRIMARY KEY (SessionID),
	-- Specifies foreign key
	CONSTRAINT Module_Foreign_Key FOREIGN KEY (ModuleCode) REFERENCES Module (ModuleCode),
	-- Prevents duplicate bookings of sessions
	CONSTRAINT Duplicate_Bookings UNIQUE(DayOfWeek, Time, Room));
	
-- Defines function to be used in check in ChosenSessions table. Checks if a student is enrolled on a chosen session (is allowed to access it)
CREATE FUNCTION EnrolledOnSession(StuID CHAR(9), SesID INT) RETURNS INT AS $$
	BEGIN
	RETURN COUNT(*) FROM(SELECT Enrolment.ModuleCode FROM Enrolment WHERE StuID = Enrolment.StudentID INTERSECT (SELECT Session.ModuleCode FROM Session WHERE SesID = Session.SessionID)) AS Result;
	END; $$
	LANGUAGE PLPGSQL;
	
-- Defines Weak Entity 'ChosenSessions'
CREATE TABLE ChosenSessions(
	StudentID CHAR(9) NOT NULL,
	SessionID INT NOT NULL,
	-- Specifies primary composite key
	CONSTRAINT Chosen_Sessions_Primary_Key PRIMARY KEY (StudentID, SessionID),
	-- Specifies foreign keys
	CONSTRAINT Student_Foreign_Key FOREIGN KEY (StudentID) REFERENCES Student (StudentID),
	CONSTRAINT Session_Foreign_Key FOREIGN KEY (SessionID) REFERENCES Session (SessionID),
	-- Checks if student is enrolled on module which session is for (stops students from accessing classes from other modules)
	CONSTRAINT Access_To_Session CHECK(EnrolledOnSession(StudentID, SessionID) > 0));

-- Defines Table 'Event'
CREATE TABLE Event(
	-- SERIAL creates auto-incrementing value
	EventID SERIAL UNIQUE NOT NULL,
	Description VARCHAR(30),
	Time TIME,
	Duration TIME,
	-- CHECK to ensure event date set is after certain date
	Date DATE CHECK (Date > '2019-09-15'),
	-- Specifies primary key
	CONSTRAINT Event_Primary_Key PRIMARY KEY (EventID));

-- Defines Weak Entity 'CustomEvent'
CREATE TABLE CustomEvent(
	StudentID CHAR(9) NOT NULL,
	EventID INT NOT NULL,
	-- Specifies primary composite key
	CONSTRAINT Custom_Event_Primary_Key PRIMARY KEY (StudentID, EventID),
	-- Specifies foreign keys
	CONSTRAINT Student_Foreign_Key FOREIGN KEY (StudentID) REFERENCES Student (StudentID),
	CONSTRAINT Event_Foreign_Key FOREIGN KEY (EventID) REFERENCES Event (EventID));
	
-- Defines Table 'Staff'
CREATE TABLE Staff(
	StaffID SERIAL UNIQUE NOT NULL,
	EmailAddress VARCHAR(35),
	Name VARCHAR(30),
	OfficeNumber CHAR(6),
	TelephoneNumber VARCHAR(15),
	-- Specifies primary key
	CONSTRAINT Staff_Primary_Key PRIMARY KEY (StaffID));
	
-- Defines Table 'ModuleLeader'
CREATE TABLE ModuleLeader(
	StaffID INT NOT NULL,
	ModuleCode CHAR(6) UNIQUE NOT NULL,
	OfficeHours VARCHAR(30),
	-- Specifies primary composite key
	CONSTRAINT Module_Leader_Primary_Key PRIMARY KEY (StaffID, ModuleCode),
	-- Specifies foreign keys
	CONSTRAINT Module_Foreign_Key FOREIGN KEY (ModuleCode) REFERENCES Module (ModuleCode),
	CONSTRAINT Staff_Foreign_Key FOREIGN KEY (StaffID) REFERENCES Staff (StaffID));
	
-- Defines Table 'Tutor'
CREATE TABLE Tutor(
	StaffID INT NOT NULL,
	ModuleCode CHAR(6) NOT NULL,
	-- Specifies primary composite key
	CONSTRAINT Tutor_Primary_Key PRIMARY KEY (StaffID, ModuleCode),
	-- Specifies foreign keys
	CONSTRAINT Module_Foreign_Key FOREIGN KEY (ModuleCode) REFERENCES Module (ModuleCode),
	CONSTRAINT Staff_Foreign_Key FOREIGN KEY (StaffID) REFERENCES Staff (StaffID));

-- Inserting values from test case document:
-- Populating Student Table
INSERT INTO Student VALUES ('328145291', 'zogbogfrog');
INSERT INTO Student VALUES ('578274289', 'superman');

-- Populating Module Table
INSERT INTO Module VALUES ('5CC507', 'Databases');
INSERT INTO Module VALUES ('6CC529', 'Game Behaviour');
INSERT INTO Module VALUES ('5CC516', 'Software Engineering');
INSERT INTO Module VALUES ('4CC510', 'Programming I');
INSERT INTO Module VALUES ('4CC511', 'Programming II');
INSERT INTO Module VALUES ('5CC518', NULL);

-- Populating Enrolment Table
-- Student 328145291
INSERT INTO Enrolment VALUES ('328145291', '5CC507');
INSERT INTO Enrolment VALUES ('328145291', '5CC516');
INSERT INTO Enrolment VALUES ('328145291', '4CC510');
INSERT INTO Enrolment VALUES ('328145291', '5CC518');
-- Student 578274289
INSERT INTO Enrolment VALUES ('578274289', '6CC529');
INSERT INTO Enrolment VALUES ('578274289', '5CC516');

-- Populating Assessment Table
-- Module 5CC507
INSERT INTO Assessment VALUES (DEFAULT, 'Milestone 1', '2019-10-06 17:00:00');
INSERT INTO Assessment VALUES (DEFAULT, 'Milestone 2', '2019-11-06 17:00:00');
INSERT INTO Assessment VALUES (DEFAULT, 'Project hand-in', '2019-12-12 23:59:00');
-- Module 6CC529
INSERT INTO Assessment VALUES (DEFAULT, 'Performance Review', '2019-12-12 23:59:00');
-- Module 5CC516
INSERT INTO Assessment VALUES (DEFAULT, 'Portfolio hand-in', '2019-12-12 23:59:00');
-- Module 4CC510
INSERT INTO Assessment VALUES (DEFAULT, 'Portfolio hand-in', '2019-12-12 17:00:00');
-- Module 4CC511
INSERT INTO Assessment VALUES (DEFAULT, 'Project hand-in', '2019-10-18 23:59:00');
INSERT INTO Assessment VALUES (DEFAULT, 'Quiz', '2019-12-12 12:00:00');

-- Links assessments to modules
INSERT INTO ModuleAssessments VALUES('5CC507', 1);
INSERT INTO ModuleAssessments VALUES('5CC507', 2);
INSERT INTO ModuleAssessments VALUES('5CC507', 3);
INSERT INTO ModuleAssessments VALUES('6CC529', 4);
INSERT INTO ModuleAssessments VALUES('5CC516', 5);
INSERT INTO ModuleAssessments VALUES('4CC510', 6);
INSERT INTO ModuleAssessments VALUES('4CC511', 7);
INSERT INTO ModuleAssessments VALUES('4CC511', 8);

-- Populating Session Table
-- Module 5CC507
INSERT INTO Session VALUES (DEFAULT, '5CC507', 'Tutorial', '09:00:00', 'Friday', 'MS316', '01:00:00');-- 1 
INSERT INTO Session VALUES (DEFAULT, '5CC507', 'Tutorial', '10:00:00', 'Friday', 'MS316', '01:00:00');-- 2 
INSERT INTO Session VALUES (DEFAULT, '5CC507', 'Tutorial', '14:00:00', 'Friday', 'MS316', '01:00:00');-- 3 
INSERT INTO Session VALUES (DEFAULT, '5CC507', 'Tutorial', '15:00:00', 'Friday', 'MS316', '01:00:00');-- 4
INSERT INTO Session VALUES (DEFAULT, '5CC507', 'Tutorial', '16:00:00', 'Friday', 'MS316', '01:00:00');-- 5 
-- Module 6CC529
INSERT INTO Session VALUES (DEFAULT, '6CC529', 'Tutorial', '11:00:00', 'Monday', 'MS214', '02:00:00');-- 6
-- Module 5CC516
INSERT INTO Session VALUES (DEFAULT, '5CC516', 'Tutorial', '11:00:00', 'Wednesday', 'MS214', '01:00:00');-- 7
INSERT INTO Session VALUES (DEFAULT, '5CC516', 'Tutorial', '11:00:00', 'Thursday', 'MS038', '01:00:00');-- 8 
-- Module 4CC510
INSERT INTO Session VALUES (DEFAULT, '4CC510', 'Tutorial', '09:00:00', 'Tuesday', 'MS304', '08:00:00');-- 9 
INSERT INTO Session VALUES (DEFAULT, '4CC510', 'Tutorial', '09:00:00', 'Tuesday', 'MS304a', '08:00:00');-- 10 
-- Module 4CC511
INSERT INTO Session VALUES (DEFAULT, '4CC511', 'Tutorial', '09:00:00', 'Monday', 'MS304', '01:00:00');-- 11 
INSERT INTO Session VALUES (DEFAULT, '4CC511', 'Tutorial', '11:00:00', 'Monday', 'MS304', '01:00:00');-- 12
INSERT INTO Session VALUES (DEFAULT, '4CC511', 'Tutorial', '13:00:00', 'Monday', 'MS213', '01:00:00');-- 13 
INSERT INTO Session VALUES (DEFAULT, '4CC511', 'Tutorial', '10:00:00', 'Tuesday', 'MS304a', '01:00:00');-- 14
INSERT INTO Session VALUES (DEFAULT, '4CC511', 'Tutorial', '11:00:00', 'Tuesday', 'MS212', '01:00:00');-- 15 
INSERT INTO Session VALUES (DEFAULT, '4CC511', 'Tutorial', '13:00:00', 'Thursday', 'MS214', '01:00:00');-- 16 
-- Module 5CC518
-- Inserted different time from test data as one provided is duplicate (room already booked for module 5CC507 on Friday at 14:00) - Flagged by UNIQUE constraint in Session Table
INSERT INTO Session VALUES (DEFAULT, '5CC518', 'Tutorial', '12:00:00', 'Friday', 'MS316', '01:00:00');-- 17 

-- Linking students to their chosen sessions
-- Student 328145291
INSERT INTO ChosenSessions VALUES ('328145291', 3);
INSERT INTO ChosenSessions VALUES ('328145291', 17);
INSERT INTO ChosenSessions VALUES ('328145291', 8);
INSERT INTO ChosenSessions VALUES ('328145291', 9);
-- Student 578274289
INSERT INTO ChosenSessions VALUES ('578274289', 6);
INSERT INTO ChosenSessions VALUES ('578274289', 8);

-- Populating Event Table
INSERT INTO Event VALUES (DEFAULT, 'Pub - Standing Order', '19:00:00', '03:59:00', '2019-10-23');
INSERT INTO Event VALUES (DEFAULT, 'Sunday Lunch', '13:00:00', '02:00:00', '2019-11-29');
INSERT INTO Event VALUES (DEFAULT, 'Gym', '12:00:00', '01:30:00', '2019-11-13');
INSERT INTO Event VALUES (DEFAULT, 'Project Meeting', '13:00:00', '15:00:00', '2019-11-12');

-- Linking events to student
INSERT INTO CustomEvent VALUES ('328145291', 1);
INSERT INTO CustomEvent VALUES ('328145291', 2);
INSERT INTO CustomEvent VALUES ('578274289', 3);
INSERT INTO CustomEvent VALUES ('578274289', 4);

-- Populating Staff Table
INSERT INTO Staff VALUES (DEFAULT, 'l.stella@derby.ac.uk', 'Leonardo Stella', 'MS308', '1410');
INSERT INTO Staff VALUES (DEFAULT, 'c.windmill@derby.ac.uk', 'Chris Windmill', 'MS310', '9216');
INSERT INTO Staff VALUES (DEFAULT, 'y.zheng@derby.ac.uk', 'Yongjun Zheng', 'MS310', '9989');
INSERT INTO Staff VALUES (DEFAULT, 'w.rippin@derby.ac.uk', 'Wayne Rippin', 'MS308', '8989');
INSERT INTO Staff VALUES (DEFAULT, 'n.jones@derby.ac.uk', 'Nige', 'MS304', NULL);
INSERT INTO Staff VALUES (DEFAULT, NULL, 'Farhan', 'E512', NULL);
INSERT INTO Staff VALUES (DEFAULT, NULL, 'Jack', 'MS218', NULL);
INSERT INTO Staff VALUES (DEFAULT, 'a.zhang@derby.ac.uk', 'Andy', '4CC511', NULL);

-- Populating ModuleLeader Table
INSERT INTO ModuleLeader VALUES (1, '5CC507', 'Thu 13 - 17');
INSERT INTO ModuleLeader VALUES (1, '6CC529', 'Thu 13 - 17');
INSERT INTO ModuleLeader VALUES (2, '5CC516', 'Fri 12 - 16');
INSERT INTO ModuleLeader VALUES (3, '4CC510', 'Tue 13 - 17');
INSERT INTO ModuleLeader VALUES (4, '4CC511', 'Thu 9 - 12');

-- Populating Tutor Table
INSERT INTO Tutor VALUES (5, '5CC507');
INSERT INTO Tutor VALUES (6, '5CC507');
INSERT INTO Tutor VALUES (7, '5CC516');
INSERT INTO Tutor VALUES (8, '4CC511');

-- Creating views to test constraints - not needed but i may as well leave the code here for testing purposes
-- Creates a view to show students chosen sessions
/*
CREATE VIEW UniTimeTable AS
SELECT Student.StudentID AS StudentID, Session.ModuleCode AS ModuleCode, Session.SessionType AS SessionType, Session.Room AS Room, Session.DayOfWeek AS DayOfWeek, Session.Time AS Time, Session.Duration AS Duration
FROM Student, ChosenSessions, Session
WHERE Student.StudentID = ChosenSessions.StudentID
AND ChosenSessions.SessionID = Session.SessionID;

-- Creates a view to show students custom events
CREATE VIEW EventsTimeTable AS
SELECT Student.StudentID AS StudentID, Event.Description AS Description, Event.Date AS Date, Event.Time AS Time, Event.Duration AS Duration
FROM Student, CustomEvent, Event
WHERE Student.StudentID = CustomEvent.StudentID
AND CustomEvent.EventID = Event.EventID;

-- Creates a view to show assessments for each student
CREATE VIEW Assessments AS
SELECT Student.StudentID AS StudentID, Module.ModuleCode AS ModuleCode, Module.ModuleTitle AS ModuleTitle, Assessment.Description AS AssessmentDescription, Assessment.Deadline AS AssessmentDeadline
FROM Student, Enrolment, Module, ModuleAssessments, Assessment
WHERE Student.StudentID = Enrolment.StudentID
AND Enrolment.ModuleCode = Module.ModuleCode
AND Module.ModuleCode = ModuleAssessments.ModuleCode
AND ModuleAssessments.AssessmentID = Assessment.AssessmentID;

-- Creates a view to show leaders staff to each module
CREATE View ModuleStaff AS
SELECT Module.ModuleCode AS ModuleCode, Module.ModuleTitle AS ModuleTitle, Staff.Name AS Name, Staff.EmailAddress AS Email, Staff.OfficeNumber AS OfficeNumber, Staff.TelephoneNumber AS TelephoneNumber
FROM Staff, ModuleLeader, Module
WHERE Module.ModuleCode = ModuleLeader.ModuleCode
AND ModuleLeader.StaffID = Staff.StaffID
UNION
SELECT Module.ModuleCode AS ModuleCode, Module.ModuleTitle AS ModuleTitle, Staff.Name AS Name, Staff.EmailAddress AS Email, Staff.OfficeNumber AS OfficeNumber, Staff.TelephoneNumber AS TelephoneNumber
FROM Staff, Tutor, Module
WHERE Module.ModuleCode = Tutor.ModuleCode
AND Tutor.StaffID = Staff.StaffID;
*/
