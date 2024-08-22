
-------------------------------------------------------------------------------------
--------------- /* DATOS ABIERTOS ANALISIS DE DATOS EN SQL */ -----------------------
-------------------------------------------------------------------------------------


-- NUMERO DE HABITANTES A LA ULTIMA FECHA DE LA DATA / POBLACION POR DEPARTAMENTO

SELECT SUM(POBLACION) POBLACION_TOTAL FROM 
(SELECT DEPARTAMENTO, MAX(POBLACION_DEPARTAMENTO) POBLACION
		FROM DAPROJECT
		GROUP BY DEPARTAMENTO) A;

SELECT DEPARTAMENTO, MAX(POBLACION_DEPARTAMENTO) POBLACION
		FROM DAPROJECT
		GROUP BY DEPARTAMENTO;

-- CANTIDAD DE CONEXIONES POR TECNOLOGIAS 

SELECT PERIODO,TECNOLOGÍA , SUM(CANT_CONEXIONES) CONEXIONES_TOTALES
	   FROM DAPROJECT
	   GROUP BY PERIODO,TECNOLOGÍA
	   ORDER BY PERIODO, SUM(CANT_CONEXIONES) DESC;

-- CANTIDAD DE CONEXIONES POR EMPRESA / TOTAL DE CONEXIONES

SELECT EMPRESA, SUM(CANT_CONEXIONES) CONEXIONES_TOTALES
		FROM DAPROJECT
		GROUP BY EMPRESA ORDER BY SUM(CANT_CONEXIONES) DESC;

SELECT SUM(CONEXIONES_TOTALES) CONEXIONES_TOTALES FROM (
SELECT EMPRESA, SUM(CANT_CONEXIONES) CONEXIONES_TOTALES
		FROM DAPROJECT
		GROUP BY EMPRESA-- ORDER BY SUM(CANT_CONEXIONES) DESC
		) A;
	
-- CREAMOS UN NUEVO CAMPO (REGION)

ALTER TABLE DAPROJECT
ADD REGION NVARCHAR(50);

UPDATE DAPROJECT
SET REGION = 
    CASE 
        WHEN DEPARTAMENTO = 'PIURA' THEN 'COSTA'
        WHEN DEPARTAMENTO = 'AMAZONAS' THEN 'SELVA'
        WHEN DEPARTAMENTO = 'LIMA' THEN 'COSTA'
        WHEN DEPARTAMENTO = 'AYACUCHO' THEN 'SIERRA'
        WHEN DEPARTAMENTO = 'CALLAO' THEN 'COSTA'
        WHEN DEPARTAMENTO = 'AREQUIPA' THEN 'SIERRA'
        WHEN DEPARTAMENTO = 'LA LIBERTAD' THEN 'COSTA'
        WHEN DEPARTAMENTO = 'MADRE DE DIOS' THEN 'SELVA'
        WHEN DEPARTAMENTO = 'TACNA' THEN 'COSTA'
        WHEN DEPARTAMENTO = 'APURIMAC' THEN 'SIERRA'
        WHEN DEPARTAMENTO = 'PASCO' THEN 'SIERRA'
        WHEN DEPARTAMENTO = 'HUANCAVELICA' THEN 'SIERRA'
        WHEN DEPARTAMENTO = 'SAN MARTIN' THEN 'SELVA'
        WHEN DEPARTAMENTO = 'LORETO' THEN 'SELVA'
        WHEN DEPARTAMENTO = 'LAMBAYEQUE' THEN 'COSTA'
        WHEN DEPARTAMENTO = 'TUMBES' THEN 'COSTA'
        WHEN DEPARTAMENTO = 'ANCASH' THEN 'SIERRA'
        WHEN DEPARTAMENTO = 'CUSCO' THEN 'SIERRA'
        WHEN DEPARTAMENTO = 'UCAYALI' THEN 'SELVA'
        WHEN DEPARTAMENTO = 'CAJAMARCA' THEN 'SIERRA'
        WHEN DEPARTAMENTO = 'MOQUEGUA' THEN 'COSTA'
        WHEN DEPARTAMENTO = 'HUANUCO' THEN 'SIERRA'
        WHEN DEPARTAMENTO = 'ICA' THEN 'COSTA'
        WHEN DEPARTAMENTO = 'JUNIN' THEN 'SIERRA'
        WHEN DEPARTAMENTO = 'PUNO' THEN 'SIERRA'
        ELSE 'DESCONOCIDO'
    END;


SELECT DISTINCT REGION FROM DAPROJECT;

-- CANTIDAD DE CONEXIONES POR REGION 

SELECT PERIODO,REGION, SUM(CANT_CONEXIONES) CONEXIONES_TOTALES
		FROM DAPROJECT
		GROUP BY PERIODO,REGION ORDER BY PERIODO,SUM(CANT_CONEXIONES) DESC;


-- AGREGAMOS EL CAMPO VELOCIDAD EN MBPS

UPDATE DAPROJECT
SET VELOC_INFERIOR_KBPS = '0'
WHERE VELOC_INFERIOR_KBPS = 'N.A.'; -- REMPLAZAMOS LOS N.A POR EL VALOR 0

ALTER TABLE DAPROJECT 
ALTER COLUMN VELOC_INFERIOR_KBPS FLOAT; -- CONVERTIMOS A FLOAT EL CAMPO

-- NUEVO CAMPO EN MBPS PARA VEL_INF

ALTER TABLE DAPROJECT
ADD VEL_INF_MBPS FLOAT; 

UPDATE DAPROJECT
SET VEL_INF_MBPS = 
    CASE WHEN VELOC_INFERIOR_KBPS = '0' THEN AVG(VELOC_INFERIOR_KBPS)/1024
		ELSE VELOC_INFERIOR_KBPS/1024
		 END;

-- NUEVO CAMPO EN MBPS PARA VEL_SUP

UPDATE DAPROJECT
SET VELOC_SUPERIOR_EXCLUYENTE_KBPS = '0'
WHERE VELOC_SUPERIOR_EXCLUYENTE_KBPS = 'N.A.';

ALTER TABLE DAPROJECT 
ALTER COLUMN VELOC_SUPERIOR_EXCLUYENTE_KBPS FLOAT;

ALTER TABLE DAPROJECT
ADD VEL_SUP_MBPS FLOAT; 

UPDATE DAPROJECT
SET VEL_SUP_MBPS = 
    CASE WHEN VELOC_SUPERIOR_EXCLUYENTE_KBPS = '0' THEN AVG(VELOC_SUPERIOR_EXCLUYENTE_KBPS)/1024
		ELSE VELOC_SUPERIOR_EXCLUYENTE_KBPS/1024
		 END;


-- VELOCIDAD PROMEDIO INFERIOR Y SUPERIOR EN MBPS POR REGION , DEPARTAMENTO Y DISTRITO

SELECT PERIODO,REGION,ROUND(AVG(VEL_INF_MBPS),2) VELPROM_INF_MBPS, ROUND(AVG(VEL_SUP_MBPS),2) VELPROM_SUP_MBPS
	FROM DAPROJECT
	GROUP BY PERIODO,REGION
	ORDER BY PERIODO, ROUND(AVG(VEL_INF_MBPS),2) DESC;



SELECT PERIODO,REGION,DEPARTAMENTO , ROUND(AVG(VEL_INF_MBPS),2) VELPROM_INF_MBPS,ROUND(AVG(VEL_SUP_MBPS),2) VELPROM_SUP_MBPS
	FROM DAPROJECT
	GROUP BY PERIODO,REGION,DEPARTAMENTO
	ORDER BY PERIODO,REGION, AVG(VEL_INF_MBPS) DESC;


-- VELOCIDAD PROMEDIO INFERIOR Y SUPERIOR (MBPS) EN LOS DISTRITOS DE LIMA

SELECT PERIODO,DEPARTAMENTO,DISTRITO,ROUND(AVG(VEL_INF_MBPS),2) VELPROM_INF_MBPS, ROUND(AVG(VEL_SUP_MBPS),2) VELPROM_SUP_MBPS
	FROM DAPROJECT
	WHERE DEPARTAMENTO = 'LIMA'
	GROUP BY PERIODO,DEPARTAMENTO,DISTRITO
	ORDER BY PERIODO, AVG(VEL_INF_MBPS) DESC;

-- DISTRITOS DE LIMA CON UNA MALA CALIDAD DE INTERNET ( <30 Mbps)

SELECT PERIODO,DISTRITO,VELPROM_INF_MBPS,VELPROM_SUP_MBPS
	FROM (SELECT PERIODO,DEPARTAMENTO,DISTRITO,ROUND(AVG(VEL_INF_MBPS),2) VELPROM_INF_MBPS, ROUND(AVG(VEL_SUP_MBPS),2) VELPROM_SUP_MBPS
	FROM DAPROJECT
	WHERE DEPARTAMENTO = 'LIMA'
	GROUP BY PERIODO,DEPARTAMENTO,DISTRITO) A WHERE VELPROM_INF_MBPS < 30 
	ORDER BY PERIODO,VELPROM_INF_MBPS;


-- VELOCIDAD PROMEDIO INFERIOR Y SUPERIOR (MBPS) POR TECNOLOGIA

SELECT PERIODO,TECNOLOGÍA,DEPARTAMENTO,DISTRITO,ROUND(AVG(VEL_INF_MBPS),2) VELPROM_INF_MBPS, ROUND(AVG(VEL_SUP_MBPS),2) VELPROM_SUP_MBPS
	FROM DAPROJECT
	WHERE DEPARTAMENTO = 'LIMA'
	GROUP BY PERIODO,TECNOLOGÍA,DEPARTAMENTO,DISTRITO
	ORDER BY PERIODO,TECNOLOGÍA, AVG(VEL_INF_MBPS) DESC;

-- DISTRITOS DE LIMA CON MALA CALIDAD DE INTERNET POR TIPO DE TECNOLOGIA

SELECT PERIODO, DEPARTAMENTO, DISTRITO ,TECNOLOGÍA, VELPROM_INF_MBPS,VELPROM_SUP_MBPS
	FROM	(
SELECT PERIODO,TECNOLOGÍA,DEPARTAMENTO,DISTRITO,ROUND(AVG(VEL_INF_MBPS),2) VELPROM_INF_MBPS, ROUND(AVG(VEL_SUP_MBPS),2) VELPROM_SUP_MBPS
	FROM DAPROJECT
	WHERE DEPARTAMENTO = 'LIMA'
	GROUP BY PERIODO,TECNOLOGÍA,DEPARTAMENTO,DISTRITO) A WHERE VELPROM_INF_MBPS < 30  
	ORDER BY PERIODO, DISTRITO,TECNOLOGÍA, VELPROM_INF_MBPS;

-- PRINCIPALES TECNOLOGIAS POR REGION

SELECT PERIODO, REGION, TECNOLOGÍA, SUM(CANT_CONEXIONES) TOTAL_CONEXIONES
	FROM DAPROJECT GROUP BY PERIODO,REGION, TECNOLOGÍA
	ORDER BY PERIODO, REGION, SUM(CANT_CONEXIONES) DESC



-- TASA DE PENETRACION DE INTERNET POR DEPARTAMENTO / PROVINCIA / DISTRITO

SELECT
    PERIODO,DEPARTAMENTO,
    (SUM(CANT_CONEXIONES) * 100.0) / MAX(POBLACION_DEPARTAMENTO) AS TASA_DE_PENETRACION_INTERNET
FROM DAPROJECT
GROUP BY PERIODO,DEPARTAMENTO ORDER BY DEPARTAMENTO,PERIODO,3;

SELECT
    PERIODO,DEPARTAMENTO,PROVINCIA,
    (SUM(CANT_CONEXIONES) * 100.0) / MAX(POBLACION_PROVINCIA) AS TASA_DE_PENETRACION_INTERNET
FROM DAPROJECT
GROUP BY PERIODO,DEPARTAMENTO,PROVINCIA ORDER BY DEPARTAMENTO,PROVINCIA,PERIODO,4 ;

SELECT
    PERIODO,DEPARTAMENTO,DISTRITO,
    (SUM(CANT_CONEXIONES) * 100.0) / MAX(POBLACION_DISTRITO) AS TASA_DE_PENETRACION_INTERNET
FROM DAPROJECT
GROUP BY PERIODO,DEPARTAMENTO,DISTRITO ORDER BY DEPARTAMENTO,DISTRITO,PERIODO,4 DESC;

-- COMPARACION DE VELOCIDADES POR EMPRESA OPERADORA

SELECT
    EMPRESA,
    AVG(VEL_INF_MBPS+ VEL_SUP_MBPS)/2 AS PROM_VEL_INTERNET
FROM DAPROJECT
GROUP BY EMPRESA ORDER BY 2 DESC

-- PARTICIPACION DE MERCADO POR EMPRESA

SELECT
    EMPRESA,
    (SUM(CANT_CONEXIONES) * 100.0) / (SELECT SUM(CANT_CONEXIONES) 
	FROM DAPROJECT) AS Participacion_Mercado
FROM DAPROJECT GROUP BY EMPRESA ORDER BY 2 DESC;


-- SELECT * FROM DAPROJECT

