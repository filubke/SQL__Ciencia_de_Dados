/* Query's feitas no pgAdmin utilizando Query Tool em PostgreSQL 16 */

CREATE DATABASE trabalho2_sql;

SELECT current_database();

-- Cria uma tabela Geral. 
CREATE TEMP TABLE geral_temp (
    unique_key INTEGER PRIMARY KEY,
    created_date VARCHAR(30),
    closed_date VARCHAR(30),
    agency VARCHAR(50),
    agency_name VARCHAR(100),
    complaint_type VARCHAR(100),
    descriptor VARCHAR(200),
    location_type VARCHAR(100),
    incident_zip VARCHAR(10),
    incident_address VARCHAR(200),
    street_name VARCHAR(100),
    cross_street_1 VARCHAR(100),
    cross_street_2 VARCHAR(100),
    intersection_street_1 VARCHAR(100),
    intersection_street_2 VARCHAR(100),
    address_type VARCHAR(50),
    city VARCHAR(100),
    landmark VARCHAR(100),
    facility_type VARCHAR(100),
    status VARCHAR(50),
    due_date VARCHAR(30),
    resolution_description TEXT,
    resolution_action_updated_date VARCHAR(30),
    community_board VARCHAR(50),
    bbl VARCHAR(50),
    borough VARCHAR(50),
    x_coordinate_state_plane NUMERIC,
    y_coordinate_state_plane NUMERIC,
    open_data_channel_type VARCHAR(50),
    park_facility_name VARCHAR(100),
    park_borough VARCHAR(50),
    vehicle_type VARCHAR(100),
    taxi_company_borough VARCHAR(100),
    taxi_pick_up_location VARCHAR(100),
    bridge_highway_name VARCHAR(100),
    bridge_highway_direction VARCHAR(100),
    road_ramp VARCHAR(100),
    bridge_highway_segment VARCHAR(100),
    latitude NUMERIC,
    longitude NUMERIC,
    location VARCHAR(100)
);

-- copiar os dados do CSV. 
COPY geral_temp 
	FROM 'D:\Users\Choko\Downloads\311_Service_Requests_from_2010_to_Present_20240703.csv'
	WITH (FORMAT csv, HEADER true);

-- contar as linhas das tabela
SELECT COUNT(*) FROM geral_temp;

/* Criando 4 tabelas para receber os dados temporarios. */
-- complains 
CREATE TABLE complaints (
    unique_key INTEGER PRIMARY KEY,
    created_date VARCHAR(30),
    closed_date VARCHAR(30),
    complaint_type VARCHAR(100),
    descriptor VARCHAR(200),
    status VARCHAR(50),
    due_date VARCHAR(30),
    resolution_description TEXT,
    resolution_action_updated_date VARCHAR(30),
	agency_id INTEGER,
	location_id INTEGER,
	additional_info_id INTEGER
/*	,FOREIGN KEY (agency_id) REFERENCES agencies(agency_id),
	FOREIGN KEY (location_id) REFERENCES locations(location_id),
	FOREIGN KEY (additional_info_id) REFERENCES additional_info(additional_info_id) */
);

-- locations 
CREATE TABLE locations  (
	location_id SERIAL PRIMARY KEY,
	unique_key INTEGER,
    location_type VARCHAR(100),
    incident_zip VARCHAR(10),
    incident_address VARCHAR(200),
    street_name VARCHAR(100),
    cross_street_1 VARCHAR(100),
    cross_street_2 VARCHAR(100),
    intersection_street_1 VARCHAR(100),
    intersection_street_2 VARCHAR(100),
    address_type VARCHAR(50),
    city VARCHAR(100),
    landmark VARCHAR(100),
    bbl VARCHAR(50),
    borough VARCHAR(50),
    x_coordinate_state_plane NUMERIC,
    y_coordinate_state_plane NUMERIC,
	taxi_pick_up_location VARCHAR(100),
    bridge_highway_name VARCHAR(100),
    bridge_highway_direction VARCHAR(100),
    road_ramp VARCHAR(100),
    bridge_highway_segment VARCHAR(100),
    latitude NUMERIC,
    longitude NUMERIC,
    location VARCHAR(100),
	FOREIGN KEY (unique_key) REFERENCES complaints(unique_key)
);

-- agencies 
CREATE TABLE agencies (
    agency_id SERIAL PRIMARY KEY,
	unique_key INTEGER,
	agency VARCHAR(50),
    agency_name VARCHAR(100),
    community_board VARCHAR(50),
    taxi_company_borough VARCHAR(100),
	FOREIGN KEY (unique_key) REFERENCES complaints(unique_key)
);

-- additional_info 
CREATE TABLE additional_info  (
    additional_info_id SERIAL PRIMARY KEY,
	unique_key INTEGER,
    facility_type VARCHAR(100),
    open_data_channel_type VARCHAR(50),
    park_facility_name VARCHAR(100),
    park_borough VARCHAR(50),
    vehicle_type VARCHAR(100),
	FOREIGN KEY (unique_key) REFERENCES complaints(unique_key)
);

/* Copiando os dados para as 4 tabelas. */

-- Copiar dados para a tabela complaints
INSERT INTO complaints (
    unique_key, created_date, closed_date, complaint_type, descriptor, status,
    due_date, resolution_description, resolution_action_updated_date
)
SELECT 
    unique_key, created_date, closed_date, complaint_type, descriptor, status,
    due_date, resolution_description, resolution_action_updated_date
	FROM geral_temp;

-- Copiar dados para a tabela locations
INSERT INTO agencies (
    unique_key, agency, agency_name, community_board, taxi_company_borough
)
SELECT
    unique_key, agency, agency_name, community_board, taxi_company_borough
FROM geral_temp;

-- Copiar dados para a tabela additional_info 
INSERT INTO additional_info  (
    unique_key, facility_type, open_data_channel_type, park_facility_name, park_borough, vehicle_type
)
SELECT 
    unique_key, facility_type, open_data_channel_type, park_facility_name, park_borough, vehicle_type
FROM geral_temp;

-- Copiar dados para a tabela locations
INSERT INTO locations (
    unique_key, location_type, incident_zip, incident_address, street_name, cross_street_1, cross_street_2,
	intersection_street_1, intersection_street_2, address_type, city, landmark, bbl, borough,
	x_coordinate_state_plane, y_coordinate_state_plane, taxi_pick_up_location, bridge_highway_name,
	bridge_highway_direction, road_ramp, bridge_highway_segment, latitude, longitude, location
)
SELECT 
    unique_key, location_type, incident_zip, incident_address, street_name, cross_street_1, cross_street_2,
	intersection_street_1, intersection_street_2, address_type, city, landmark, bbl, borough,
	x_coordinate_state_plane, y_coordinate_state_plane, taxi_pick_up_location, bridge_highway_name,
	bridge_highway_direction, road_ramp, bridge_highway_segment, latitude, longitude, location
FROM geral_temp;

/* verificando a integridade das relações entre as tabelas */
--Contar o Número de Registros em Cada Tabela
SELECT 
    (SELECT COUNT(*) FROM complaints) AS complaints_count,
    (SELECT COUNT(*) FROM agencies) AS agencies_count,
    (SELECT COUNT(*) FROM additional_info) AS additional_info_count,
    (SELECT COUNT(*) FROM locations) AS locations_count;

-- Verifica se os id's estão na mesma linha
SELECT 
	c.unique_key, 
	a.agency_id, 
	l.location_id, 
	ai.additional_info_id
	FROM complaints c
	JOIN agencies a ON c.unique_key = a.unique_key
	JOIN locations l ON c.unique_key = l.unique_key
	JOIN additional_info ai ON c.unique_key = ai.unique_key
LIMIT 10;

-- Verificar se os dados das tabelas estão corretamente relacionados
SELECT 
	c.unique_key, 
	c.complaint_type, 
	a.agency_name, 
	l.city 
FROM complaints c
JOIN agencies a ON c.unique_key = a.unique_key
JOIN locations l ON c.unique_key = l.unique_key
LIMIT 10;

-- seleciona um location id com unique key e mais informações da tabela locations
SELECT 
    location_id,
    unique_key,
    location_type,
    incident_address,
    city
FROM 
    locations
ORDER BY location_id
LIMIT 10;

-- seleciona todos os id's com um unique key e informações de cada tabela para verificar se a relação está correta
SELECT 
    l.location_id,
	a.agency_id,
	ai.additional_info_id,
    l.unique_key,
    l.location_type,
    l.incident_address,
    l.city,
    a.agency,
    c.complaint_type,
    ai.facility_type
FROM 
    complaints c
JOIN 
    locations l ON c.unique_key = l.unique_key
JOIN 
    agencies a ON c.unique_key = a.unique_key
JOIN 
    additional_info ai ON c.unique_key = ai.unique_key
WHERE 
    c.unique_key = 37171497;

-- faz outra seleção para verificar integridade das relações
SELECT 
	c.unique_key, 
	ai.additional_info_id, 
	l.location_id, 
	c.complaint_type, 
	ai.facility_type, 
	ai.vehicle_type,
	l.city
FROM complaints c
JOIN additional_info ai ON c.unique_key = ai.unique_key
JOIN locations l ON c.unique_key = l.unique_key
LIMIT 10;

--Verificar agencies com complaints:
SELECT 
	c.unique_key, 
	a.agency_id,
	a.agency_name,
	a.agency,
	a.community_board,
	a.taxi_company_borough,
	c.complaint_type,
	c.created_date
FROM complaints c
JOIN agencies a ON c.unique_key = a.unique_key
LIMIT 10;

--Verificar additional_info com complaints:
SELECT 
	c.unique_key,
	ai.additional_info_id,
	ai.facility_type,
	ai.open_data_channel_type,
	ai.park_facility_name,
	ai.park_borough,
	ai.vehicle_type
FROM complaints c
JOIN additional_info ai ON c.unique_key = ai.unique_key
LIMIT 10;

--Verificar locations com complaints:
SELECT 
	c.unique_key,
	l.location_id,
	l.location_type,
	l.address_type,
	l.city,
	l.borough
FROM complaints c
JOIN locations l ON c.unique_key = l.unique_key
LIMIT 10;


/* parte das perguntas */

-- Criar a tabela temporária para verificar incidentes que foram reportados mais de uma vez em um curto período de tempo (utilizando o dia e semana)

CREATE TEMPORARY TABLE temp_repeated_incidents_day AS
WITH repeated_incidents AS (
    SELECT
        c.complaint_type,
        l.address_type,
        l.incident_address,
        l.city,
		l.borough,
        c.created_date,
        DATE_PART('year', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')) AS report_year,
        DATE_PART('month', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')) AS report_month,
        DATE_PART('week', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')) AS report_week,
        DATE_PART('day', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')) AS report_day,
        COUNT(c.unique_key) AS report_count
    FROM
        complaints c
    JOIN
        locations l ON c.unique_key = l.unique_key
    JOIN
        agencies a ON c.unique_key = a.unique_key
    JOIN
        additional_info ai ON c.unique_key = ai.unique_key
    GROUP BY
        c.complaint_type,
        l.address_type,
        l.incident_address,
        l.city,
		l.borough,
        c.created_date,
        DATE_PART('year', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')),
        DATE_PART('month', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')),
        DATE_PART('week', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')),
        DATE_PART('day', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM'))
    HAVING
        COUNT(c.unique_key) > 1
)
SELECT
    complaint_type,
    address_type,
    incident_address,
    city,
	borough,
    created_date,
    report_year,
    report_month,
    report_week,
    report_day,
    report_count
FROM
    repeated_incidents
ORDER BY
    report_year, report_month, report_week, report_day, report_count DESC;

CREATE TEMPORARY TABLE temp_repeated_incidents_week AS
WITH repeated_incidents AS (
    SELECT
        c.complaint_type,
        l.address_type,
        l.incident_address,
        l.city,
		l.borough,
        c.created_date,
        DATE_PART('year', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')) AS report_year,
        DATE_PART('month', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')) AS report_month,
        DATE_PART('week', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')) AS report_week,
        COUNT(c.unique_key) AS report_count
    FROM
        complaints c
    JOIN
        locations l ON c.unique_key = l.unique_key
    JOIN
        agencies a ON c.unique_key = a.unique_key
    JOIN
        additional_info ai ON c.unique_key = ai.unique_key
    GROUP BY
        c.complaint_type,
        l.address_type,
        l.incident_address,
        l.city,
		l.borough,
        c.created_date,
        DATE_PART('year', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')),
        DATE_PART('month', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')),
        DATE_PART('week', TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM'))
    HAVING
        COUNT(c.unique_key) > 1
)
SELECT
    complaint_type,
    address_type,
    incident_address,
    city,
	borough,
    created_date,
    report_year,
    report_month,
    report_week,
    report_count
FROM
    repeated_incidents
ORDER BY
    report_year, report_month, report_week, report_count DESC;

SELECT * FROM temp_repeated_incidents_day;
SELECT * FROM temp_repeated_incidents_week;

-- Calcula a duração média dos incidentes para cada tipo de reclamação
CREATE TEMPORARY TABLE temp_average_duration AS
SELECT 
    c.complaint_type,
    AVG(TO_TIMESTAMP(c.closed_date, 'MM/DD/YYYY HH:MI:SS AM') - TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')) AS average_duration
FROM 
    complaints c
JOIN
    locations l ON c.unique_key = l.unique_key
JOIN
    agencies a ON c.unique_key = a.unique_key
JOIN
    additional_info ai ON c.unique_key = ai.unique_key
WHERE 
    c.closed_date IS NOT NULL
GROUP BY 
    c.complaint_type
ORDER BY
    average_duration DESC;
SELECT * FROM temp_average_duration;
CREATE TEMPORARY TABLE temp_average_duration_count AS
SELECT 
    c.complaint_type,
    COUNT(c.unique_key) AS complaint_count,
    AVG(TO_TIMESTAMP(c.closed_date, 'MM/DD/YYYY HH:MI:SS AM') - TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')) AS average_duration
FROM 
    complaints c
JOIN
    locations l ON c.unique_key = l.unique_key
JOIN
    agencies a ON c.unique_key = a.unique_key
JOIN
    additional_info ai ON c.unique_key = ai.unique_key
WHERE 
    c.closed_date IS NOT NULL
GROUP BY 
    c.complaint_type
ORDER BY
    average_duration DESC;
SELECT * FROM temp_average_duration_count;

CREATE TEMPORARY TABLE temp_average_descriptor AS
SELECT 
    c.descriptor,
    AVG(TO_TIMESTAMP(c.closed_date, 'MM/DD/YYYY HH:MI:SS AM') - TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')) AS average_duration
FROM 
    complaints c
JOIN
    locations l ON c.unique_key = l.unique_key
JOIN
    agencies a ON c.unique_key = a.unique_key
JOIN
    additional_info ai ON c.unique_key = ai.unique_key
WHERE 
    c.closed_date IS NOT NULL
GROUP BY 
    c.descriptor
ORDER BY
    average_duration DESC;
SELECT * FROM temp_average_descriptor;

/*Pré-processamento:*/

/* Para a normalização do nome das agências, primeiro vamos verificar o nome das agências
depois vamos substituir com o nome correto, aqui poderiamos agilizar o processo substitiundo pelo que mais
tem recorrencia, mas foi escolhido um processo manual, após a substituição cria-se um consulta para verificar se foi tudo corrigido.
Site utilizado para os nomes das agencias https://www.nyc.gov/nyc-resources/agencies.page*/
--Verificação geral para ver quais as agency em um tabela temporaria para facilitar a consulta recorrrente
CREATE TEMPORARY TABLE temp_agency_name AS
SELECT 
    agency,
    agency_name,
    COUNT(*) AS count_records
FROM 
    agencies
GROUP BY 
    agency,
    agency_name
ORDER BY
    agency, count_records DESC;
SELECT * FROM temp_agency_name;

-- agency NYPD -> agency_name New York City Police Department
UPDATE 
	agencies
SET agency_name = 'New York City Police Department'
WHERE agency = 'NYPD';
-- agency HPD -> agency_name Department of Housing Preservation and Development
UPDATE 
	agencies
SET agency_name = 'Department of Housing Preservation and Development'
WHERE agency = 'HPD';
-- agency DCWP -> agency_name Department of Consumer and Worker Protection
UPDATE 
	agencies
SET agency_name = 'Department of Consumer and Worker Protection'
WHERE agency = 'DCWP';
-- agency DOB -> agency_name Department of Buildings
UPDATE
	agencies
SET agency_name = 'Department of Buildings'
WHERE agency = 'DOB';
-- agency DOE -> agency_name Department of Education
UPDATE 
	agencies
SET agency_name = 'Department of Education'
WHERE agency = 'DOE';
-- agency 3-1-1 -> agency_name "3-1-1 Call Center"
UPDATE 
	agencies
SET agency_name = '3-1-1 Call Center'
WHERE agency = '3-1-1';
-- agency ACS -> agency_name Administration for Children's Services
UPDATE 
	agencies
SET agency_name = 'Administration for Children"s Services'
WHERE agency = 'ACS';
-- agency DFTA -> agency_name Department for the Aging
UPDATE 
	agencies
SET agency_name = 'Department for the Aging'
WHERE agency = 'DFTA';
-- agency DHS -> agency_name Department of Homeless Services
UPDATE 
	agencies
SET agency_name = 'Department of Homeless Services'
WHERE agency = 'DHS';
-- agency DFTA -> agency_name Department of Finance
UPDATE 
	agencies
SET agency_name = 'Department of Finance'
WHERE agency = 'DOF';
-- agency DOHMH -> agency_name Department of Health and Mental Hygiene
UPDATE 
	agencies
SET agency_name = 'Department of Health and Mental Hygiene'
WHERE agency = 'DOHMH';
-- agency DOT -> agency_name Department of Transportation
UPDATE 
	agencies
SET agency_name = 'Department of Transportation'
WHERE agency = 'DOT';
-- agency FDNY -> agency_name Fire Department of New York
UPDATE 
	agencies
SET agency_name = 'Fire Department of New York'
WHERE agency = 'FDNY';
-- agency NYCEM -> agency_name NYC Emergency Management
UPDATE 
	agencies
SET agency_name = 'NYC Emergency Management'
WHERE agency = 'NYCEM';
-- agency TLC -> agency_name Taxi and Limousine Commission
UPDATE 
	agencies
SET agency_name = 'Taxi and Limousine Commission'
WHERE agency = 'TLC';
-- agency DPR -> agency_name Department of Parks and Recreation
UPDATE 
	agencies
SET agency_name = 'Department of Parks and Recreation'
WHERE agency = 'DPR';
-- agency COIB -> agency_name Conflicts of Interest Board
UPDATE 
	agencies
SET agency_name = 'Conflicts of Interest Board'
WHERE agency = 'COIB';
-- agency DCAS -> agency_name Department of Citywide Administrative Services
UPDATE 
	agencies
SET agency_name = 'Department of Citywide Administrative Services'
WHERE agency = 'DCAS';
-- agency DCP -> agency_name Department of City Planning
UPDATE 
	agencies
SET agency_name = 'Department of City Planning'
WHERE agency = 'DCP';
-- agency DVS -> agency_name Department of Veterans' Services
UPDATE 
	agencies
SET agency_name = 'Department of Veterans Services'
WHERE agency = 'DVS';
-- agency OMB -> agency_name Office of Management and Budget
UPDATE 
	agencies
SET agency_name = 'Office of Management and Budget'
WHERE agency = 'OMB';
-- agency CEO -> agency_name Center for Employment Opportunities
UPDATE 
	agencies
SET agency_name = 'Center for Employment Opportunities'
WHERE agency = 'CEO';
-- agency DORIS -> agency_name Department of Records & Information Services
UPDATE 
	agencies
SET agency_name = 'Department of Records & Information Services'
WHERE agency = 'DORIS';
-- agency MOC -> agency_name Mayor Office of Contract Services
UPDATE 
	agencies
SET agency_name = 'Mayor Office of Contract Services'
WHERE agency = 'MOC';
-- agency TAT -> agency_name Tax Appeals Tribunal
UPDATE 
	agencies
SET agency_name = 'Tax Appeals Tribunal'
WHERE agency = 'TAT';
-- agency TAX -> agency_name Department of Taxation and Finance
UPDATE 
	agencies
SET agency_name = 'Department of Taxation and Finance'
WHERE agency = 'TAX';

-- verifica todos agency_name e agency
SELECT 
    agency,
    agency_name,
    COUNT(*) AS count_records
FROM 
    agencies
GROUP BY 
    agency,
    agency_name
ORDER BY
    agency, count_records DESC;

/* Vamos utilizar um caminho parecido ao da normalização dos nomes das agencias, vamos verificar os campos
vazios e qual seu incident_zip e usalos como base para preencher.*/


--Verificação geral para ver quais os zip não tem city em um tabela temporaria para facilitar a consulta recorrrente
CREATE TEMPORARY TABLE temp_city_info AS
SELECT
    city,
    incident_zip,
    borough
FROM
    complaints c
JOIN
    locations l ON c.unique_key = l.unique_key
JOIN
    agencies a ON c.unique_key = a.unique_key
JOIN
    additional_info ai ON c.unique_key = ai.unique_key;

-- Criar outra tabela temporária para registros onde city está vazio a partir da temporaria anterior
CREATE TEMPORARY TABLE temp_city_zip_borough AS
SELECT
    city,
    incident_zip,
    borough,
    COUNT(*) AS count_records
FROM
    temp_city_info
GROUP BY
    city,
    incident_zip,
    borough
ORDER BY
    city, incident_zip, borough;
SELECT * FROM temp_city_info;
-- Seleciona a tabela temporaria ordenando os campos city vazios e pela sua contagem
SELECT
    city,
    incident_zip,
    borough,
    count_records
FROM
    temp_city_zip_borough
WHERE
    city IS NULL OR city = ''
ORDER BY
    count_records DESC;

-- contagem de quantas vezes o nome city  de um incident_zip aparece
SELECT 
    city,
    COUNT(*) AS count_records
FROM
    temp_city_info
WHERE
    incident_zip = '11207'
GROUP BY
    city
ORDER BY
    count_records DESC;

--Verificar consistencia de linhas especificas em relação a cidade
SELECT 
    l.unique_key,
    l.city,
    l.incident_zip,
    l.borough,
    c.descriptor,
	c.resolution_description
FROM
    locations l
JOIN
    complaints c ON l.unique_key = c.unique_key
WHERE
    l.city = '.'
GROUP BY
    l.unique_key,
    l.city,
    l.incident_zip,
    l.borough,
    c.descriptor,
	c.resolution_description
ORDER BY
    l.unique_key;
/* Como não temos um padrão na coluna city, foi decidido utilizar o chat gpt como auxiliar para gerar o local 
se baseando no zip code fornecido pelo incident_zip, assim foi gerado uma lista de zip em relação a lista de city vazio
com isso preenchemos os city vazios e todos que tinha o mesmo zip foram "normalizados"*/

CREATE TEMPORARY TABLE zip_city_mapping (
    zip_code VARCHAR(10) PRIMARY KEY,
    city VARCHAR(100)
);

-- Inserir os dados de zip_code e city na tabela temporária
INSERT INTO zip_city_mapping (zip_code, city) VALUES
    ('11385', 'Queens'),
    ('11207', 'Brooklyn'),
    ('10019', 'Manhattan'),
    ('10457', 'Bronx'),
    ('10452', 'Bronx'),
    ('11208', 'Brooklyn'),
    ('11234', 'Brooklyn'),
    ('10025', 'Manhattan'),
    ('11201', 'Brooklyn'),
    ('10467', 'Bronx'),
    ('10468', 'Bronx'),
    ('11211', 'Brooklyn'),
    ('11236', 'Brooklyn'),
    ('11434', 'Queens'),
    ('10034', 'Manhattan'),
    ('11101', 'Queens'),
    ('11377', 'Queens'),
    ('10016', 'Manhattan'),
    ('10001', 'Manhattan'),
    ('10466', 'Bronx'),
    ('10009', 'Manhattan'),
    ('11223', 'Brooklyn'),
    ('10003', 'Manhattan'),
    ('10023', 'Manhattan'),
    ('10314', 'Staten Island'),
    ('11205', 'Brooklyn'),
    ('11365', 'Queens'),
    ('10002', 'Manhattan'),
    ('11226', 'Brooklyn'),
    ('11372', 'Queens'),
    ('10128', 'Manhattan'),
    ('10031', 'Manhattan'),
    ('11420', 'Queens'),
    ('10453', 'Bronx'),
    ('11203', 'Brooklyn'),
    ('11220', 'Brooklyn'),
    ('10011', 'Manhattan'),
    ('10451', 'Bronx'),
    ('10458', 'Bronx'),
    ('10032', 'Manhattan'),
    ('11368', 'Queens'),
    ('10024', 'Manhattan'),
    ('11215', 'Brooklyn'),
    ('10456', 'Bronx'),
    ('11230', 'Brooklyn'),
    ('10033', 'Manhattan'),
    ('10029', 'Manhattan'),
    ('10040', 'Manhattan'),
    ('11235', 'Brooklyn'),
    ('11218', 'Brooklyn'),
    ('11413', 'Queens'),
    ('10036', 'Manhattan'),
    ('11212', 'Brooklyn'),
    ('11221', 'Brooklyn'),
    ('11209', 'Brooklyn'),
    ('10463', 'Bronx'),
    ('11378', 'Queens'),
    ('10469', 'Bronx'),
    ('10312', 'Staten Island'),
    ('10027', 'Manhattan'),
    ('11229', 'Brooklyn'),
    ('11412', 'Queens'),
    ('10022', 'Manhattan'),
    ('11206', 'Brooklyn'),
    ('11375', 'Queens'),
    ('11204', 'Brooklyn'),
    ('11419', 'Queens'),
    ('11379', 'Queens'),
    ('11214', 'Brooklyn'),
    ('11213', 'Brooklyn'),
    ('10473', 'Bronx'),
    ('10014', 'Manhattan'),
    ('11233', 'Brooklyn'),
    ('11435', 'Queens'),
    ('10028', 'Manhattan'),
    ('11219', 'Brooklyn'),
    ('11421', 'Queens'),
    ('11433', 'Queens'),
    ('10460', 'Bronx'),
    ('11354', 'Queens'),
    ('11216', 'Brooklyn'),
    ('11210', 'Brooklyn'),
    ('10461', 'Bronx'),
    ('11357', 'Queens'),
    ('11373', 'Queens'),
    ('10462', 'Bronx'),
    ('11237', 'Brooklyn'),
    ('11217', 'Brooklyn'),
    ('11238', 'Brooklyn'),
    ('10021', 'Manhattan'),
    ('10306', 'Staten Island'),
    ('10026', 'Manhattan'),
    ('11422', 'Queens'),
    ('11225', 'Brooklyn'),
    ('10065', 'Manhattan'),
    ('11105', 'Queens'),
    ('10472', 'Bronx'),
    ('10012', 'Manhattan'),
    ('11222', 'Brooklyn'),
    ('11432', 'Queens'),
    ('11417', 'Queens'),
    ('11361', 'Queens'),
    ('11374', 'Queens'),
    ('10465', 'Bronx'),
    ('10035', 'Manhattan'),
    ('10301', 'Staten Island'),
    ('11418', 'Queens'),
    ('10459', 'Bronx'),
    ('10013', 'Manhattan'),
    ('10010', 'Manhattan'),
    ('11364', 'Queens'),
    ('11356', 'Queens'),
    ('11355', 'Queens'),
    ('10017', 'Manhattan'),
    ('11436', 'Queens'),
    ('10455', 'Bronx'),
    ('11106', 'Queens'),
    ('10037', 'Manhattan'),
    ('11691', 'Queens'),
    ('11423', 'Queens'),
    ('11104', 'Queens'),
    ('11103', 'Queens'),
    ('10454', 'Bronx'),
    ('11429', 'Queens'),
    ('11249', 'Brooklyn'),
    ('11358', 'Queens'),
    ('11367', 'Queens'),
    ('11416', 'Queens'),
    ('10018', 'Manhattan'),
    ('11369', 'Queens'),
    ('11228', 'Brooklyn'),
    ('11232', 'Brooklyn'),
    ('11414', 'Queens'),
    ('11411', 'Queens'),
    ('10309', 'Staten Island'),
    ('11102', 'Queens'),
    ('10305', 'Staten Island'),
    ('10304', 'Staten Island'),
    ('11224', 'Brooklyn'),
    ('11231', 'Brooklyn'),
    ('10075', 'Manhattan'),
    ('10471', 'Bronx'),
    ('10030', 'Manhattan'),
    ('10039', 'Manhattan'),
    ('11694', 'Queens'),
    ('10007', 'Manhattan'),
    ('11428', 'Queens'),
    ('10470', 'Bronx'),
    ('10310', 'Staten Island'),
    ('10475', 'Bronx'),
    ('10308', 'Staten Island'),
    ('11427', 'Queens'),
    ('11370', 'Queens'),
    ('11426', 'Queens'),
    ('10303', 'Staten Island'),
    ('10038', 'Manhattan'),
    ('11366', 'Queens'),
    ('11693', 'Queens'),
    ('11415', 'Queens'),
    ('11362', 'Queens'),
    ('10302', 'Staten Island'),
    ('11004', 'Queens'),
    ('11692', 'Queens'),
    ('11360', 'Queens'),
    ('10307', 'Staten Island'),
    ('10474', 'Bronx'),
    ('11363', 'Queens'),
    ('10005', 'Manhattan'),
    ('10464', 'Bronx'),
    ('10004', 'Manhattan'),
    ('11109', 'Queens'),
    ('10006', 'Manhattan'),
    ('11239', 'Brooklyn'),
    ('10069', 'Manhattan'),
    ('11001', 'Queens'),
    ('10020', 'Manhattan'),
    ('11237', 'Brooklyn'),
    ('10168', 'Manhattan'),
    ('10463', 'Bronx'),
    ('10280', 'Manhattan'),
    ('11430', 'Queens'),
    ('10282', 'Manhattan'),
    ('11208', 'Brooklyn'),
    ('11040', 'Queens'),
    ('10278', 'Manhattan'),
    ('10165', 'Manhattan'),
    ('11697', 'Queens'),
    ('10172', 'Manhattan'),
    ('10000', 'Manhattan'),
    ('11005', 'Queens'),
    ('10119', 'Manhattan'),
    ('10281', 'Manhattan'),
    ('11359', 'Queens'),
    ('10169', 'Manhattan'),
    ('11421', 'Queens'),
    ('11385', 'Queens'),
    ('11371', 'Queens'),
    ('10115', 'Manhattan'),
    ('10271', 'Manhattan'),
    ('11695', 'Queens'),
    ('10105', 'Manhattan'),
    ('11385', 'Queens'),
    ('10301', 'Staten Island'),
    ('10044', 'Manhattan'),
    ('11368', 'Queens'),
    ('11416', 'Queens'),
    ('10048', 'Manhattan'),
    ('10118', 'Manhattan'),
    ('10120', 'Manhattan'),
    ('10021', 'Manhattan'),
    ('10314', 'Staten Island'),
    ('10304', 'Staten Island'),
    ('10103', 'Manhattan'),
    ('11429', 'Queens'),
    ('11426', 'Queens'),
    ('10045', 'Manhattan'),
    ('10106', 'Manhattan'),
    ('11416', 'Queens'),
    ('10121', 'Manhattan'),
    ('11360', 'Queens'),
    ('11422', 'Queens'),
    ('10110', 'Manhattan'),
    ('10022', 'Manhattan'),
    ('11421', 'Queens'),
    ('10002', 'Manhattan'),
    ('10031', 'Manhattan'),
    ('10030', 'Manhattan'),
    ('10029', 'Manhattan'),
    ('10027', 'Manhattan'),
    ('10025', 'Manhattan'),
    ('11211', 'Brooklyn'),
    ('11220', 'Brooklyn'),
    ('10013', 'Manhattan'),
    ('7114', 'Brooklyn'),
    ('11237', 'Brooklyn'),
    ('10306', 'Staten Island'),
    ('10307', 'Staten Island'),
    ('10305', 'Staten Island'),
    ('11414', 'Queens'),
    ('10173', 'Manhattan'),
    ('10170', 'Manhattan'),
    ('10154', 'Manhattan'),
    ('11422', 'Queens'),
    ('11423', 'Queens'),
    ('11414', 'Queens'),
    ('10454', 'Bronx'),
    ('10463', 'Bronx'),
    ('11205', 'Brooklyn'),
    ('11206', 'Brooklyn'),
    ('11207', 'Brooklyn');

-- Atualizar a tabela locations com base na tabela zip_city_mapping
UPDATE locations l
SET city = z.city
FROM zip_city_mapping z
WHERE l.incident_zip = z.zip_code;

SELECT DISTINCT city, incident_zip
FROM locations
WHERE city IS NOT NULL
ORDER BY city;


/* Outra alternativa seria colocar em todo city vazio a cidade New York pois não temos um padrão igual a normalização anterior
para futuras analises podemos utilizar latitude e longitude como outro dado de geolocalização assim como o bairro (borough)
utilizar o zip code fornecido pelo incident_zip seria pouco produtivo e não traria um dado completo, já que a base trata de dados do 311 de NY
o termo "New York" foi escolhido devido a baixa utilização dele, aproximadamente 43 vezes que foi localizado
-- Atualizar a tabela locations para preencher o campo city com 'New York' onde o city está vazio
UPDATE locations
SET city = 'New York'
WHERE city IS NULL OR city = '';*/

/* Código para apagar linhas simultaneamente de dados que foram considerados não corretos, como teste ou alguma outra situação
ex: city = "311 TEST SERVICE REQ"*/
BEGIN;
DELETE FROM locations
WHERE unique_key IN (15737924, 15737926);
DELETE FROM agencies
WHERE unique_key IN (15737924, 15737926);
DELETE FROM additional_info
WHERE unique_key IN (15737924, 15737926);
DELETE FROM complaints
WHERE unique_key IN (15737924, 15737926);
COMMIT;

/*Análise dos dados:*/

-- Consulta para calcular o número de incidentes por tipo
SELECT 
    complaint_type,
    COUNT(*) AS number_of_incidents
FROM 
    complaints
GROUP BY 
    complaint_type
ORDER BY 
    number_of_incidents DESC;

-- Consulta para calcular o número e % de incidentes por tipo
WITH incident_summary AS (
    SELECT 
        complaint_type,
        COUNT(*) AS number_of_incidents
    FROM 
        complaints
    GROUP BY 
        complaint_type
),
total_summary AS (
    SELECT 
        COUNT(*) AS total_incidents
    FROM 
        complaints
)
SELECT 
    i.complaint_type,
    i.number_of_incidents,
    ROUND((i.number_of_incidents * 100.0 / t.total_incidents),2) AS percentage_of_total
FROM 
    incident_summary i,
    total_summary t
ORDER BY 
    i.number_of_incidents DESC;

-- Univariada para número por tipo de incidente
WITH incident_counts AS (
    SELECT 
        complaint_type,
        COUNT(*) AS number_of_incidents
    FROM 
        complaints
    GROUP BY 
        complaint_type
)
SELECT 
    COUNT(number_of_incidents) AS number_values,
    COUNT(DISTINCT number_of_incidents) AS cardinality,
    MIN(number_of_incidents) AS minimum,
    MAX(number_of_incidents) AS maximum,
    MAX(number_of_incidents) - MIN(number_of_incidents) AS range,
    AVG(number_of_incidents) AS mean,
    STDDEV(number_of_incidents) AS standard_deviation
FROM 
    incident_counts;

-- Consulta para calcular o número de incidentes por tipo, bairro e cidade
SELECT 
    l.city AS city,
    l.borough AS borough,
    c.complaint_type AS complaint_type,
    COUNT(*) AS frequency
FROM 
    complaints c
JOIN 
    locations l ON c.unique_key = l.unique_key
GROUP BY 
    l.city, 
    l.borough,
    c.complaint_type
ORDER BY 
    frequency DESC;

-- Consulta para calcular o número e % de incidentes por tipo, bairro e cidade
WITH complaint_frequencies AS (
    SELECT 
        l.city AS city,
        l.borough AS borough,
        c.complaint_type AS complaint_type,
        COUNT(*) AS frequency
    FROM 
        complaints c
    JOIN 
        locations l ON c.unique_key = l.unique_key
    GROUP BY 
        l.city, 
        l.borough,
        c.complaint_type
),
total_complaints AS (
    SELECT 
        SUM(frequency) AS total
    FROM 
        complaint_frequencies
)
SELECT 
    cf.city,
    cf.borough,
    cf.complaint_type,
    cf.frequency,
    (cf.frequency::numeric / tc.total * 100)::numeric(5, 2) AS percentage
FROM 
    complaint_frequencies cf,
    total_complaints tc
ORDER BY 
    cf.frequency DESC;

-- Consulta para calcular o número e % de incidentes por bairro e cidade
WITH complaint_frequencies AS (
    SELECT 
        l.city AS city,
        l.borough AS borough,
        COUNT(*) AS frequency
    FROM 
        complaints c
    JOIN 
        locations l ON c.unique_key = l.unique_key
    GROUP BY 
        l.city, 
        l.borough
),
total_complaints AS (
    SELECT 
        SUM(frequency) AS total
    FROM 
        complaint_frequencies
)
SELECT 
    cf.city,
    cf.borough,
    (cf.frequency::numeric / tc.total * 100)::numeric(5, 2) AS percentage
FROM 
    complaint_frequencies cf,
    total_complaints tc
ORDER BY 
    percentage DESC;

-- Consulta para calcular o número de incidentes por descrição
SELECT 
    descriptor,
    COUNT(*) AS number_of_incidents
FROM 
    complaints
GROUP BY 
    descriptor
ORDER BY 
    number_of_incidents DESC;

-- Consulta para calcular o número e % de incidentes por descrição
WITH incident_summary AS (
    SELECT 
        descriptor,
        COUNT(*) AS number_of_incidents
    FROM 
        complaints
    GROUP BY 
        descriptor
),
total_summary AS (
    SELECT 
        COUNT(*) AS total_incidents
    FROM 
        complaints
)
SELECT 
    i.descriptor,
    i.number_of_incidents,
    ROUND((i.number_of_incidents * 100.0 / t.total_incidents),2) AS percentage_of_total
FROM 
    incident_summary i,
    total_summary t
ORDER BY 
    i.number_of_incidents DESC;

-- Univariada para número por descrição de incidente
WITH incident_counts AS (
    SELECT 
        descriptor,
        COUNT(*) AS number_of_incidents
    FROM 
        complaints
    GROUP BY 
        descriptor
)
SELECT 
    COUNT(number_of_incidents) AS number_values,
    COUNT(DISTINCT number_of_incidents) AS cardinality,
    MIN(number_of_incidents) AS minimum,
    MAX(number_of_incidents) AS maximum,
    MAX(number_of_incidents) - MIN(number_of_incidents) AS range,
    AVG(number_of_incidents) AS mean,
    STDDEV(number_of_incidents) AS standard_deviation
FROM 
    incident_counts;

-- Consulta para calcular o número de incidentes por descrição, bairro e cidade
SELECT 
    l.city AS city,
    l.borough AS borough,
    c.descriptor AS descriptor,
    COUNT(*) AS frequency
FROM 
    complaints c
JOIN 
    locations l ON c.unique_key = l.unique_key
GROUP BY 
    l.city, 
    l.borough,
    c.descriptor
ORDER BY 
    frequency DESC;

-- Cálculo da correlação entre zip_code e contagem de incidentes
WITH incident_counts AS (
    SELECT 
		l.incident_zip AS zip_code,
        COUNT(*) AS incident_count
    FROM 
        complaints c
    JOIN 
        locations l ON c.unique_key = l.unique_key
    WHERE 
        l.incident_zip ~ '^[0-9]+$'  -- Filtra apenas códigos postais numéricos
    GROUP BY 
    	l.incident_zip
)
SELECT 
    CORR(zip_code::numeric, incident_count) AS correlation
FROM 
    incident_counts;

-- Cálculo da correlação entre zip_code e contagem de incidentes com tipo da reclamação
WITH incident_counts AS (
    SELECT 
		c.complaint_type,
        l.incident_zip AS zip_code,
        COUNT(*) AS incident_count
    FROM 
        complaints c
    JOIN 
        locations l ON c.unique_key = l.unique_key
    WHERE 
        l.incident_zip ~ '^[0-9]+$'  -- Filtra apenas códigos postais numéricos
    GROUP BY 
    	complaint_type,
		l.incident_zip
)
SELECT 
    CORR(zip_code::numeric, incident_count) AS correlation
FROM 
    incident_counts;

-- Cálculo da correlação entre zip_code e contagem de incidentes com a descrição da reclamação
WITH incident_counts AS (
    SELECT 
		c.descriptor,
        l.incident_zip AS zip_code,
        COUNT(*) AS incident_count
    FROM 
        complaints c
    JOIN 
        locations l ON c.unique_key = l.unique_key
    WHERE 
        l.incident_zip ~ '^[0-9]+$'  -- Filtra apenas códigos postais numéricos
    GROUP BY 
    	descriptor,
		l.incident_zip
)
SELECT 
    CORR(zip_code::numeric, incident_count) AS correlation
FROM 
    incident_counts;

-- Cálculo da correlação entre zip_code e o tempo de atendimento da reclamação
WITH incident_durations AS (
    SELECT
        l.incident_zip,
        AVG(
            EXTRACT(EPOCH FROM (
                TO_TIMESTAMP(c.closed_date, 'MM/DD/YYYY HH:MI:SS AM') - 
                TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')
            )) / 3600  -- Converte a diferença de segundos para horas
        ) AS average_duration_hours
    FROM
        complaints c
    JOIN
        locations l ON c.unique_key = l.unique_key
    WHERE
        c.closed_date IS NOT NULL AND
		l.incident_zip ~ '^[0-9]+$'  -- Filtra apenas códigos postais numéricos
    GROUP BY
        l.incident_zip
)
SELECT 
    CORR(incident_zip::numeric, average_duration_hours) AS correlation
FROM 
    incident_durations;

-- Cálculo da correlação entre zip_code e o tempo de atendimento da reclamação com tipo da reclmação
WITH incident_durations AS (
    SELECT
		c.complaint_type,
        l.incident_zip,
        AVG(
            EXTRACT(EPOCH FROM (
                TO_TIMESTAMP(c.closed_date, 'MM/DD/YYYY HH:MI:SS AM') - 
                TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')
            )) / 3600  -- Converte a diferença de segundos para horas
        ) AS average_duration_hours
    FROM
        complaints c
    JOIN
        locations l ON c.unique_key = l.unique_key
    WHERE
        c.closed_date IS NOT NULL AND
		l.incident_zip ~ '^[0-9]+$'  -- Filtra apenas códigos postais numéricos
    GROUP BY
		c.complaint_type,
        l.incident_zip
)
SELECT 
    CORR(incident_zip::numeric, average_duration_hours) AS correlation
FROM 
    incident_durations;

-- Cálculo da correlação entre zip_code e o tempo de atendimento da reclamação com descrição da reclmação
WITH incident_durations AS (
    SELECT
		c.descriptor,
        l.incident_zip,
        AVG(
            EXTRACT(EPOCH FROM (
                TO_TIMESTAMP(c.closed_date, 'MM/DD/YYYY HH:MI:SS AM') - 
                TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')
            )) / 3600  -- Converte a diferença de segundos para horas
        ) AS average_duration_hours
    FROM
        complaints c
    JOIN
        locations l ON c.unique_key = l.unique_key
    WHERE
        c.closed_date IS NOT NULL AND
		l.incident_zip ~ '^[0-9]+$'  -- Filtra apenas códigos postais numéricos
    GROUP BY
		c.descriptor,
        l.incident_zip
)
SELECT 
    CORR(incident_zip::numeric, average_duration_hours) AS correlation
FROM 
    incident_durations;

-- Contagem de incidentes que levaram mais de 30 dias para serem finalizados levando em conta a cidade e reclamação
WITH incident_durations AS (
    SELECT
        l.city,
        c.complaint_type,
        EXTRACT(EPOCH FROM (
            TO_TIMESTAMP(c.closed_date, 'MM/DD/YYYY HH:MI:SS AM') - 
            TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')
        )) / 86400 AS duration_days  -- Converte a diferença de segundos para dias
    FROM
        complaints c
    JOIN
        locations l ON c.unique_key = l.unique_key
    WHERE
        c.closed_date IS NOT NULL
),
outlier_durations AS (
    SELECT
        city,
        complaint_type,
        duration_days
    FROM
        incident_durations
    WHERE
        duration_days > 30  -- Identifica registros fora do intervalo de 30 dias
)
SELECT
    city,
    complaint_type,
    COUNT(*) AS number_of_complaints
FROM
    outlier_durations
GROUP BY
    city,
    complaint_type
ORDER BY
    number_of_complaints DESC;

-- Contagem de incidentes que levaram mais de 30 dias para serem finalizados levando em conta a cidade
WITH incident_durations AS (
    SELECT
        l.city,
        EXTRACT(EPOCH FROM (
            TO_TIMESTAMP(c.closed_date, 'MM/DD/YYYY HH:MI:SS AM') - 
            TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')
        )) / 86400 AS duration_days  -- Converte a diferença de segundos para dias
    FROM
        complaints c
    JOIN
        locations l ON c.unique_key = l.unique_key
    WHERE
        c.closed_date IS NOT NULL
),
outlier_durations AS (
    SELECT
        city,
        duration_days
    FROM
        incident_durations
    WHERE
        duration_days > 30  -- Identifica registros fora do intervalo de 30 dias
)
SELECT
    city,
    COUNT(*) AS number_of_complaints
FROM
    outlier_durations
GROUP BY
    city
ORDER BY
    number_of_complaints DESC;

-- Contagem de incidentes que levaram mais de 30 dias para serem finalizados levando em conta a reclamação
WITH incident_durations AS (
    SELECT
        c.complaint_type,
        EXTRACT(EPOCH FROM (
            TO_TIMESTAMP(c.closed_date, 'MM/DD/YYYY HH:MI:SS AM') - 
            TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')
        )) / 86400 AS duration_days  -- Converte a diferença de segundos para dias
    FROM
        complaints c
    JOIN
        locations l ON c.unique_key = l.unique_key
    WHERE
        c.closed_date IS NOT NULL
),
outlier_durations AS (
    SELECT
        complaint_type,
        duration_days
    FROM
        incident_durations
    WHERE
        duration_days > 30  -- Identifica registros fora do intervalo de 30 dias
)
SELECT
    complaint_type,
    COUNT(*) AS number_of_complaints
FROM
    outlier_durations
GROUP BY
    complaint_type
ORDER BY
    number_of_complaints DESC;

-- Relação entre tipos de reclamação e resolução.
SELECT 
    c.complaint_type,
    c.resolution_description,
    COUNT(*) AS number_of_complaints
FROM 
    complaints c
GROUP BY 
    c.complaint_type,
    c.resolution_description
ORDER BY 
    number_of_complaints DESC;

/* Views e subconsultas: */

-- View que retorna todos os incidentes que estão em aberto.
CREATE VIEW open_incidents AS
SELECT
    c.unique_key,
    c.created_date,
    c.closed_date,
    c.complaint_type,
    c.descriptor,
    c.status,
    c.due_date,
    c.resolution_description,
    l.incident_zip,
    l.city,
    l.borough
FROM
    complaints c
JOIN
    locations l ON c.unique_key = l.unique_key
WHERE
    c.closed_date IS NULL;
SELECT * FROM open_incidents;

-- View que mostra a contagem de incidentes por bairro.
CREATE VIEW incident_count_by_borough AS
SELECT
    l.borough,
    COUNT(c.unique_key) AS incident_count
FROM
    complaints c
JOIN
    locations l ON c.unique_key = l.unique_key
GROUP BY
    l.borough
ORDER BY
    incident_count DESC;
SELECT * FROM incident_count_by_borough;

-- View que mostra a contagem de incidentes.
CREATE VIEW incident_count AS
SELECT
    c.complaint_type,
    COUNT(c.unique_key) AS incident_count
FROM
    complaints c
JOIN
    locations l ON c.unique_key = l.unique_key
GROUP BY
    c.complaint_type
ORDER BY
    incident_count DESC;
SELECT * FROM incident_count;

-- Os 10 incidentes com o maior atraso entre a data de criação e a data de fechamento.
WITH incident_durations AS (
    SELECT
        c.unique_key,
        l.city,
        c.complaint_type,
        ROUND(EXTRACT(EPOCH FROM (
            TO_TIMESTAMP(c.closed_date, 'MM/DD/YYYY HH:MI:SS AM') - 
            TO_TIMESTAMP(c.created_date, 'MM/DD/YYYY HH:MI:SS AM')
        )) / 86400) AS duration_days  -- Converte a diferença de segundos para dias e arredonda
    FROM
        complaints c
    JOIN
        locations l ON c.unique_key = l.unique_key
    WHERE
        c.closed_date IS NOT NULL
)
SELECT
    unique_key,
    city,
    complaint_type,
    duration_days
FROM
    incident_durations
ORDER BY
    duration_days DESC
LIMIT 10;

-- Endereços onde ocorreram mais de 5 reclamações diferentes.
CREATE VIEW frequent_complaint_addresses AS
WITH complaint_count_per_address AS (
    SELECT
        l.incident_address,
        l.city,
        l.borough,
        COUNT(DISTINCT c.complaint_type) AS complaint_types_count
    FROM
        complaints c
    JOIN
        locations l ON c.unique_key = l.unique_key
    GROUP BY
        l.incident_address, l.city, l.borough
    HAVING
        COUNT(DISTINCT c.complaint_type) > 5
)
SELECT
    incident_address,
    city,
    borough,
    complaint_types_count
FROM
    complaint_count_per_address
ORDER BY
    complaint_types_count DESC;
SELECT * FROM frequent_complaint_addresses;


SELECT * FROM additional_info;

DROP TABLE temp_city_zip_counts;


/*Tentativa de criar um mapa com a latitude e longitude */
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;



/* TEM VARIAS LINHAS COM DADOS ESTRANHOS E ATÉ TESTES*/





