drop database Lab2;
CREATE DATABASE Lab2;

USE Lab2;

CREATE TABLE people (
    pid char(12) PRIMARY key,
    firstName char(50) NOT NULL,
    lastName char(50) NOT NULL,
    email char(50),
    affiliation char(50) NOT NULL,
    startdate DATE,
    enddate DATE
);

create table student (
    pid char(12) primary key,
    academic_program varchar(100),
    foreign key (pid) references people(pid)
);

create table Employee(
    pid char(12) primary key,
    phone_number int,
    office_space varchar(100),
    position varchar(100),
    foreign key (pid) references people(pid),
    supervisor_id char(12),
    foreign key (supervisor_id) references people(pid)
);

create table Academic(
    pid char(12) primary key,
    foreign key (pid) references Employee(pid)
);

create table Faculty(
    pid char(12) primary key,
    foreign key (pid) references Academic(pid)
);

create table Non_Academic(
    pid char(12) primary key,
    foreign key (pid) references Employee(pid)
);

CREATE Table administrative(
    pid char(12) PRIMARY key,
    Foreign Key (pid) REFERENCES Non_Academic(pid)
);

CREATE Table Technical(
    pid char(12) PRIMARY key,
    Foreign Key (pid) REFERENCES Non_Academic(pid)
);

CREATE TABLE advises (
    pidS char(12) NOT NULL,
    pidA char(12),
    PRIMARY KEY (pidA, pidS),
    FOREIGN KEY (pidS) REFERENCES student(pid),
    FOREIGN KEY (pidA) REFERENCES Academic(pid)
);

Create table laboratories (
    labid char(12) primary key,
    name char(50) NOT NULL,
    building char(50) NOT NULL,
    roomNumber int NOT NULL,
    discipline char(50),
    pidFac char(12) NOT NULL,
    FOREIGN KEY (pidFac) REFERENCES Faculty(pid)
);

create table attached (
    pid char(12),
    labid char(12) NOT NULL,
    PRIMARY KEY (pid, labid),
    FOREIGN KEY (pid) REFERENCES people(pid)
);

create table researchProject (
    code char(12) primary key,
    title char(50) NOT NULL,
    startdate DATE,
    enddate DATE,
    status char(50) check (status in ('Proposed', 'Active','Suspended','Completed','Cancelled'))
);

create table participates (
    role VARCHAR(50),
    participant_id char(12) NOT NULL,
    project_code char(12),
    primary key(participant_id,project_code),
    foreign key (participant_id) references people(pid),
    foreign key(project_code) references researchProject(code)
);

create table Budget (
    budgetLine char(50) primary key,
    amountGranted int,
    amountDisbursed int,
    startDate date,
    endDate date,
    managerid char(12) NOT NULL,
    foreign key (managerid) references Academic(pid)
);

create table fundsprj (
    budgetLine char(50) NOT NULL,
    project_code char(12),
    primary key (budgetLine,project_code),
    foreign key (budgetLine) references Budget(budgetLine),
    foreign key(project_code) references researchProject(code)
);

create table FundsLab (
    budgetid char(50) NOT NULL,
    labid char(12),
    foreign key (labid) references laboratories(labid),
    foreign key (budgetid) references Budget(budgetLine),
    primary key(budgetid,labid)
);

create table equipmentModel (
    modelId char(12) PRIMARY key,
    commercialName char(50),
    manufacturer char(50),
    category char(50),
    requiredEnvironment char(50),
    trainingMandatory char(50)
);

create table equipmentUnit (
    serialNo int PRIMARY key,
    acquisitionDate date,
    purchaseCost int,
    status char(50) check (status in ('InService', 'UnderMaintenance','OutOfService','Retired')),
    portable BOOLEAN,
    instanceOf char(12) NOT NULL,
    locatedIn char(12) NOT NULL,
    Foreign Key (locatedIn) REFERENCES laboratories(labid),
    Foreign Key (instanceOf) REFERENCES equipmentModel(modelId)
);

create table Certification (
    code char(12) PRIMARY KEY,
    title char(50),
    issuingAuthority char(50),
    validityPeriod DATE,
    safetyLevel int
);

create table Reservation (
    resId char(12) PRIMARY KEY,
    submissionTS DATETIME,
    plannedStart DATE,
    plannedEnd DATE,
    purpose char(50),
    status char(50) check (status in ('Pending', 'Approved','Rejected','Cancelled','Completed'))
);

create table Reserve(
    resId char(12), 
    serialNo int not null,
    foreign key (resid) references Reservation(resid),
    foreign key (serialNo) references equipmentUnit(serialNo),
    primary key (resid,serialNo)
);

create table Main_hasmain (
    startTS DATETIME,
    endTS DATETIME,
    type char(50) check (type in ('Preventive', 'Corrective')),
    description char(50),
    cost int,
    outcome char(50) check (outcome in ('Resolved', 'FollowUpRequired')),
    Equip_sernum int,
    technical_pid char(12),
    primary key (startTS,technical_pid,Equip_sernum),
    foreign key (technical_pid) references people(pid),
    foreign key (Equip_sernum) references equipmentUnit(serialNo)
);

create table calib_hascalib (
    calibDate DATE,
    calibrationType char(50),
    result char(50) check (result in ('Pass', 'Fail', 'Adjusted')),
    nextDueDate DATE,
    remarks char(50),
    Equip_sernum int,
    primary key (Equip_sernum, calibDate),
    foreign key (Equip_sernum) references equipmentUnit(serialNo)
);

create table Consumable (
    consId char(12) PRIMARY KEY,
    name char(50),
    unitOfMeasure char(50),
    hazardLevel int,
    reorderThreshold int
);

create table Supplier (
    suppId char(12) PRIMARY KEY,
    name char(50),
    contactEmail char(50),
    phone int
);

create table requires (
    modelId char(12),
    code char(12),
    PRIMARY KEY (modelId, code),
    Foreign Key (modelID) REFERENCES equipmentModel(modelId),
    Foreign Key (code) REFERENCES Certification(code)
);

CREATE Table holds(
    pid char(12),
    code char(12),
    expirationDate DATE,
    issueDate DATE,
    grade CHAR(12),
    Foreign Key (pid) REFERENCES people(pid),
    Foreign Key (code) REFERENCES Certification(code),
    PRIMARY KEY (pid, code)
);

CREATE Table stocks(
    consId char(12),
    labid char(12),
    pid char(12) NOT NULL,
    quantityOnHand INT,
    lastRestockDate DATE,
    storageCondition CHAR(12),
    monitoringSince DATE,
    Foreign Key (consId) REFERENCES Consumable(consId),
    Foreign Key (labid) REFERENCES laboratories(labid),
    Foreign Key (pid) REFERENCES Technical(pid),
    PRIMARY KEY (consId, labid)
);

CREATE Table supplies(
    consId char(12),
    labid char(12),
    suppId char(12),
    unitPrice INT,
    Foreign Key (consId) REFERENCES Consumable(consId),
    Foreign Key (labid) REFERENCES laboratories(labid),
    Foreign Key (suppId) REFERENCES Supplier(suppId),
    PRIMARY KEY (consId, labid, suppId)
);

CREATE TABLE consumes (
    resId char(12),
    consId char(12),
    labid char(12),
    quantityUsed INT,
    FOREIGN KEY (consId, labid) REFERENCES stocks(consId, labid),
    Foreign Key (resId) REFERENCES Reservation(resId),
    PRIMARY key (consId, resId, labid)
);