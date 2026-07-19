-- ============================================
-- CTI: Supertype
-- ============================================
CREATE TABLE Entity (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Active BIT DEFAULT 0
);

-- ============================================
-- CTI: Subtypes
-- ============================================
CREATE TABLE Student (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    EntityID INT UNIQUE NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    FOREIGN KEY (EntityID) REFERENCES Entity(ID)
);

CREATE TABLE Course (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    EntityID INT UNIQUE NOT NULL,
    Name VARCHAR(100) NOT NULL,
    StartDate DATE,
    EndDate DATE,
    MaxCapacity INT,
    FOREIGN KEY (EntityID) REFERENCES Entity(ID)
);

CREATE TABLE Teacher (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    EntityID INT UNIQUE NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    Specialization VARCHAR(100),
    FOREIGN KEY (EntityID) REFERENCES Entity(ID)
);

-- ============================================
-- DDEAV: Catalog tables
-- ============================================
CREATE TABLE OptionGroup (
    ID INT PRIMARY KEY,
    Active TINYINT DEFAULT 1,
    Name VARCHAR(100) NOT NULL
);

CREATE TABLE OptionValue (
    ID INT PRIMARY KEY,
    Active TINYINT DEFAULT 1,
    Value VARCHAR(255) NOT NULL
);

CREATE TABLE ValidOption (
    ID INT PRIMARY KEY,
    OptionValueID INT NOT NULL,
    OptionGroupID INT NOT NULL,
    UNIQUE (OptionGroupID, OptionValueID),
    FOREIGN KEY (OptionValueID) REFERENCES OptionValue(ID),
    FOREIGN KEY (OptionGroupID) REFERENCES OptionGroup(ID)
);

ALTER TABLE ValidOption ADD UNIQUE INDEX (OptionGroupID, ID);

-- ============================================
-- DDEAV: Bridge tables
-- ============================================
CREATE TABLE EntityUniqueOption (
    EntityID INT NOT NULL,
    ValidOptionID INT NOT NULL,
    OptionGroupID INT NOT NULL,
    UNIQUE (EntityID, OptionGroupID),
    FOREIGN KEY (EntityID) REFERENCES Entity(ID),
    FOREIGN KEY (OptionGroupID, ValidOptionID) REFERENCES ValidOption(OptionGroupID, ID)
);

CREATE TABLE EntityMultipleOption (
    EntityID INT NOT NULL,
    ValidOptionID INT NOT NULL,
    UNIQUE (EntityID, ValidOptionID),
    FOREIGN KEY (EntityID) REFERENCES Entity(ID),
    FOREIGN KEY (ValidOptionID) REFERENCES ValidOption(ID)
);
