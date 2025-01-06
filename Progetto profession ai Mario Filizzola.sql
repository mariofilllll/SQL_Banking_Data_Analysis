SELECT DATABASE(); 
use banca;

-- Drop delle tabelle temporanee esistenti (se presenti)
DROP TEMPORARY TABLE IF EXISTS eta_cliente;
DROP TEMPORARY TABLE IF EXISTS temp_transazioni_uscita;
DROP TEMPORARY TABLE IF EXISTS temp_transazioni_entrata;
DROP TEMPORARY TABLE IF EXISTS temp_importo_uscita;
DROP TEMPORARY TABLE IF EXISTS temp_importo_entrata;
DROP TEMPORARY TABLE IF EXISTS temp_conti;
DROP TEMPORARY TABLE IF EXISTS temp_conto_tipologia;
DROP TEMPORARY TABLE IF EXISTS temp_transazioni_uscita_per_tipo_conto;
DROP TEMPORARY TABLE IF EXISTS temp_transazioni_entrata_per_tipo_conto;
DROP TEMPORARY TABLE IF EXISTS temp_importo_uscita_per_tipo_conto;
DROP TEMPORARY TABLE IF EXISTS temp_importo_entrata_per_tipo_conto;

-- 1. Età del cliente
CREATE TEMPORARY TABLE eta_cliente AS
SELECT id_cliente, nome, cognome, TIMESTAMPDIFF(YEAR, data_nascita, CURDATE()) AS eta
FROM cliente;

-- 2. Numero di transazioni in uscita
CREATE TEMPORARY TABLE temp_transazioni_uscita AS
SELECT c.id_cliente, COUNT(t.id_conto) AS num_transazioni_uscita
FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
LEFT JOIN transazioni t ON co.id_conto = t.id_conto
LEFT JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '-'  -- Uscite
GROUP BY c.id_cliente;

-- 3. Numero di transazioni in entrata
CREATE TEMPORARY TABLE temp_transazioni_entrata AS
SELECT c.id_cliente, COUNT(t.id_conto) AS num_transazioni_entrata
FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
LEFT JOIN transazioni t ON co.id_conto = t.id_conto
LEFT JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '+'  -- Entrate
GROUP BY c.id_cliente;

-- 4. Importo transato in uscita su tutti i conti
CREATE TEMPORARY TABLE temp_importo_uscita AS
SELECT c.id_cliente, SUM(t.importo) AS importo_uscita
FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
LEFT JOIN transazioni t ON co.id_conto = t.id_conto
LEFT JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '-'  -- Uscite
GROUP BY c.id_cliente;

-- 5. Importo transato in entrata su tutti i conti
CREATE TEMPORARY TABLE temp_importo_entrata AS
SELECT c.id_cliente, SUM(t.importo) AS importo_entrata
FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
LEFT JOIN transazioni t ON co.id_conto = t.id_conto
LEFT JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '+'  -- Entrate
GROUP BY c.id_cliente;

-- 6. Numero totale di conti posseduti
CREATE TEMPORARY TABLE temp_conti AS
SELECT c.id_cliente, COUNT(co.id_conto) AS num_conti
FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
GROUP BY c.id_cliente;

-- 7. Numero di conti posseduti per tipologia (una colonna per ogni tipo di conto)
CREATE TEMPORARY TABLE temp_conto_tipologia AS
SELECT c.id_cliente,
    SUM(CASE WHEN co.id_tipo_conto = 1 THEN 1 ELSE 0 END) AS num_conto_tipo_1,
    SUM(CASE WHEN co.id_tipo_conto = 2 THEN 1 ELSE 0 END) AS num_conto_tipo_2,
    SUM(CASE WHEN co.id_tipo_conto = 3 THEN 1 ELSE 0 END) AS num_conto_tipo_3
FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
GROUP BY c.id_cliente;

-- 8. Numero di transazioni in uscita per tipologia di conto
CREATE TEMPORARY TABLE temp_transazioni_uscita_per_tipo_conto AS
SELECT 
    c.id_cliente,
    SUM(CASE WHEN co.id_tipo_conto = 1 THEN 1 ELSE 0 END) AS num_trans_uscita_tipo_1,
    SUM(CASE WHEN co.id_tipo_conto = 2 THEN 1 ELSE 0 END) AS num_trans_uscita_tipo_2,
    SUM(CASE WHEN co.id_tipo_conto = 3 THEN 1 ELSE 0 END) AS num_trans_uscita_tipo_3
FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
LEFT JOIN transazioni t ON co.id_conto = t.id_conto
LEFT JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '-'  -- Uscite
GROUP BY c.id_cliente;

-- 9. Numero di transazioni in entrata per tipologia di conto
CREATE TEMPORARY TABLE temp_transazioni_entrata_per_tipo_conto AS
SELECT 
    c.id_cliente,
    SUM(CASE WHEN co.id_tipo_conto = 1 THEN 1 ELSE 0 END) AS num_trans_entrata_tipo_1,
    SUM(CASE WHEN co.id_tipo_conto = 2 THEN 1 ELSE 0 END) AS num_trans_entrata_tipo_2,
    SUM(CASE WHEN co.id_tipo_conto = 3 THEN 1 ELSE 0 END) AS num_trans_entrata_tipo_3
FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
LEFT JOIN transazioni t ON co.id_conto = t.id_conto
LEFT JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '+'  -- Entrate
GROUP BY c.id_cliente;

-- 10. Importo transato in uscita per tipologia di conto
CREATE TEMPORARY TABLE temp_importo_uscita_per_tipo_conto AS
SELECT 
    c.id_cliente,
    SUM(CASE WHEN co.id_tipo_conto = 1 THEN t.importo ELSE 0 END) AS importo_uscita_tipo_1,
    SUM(CASE WHEN co.id_tipo_conto = 2 THEN t.importo ELSE 0 END) AS importo_uscita_tipo_2,
    SUM(CASE WHEN co.id_tipo_conto = 3 THEN t.importo ELSE 0 END) AS importo_uscita_tipo_3
FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
LEFT JOIN transazioni t ON co.id_conto = t.id_conto
LEFT JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '-'  -- Uscite
GROUP BY c.id_cliente;

-- 11. Importo transato in entrata per tipologia di conto
CREATE TEMPORARY TABLE temp_importo_entrata_per_tipo_conto AS
SELECT 
    c.id_cliente,
    SUM(CASE WHEN co.id_tipo_conto = 1 THEN t.importo ELSE 0 END) AS importo_entrata_tipo_1,
    SUM(CASE WHEN co.id_tipo_conto = 2 THEN t.importo ELSE 0 END) AS importo_entrata_tipo_2,
    SUM(CASE WHEN co.id_tipo_conto = 3 THEN t.importo ELSE 0 END) AS importo_entrata_tipo_3
FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
LEFT JOIN transazioni t ON co.id_conto = t.id_conto
LEFT JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '+'  -- Entrate
GROUP BY c.id_cliente;

-- Tabella Denormalizzata
DROP TABLE IF EXISTS tabella_denormalizzata;
CREATE TABLE tabella_denormalizzata AS
SELECT 
    c.id_cliente, 
    c.nome, 
    c.cognome, 
    COALESCE(e.eta, 0) AS eta, 
    COALESCE(tu.num_transazioni_uscita, 0) AS num_transazioni_uscita, 
    COALESCE(te.num_transazioni_entrata, 0) AS num_transazioni_entrata, 
    COALESCE(iu.importo_uscita, 0) AS importo_uscita, 
    COALESCE(ie.importo_entrata, 0) AS importo_entrata, 
    COALESCE(cnt.num_conti, 0) AS num_conti,
    COALESCE(tp.num_conto_tipo_1, 0) AS num_conto_tipo_1,
    COALESCE(tp.num_conto_tipo_2, 0) AS num_conto_tipo_2,
    COALESCE(tp.num_conto_tipo_3, 0) AS num_conto_tipo_3,
    COALESCE(tut.num_trans_uscita_tipo_1, 0) AS num_trans_uscita_tipo_1,
    COALESCE(tut.num_trans_uscita_tipo_2, 0) AS num_trans_uscita_tipo_2,
    COALESCE(tut.num_trans_uscita_tipo_3, 0) AS num_trans_uscita_tipo_3,
    COALESCE(tet.num_trans_entrata_tipo_1, 0) AS num_trans_entrata_tipo_1,
    COALESCE(tet.num_trans_entrata_tipo_2, 0) AS num_trans_entrata_tipo_2,
    COALESCE(tet.num_trans_entrata_tipo_3, 0) AS num_trans_entrata_tipo_3,
    COALESCE(iup.importo_uscita_tipo_1, 0) AS importo_uscita_tipo_1,
    COALESCE(iup.importo_uscita_tipo_2, 0) AS importo_uscita_tipo_2,
    COALESCE(iup.importo_uscita_tipo_3, 0) AS importo_uscita_tipo_3,
    COALESCE(iep.importo_entrata_tipo_1, 0) AS importo_entrata_tipo_1,
    COALESCE(iep.importo_entrata_tipo_2, 0) AS importo_entrata_tipo_2,
    COALESCE(iep.importo_entrata_tipo_3, 0) AS importo_entrata_tipo_3
FROM cliente c
LEFT JOIN eta_cliente e ON c.id_cliente = e.id_cliente
LEFT JOIN temp_transazioni_uscita tu ON c.id_cliente = tu.id_cliente
LEFT JOIN temp_transazioni_entrata te ON c.id_cliente = te.id_cliente
LEFT JOIN temp_importo_uscita iu ON c.id_cliente = iu.id_cliente
LEFT JOIN temp_importo_entrata ie ON c.id_cliente = ie.id_cliente
LEFT JOIN temp_conti cnt ON c.id_cliente = cnt.id_cliente
LEFT JOIN temp_conto_tipologia tp ON c.id_cliente = tp.id_cliente
LEFT JOIN temp_transazioni_uscita_per_tipo_conto tut ON c.id_cliente = tut.id_cliente
LEFT JOIN temp_transazioni_entrata_per_tipo_conto tet ON c.id_cliente = tet.id_cliente
LEFT JOIN temp_importo_uscita_per_tipo_conto iup ON c.id_cliente = iup.id_cliente
LEFT JOIN temp_importo_entrata_per_tipo_conto iep ON c.id_cliente = iep.id_cliente;


