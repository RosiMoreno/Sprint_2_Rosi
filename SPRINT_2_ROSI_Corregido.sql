SELECT * FROM company;
SELECT * FROM transaction;
# Nivel 1
# Ejercicio 2
# Llistat dels països que estan fent compres.
SELECT DISTINCT country 
FROM company
JOIN transaction
ON transaction.company_id = company.id
WHERE declined = 0;

# Des de quants països es realitzen les compres.
SELECT count(distinct country)
FROM company
JOIN transaction
ON transaction.company_id = company.id
WHERE declined = 0;

# Identifica la companyia amb la mitjana més gran de vendes.
SELECT company_name, round(AVG(amount), 2) AS promedioempresa
FROM company
JOIN transaction
ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY company_name
ORDER BY promedioempresa DESC
LIMIT 1;


# Ejercicio 3
# Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT * FROM transaction
WHERE company_id IN (SELECT id 
					 FROM company
                     WHERE country = "Germany");

# Llista les empreses que han realitzat transaccions per un amount superior 
# a la mitjana de totes les transaccions.
SELECT company_id, max(amount) AS trans_sup_promediototal
FROM transaction
GROUP BY company_id
HAVING trans_sup_promediototal > (SELECT AVG(amount) AS promediototal
							FROM transaction)
ORDER BY trans_sup_promediototal DESC;

# opción 2
SELECT company_id
FROM transaction
WHERE amount > (SELECT AVG(amount) AS promediototal
					FROM transaction)
GROUP BY company_id;

# Promedio de ventas totales
SELECT round(AVG(amount), 2) AS promediototal
FROM transaction;
                        
# Eliminaran del sistema les empreses que no tenen transaccions registrades, 
# entrega el llistat d'aquestes empreses.
# usando una join
SELECT company_name
FROM company
RIGHT JOIN transaction
ON transaction.company_id = company.id
WHERE company.id IS NULL;

# usando una subquery
SELECT company_name
FROM company
WHERE NOT EXISTS (SELECT DISTINCT transaction.company_id 
						 FROM transaction);
# Nivell 2
# Exercici 1
# Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
# Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT DATE(timestamp), sum(amount)
FROM transaction
WHERE declined = 0
GROUP BY DATE(timestamp)
ORDER BY sum(amount) DESC
LIMIT 5;

# Exercici 2
# Quina és la mitjana de vendes per país? 
SELECT country, round(AVG(amount), 2) AS promediopais
FROM (SELECT country, amount
		FROM company
        JOIN transaction
        ON company.id = transaction.company_id
        WHERE declined = 0) AS ventaspais
GROUP BY country
ORDER BY promediopais DESC;

# Exercici 3
# En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries 
# per a fer competència a la companyia "Non Institute". 
# Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

# Mostra el llistat aplicant JOIN i subconsultes.
SELECT *
FROM transaction
JOIN company
ON company.id = transaction.company_id
WHERE country IN (SELECT country
									FROM company
									WHERE company_name = "Non Institute");

# Mostra el llistat aplicant solament subconsultes.
# Selecciono las compañías que están en el mismo país que Non Institute
SELECT id, company_name
FROM company
WHERE country IN (SELECT country
				  FROM company
				  WHERE company_name LIKE "Non Institute");

# Selecciono las transacciones hechas por estas compañías en este país con subconsultes anidadas.
SELECT *
FROM transaction
WHERE company_id IN (SELECT id
	  			     FROM company
				     WHERE country IN (SELECT country
								       FROM company
								       WHERE company_name LIKE "Non Institute"));

# Nivell 3
# Exercici 1
# Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros 
# i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. 
# Ordena els resultats de major a menor quantitat.

SELECT company_name, phone, country, DATE(timestamp) AS date, amount
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE amount BETWEEN 100 AND 200
HAVING date IN ("2021-04-29", "2021-07-20", "2022-03-13")
ORDER BY amount DESC;

# Exercici 2
# Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
# per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
# però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.
# Opción inicial (Más compleja)
SELECT company_name, 
CASE WHEN numtransaccions > 4 THEN "Más de 4"
	 ELSE "4 o menos" END AS mas_cuatre_transaccions
FROM (SELECT company_id, count(company_id) AS numtransaccions
	  FROM transaction
	  GROUP BY company_id) AS subquery
JOIN company
ON subquery.company_id = company.id;

# Opción corregida (más simple)
SELECT company_name, 
	 CASE WHEN count(company_id) > 4 THEN "Más de 4"
		  ELSE "4 o menos" END AS mas_cuatre_transaccions
FROM transaction
JOIN company
ON transaction.company_id = company.id
GROUP BY company_name;


