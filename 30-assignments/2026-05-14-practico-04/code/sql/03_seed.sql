-- ============================================
-- CTI: Supertype anchors
-- ============================================
INSERT INTO Entity (ID, Active) VALUES
(1, 1),  -- Course: Base de Datos
(2, 1),  -- Student: Juan Pérez
(3, 1);  -- Teacher: Gabriel Gonzáles

-- ============================================
-- CTI: Subtypes
-- ============================================
INSERT INTO Course (ID, EntityID, Name, StartDate, EndDate, MaxCapacity) VALUES
(1, 1, 'Base de Datos', '2026-03-01', '2026-07-15', 40);

INSERT INTO Student (ID, EntityID, FullName, Email, Phone) VALUES
(1, 2, 'Juan Pérez', 'juan.perez@email.com', '123456789');

INSERT INTO Teacher (ID, EntityID, FullName, Email, Specialization) VALUES
(1, 3, 'Gabriel Gonzáles', 'gabriel@email.com', 'Bases de Datos');

-- ============================================
-- DDEAV: Escenario 2009 — solo "Presencialidad Plena"
-- ============================================
INSERT INTO OptionGroup (ID, Active, Name) VALUES
(1, 1, 'ModalidadCursada');

INSERT INTO OptionValue (ID, Active, Value) VALUES
(1, 1, 'Presencialidad Plena');

INSERT INTO ValidOption (ID, OptionValueID, OptionGroupID) VALUES
(1, 1, 1);

INSERT INTO EntityUniqueOption (EntityID, ValidOptionID, OptionGroupID) VALUES
(1, 1, 1);
