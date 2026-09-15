-- 99: Verificación punta a punta (Ej.1–Ej.6, estado final)
-- Qué: smoke test que falla con EXCEPTION si alguna consigna no se cumple.
--   Termina con NOTICE 'VERIFY OK' si todo pasa.
-- Cómo se usa: `make verify`. Se corre DESPUÉS de la cadena completa
--   (`make all`: setup → schema → seed → queries → update → delete → verify).
-- Estado final esperado: 2 filas (John con birth_date '1994-05-15' + Jane);
--   Mike Brown ya no existe (Ej.6).
-- Nota fecha-dependiente: la edad se calcula contra CURRENT_DATE, así que el test
--   NO aserta conteos absolutos de "mayores de 30" (Jane cruza los 30 en 2028);
--   aserta pertenencia (John, nacido en 1994, siempre está en el conjunto) y
--   coherencia entre las dos formulaciones de 4.3 (EXTRACT vs INTERVAL).
-- Cada bloque -- Ej.N indica qué consigna prueba; si algo falla, el mensaje dice
--   cuál (ej. 'Ej.5 falló: ...') para saber dónde mirar.
-- Glosario: docs/GLOSSARY.md (DO, FOUND no usado aquí, RAISE EXCEPTION/NOTICE).

DO $$
DECLARE
    v_n INT;
    v_birth DATE;
    v_name TEXT;
    v_age_extract INT;
    v_age_interval INT;
BEGIN
    -- Ej.2: la tabla existe con las 6 columnas de la consigna
    SELECT COUNT(*) INTO v_n
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'patients';
    IF v_n <> 6 THEN RAISE EXCEPTION 'Ej.2 falló: columnas=% (esperado 6)', v_n; END IF;

    -- Ej.3 + Ej.6: quedan 2 filas (Mike borrado)
    SELECT COUNT(*) INTO v_n FROM patients;
    IF v_n <> 2 THEN RAISE EXCEPTION 'Ej.3/Ej.6 falló: filas=% (esperado 2)', v_n; END IF;

    -- Ej.6: Mike Brown ya no existe
    SELECT COUNT(*) INTO v_n FROM patients WHERE first_name = 'Mike' AND last_name = 'Brown';
    IF v_n <> 0 THEN RAISE EXCEPTION 'Ej.6 falló: Mike Brown sigue presente'; END IF;

    -- Ej.5: John Doe existe y su fecha es '1994-05-15'
    SELECT birth_date INTO v_birth FROM patients WHERE first_name = 'John' AND last_name = 'Doe';
    IF NOT FOUND THEN RAISE EXCEPTION 'Ej.5 falló: John Doe no existe'; END IF;
    IF v_birth <> DATE '1994-05-15' THEN RAISE EXCEPTION 'Ej.5 falló: birth_date=%', v_birth; END IF;

    -- Ej.4.4: lookup por teléfono devuelve a John Doe
    SELECT CONCAT(first_name, ' ', last_name) INTO v_name FROM patients WHERE phone = '123456789';
    IF NOT FOUND THEN RAISE EXCEPTION 'Ej.4.4 falló: teléfono 123456789 sin resultado'; END IF;
    IF v_name <> 'John Doe' THEN RAISE EXCEPTION 'Ej.4.4 falló: nombre=%', v_name; END IF;

    -- Ej.4.2: edad calculada coherente y no nula para John
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date))::INT INTO v_age_extract
    FROM patients WHERE first_name = 'John' AND last_name = 'Doe';
    IF v_age_extract IS NULL OR v_age_extract <= 30 THEN
        RAISE EXCEPTION 'Ej.4.2 falló: edad John=%', v_age_extract;
    END IF;

    -- Ej.4.3: John está en el conjunto "mayores de 30" (pertenencia, no conteo)
    SELECT COUNT(*) INTO v_n FROM patients
    WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) > 30
      AND first_name = 'John' AND last_name = 'Doe';
    IF v_n <> 1 THEN RAISE EXCEPTION 'Ej.4.3 falló: John no está en >30'; END IF;

    -- Ej.4.3 coherencia: formulación EXTRACT vs INTERVAL devuelven lo mismo
    SELECT COUNT(*) INTO v_age_extract FROM patients
    WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) > 30;
    SELECT COUNT(*) INTO v_age_interval FROM patients
    WHERE birth_date < CURRENT_DATE - INTERVAL '30 years';
    IF v_age_extract <> v_age_interval THEN
        RAISE EXCEPTION 'Ej.4.3 falló: EXTRACT=% vs INTERVAL=%', v_age_extract, v_age_interval;
    END IF;

    -- Ej.4.1: SELECT * devuelve las 2 filas finales
    SELECT COUNT(*) INTO v_n FROM (SELECT * FROM patients) s;
    IF v_n <> 2 THEN RAISE EXCEPTION 'Ej.4.1 falló: filas=%', v_n; END IF;

    RAISE NOTICE 'VERIFY OK: Ej.1-Ej.6 cumplen (2 filas, John 1994-05-15, sin Mike)';
END $$;
