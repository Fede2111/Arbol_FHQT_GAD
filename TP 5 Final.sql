CREATE EXTENSION fuzzystrmatch;

CREATE TABLE elementos (
    id serial PRIMARY KEY,
    cadena text
);

CREATE TABLE pivotes (
    id_pivote serial PRIMARY KEY,
    pivote text 
);

CREATE TABLE nodos (
    id_nodo serial PRIMARY KEY,
    distancia integer,
	id_pivote integer REFERENCES pivotes(id_pivote),
    nodo_padre integer REFERENCES nodos(id_nodo)
);

CREATE TABLE nodos_hoja (
	id_nodo_hoja integer REFERENCES nodos (id_nodo),
	id_elemento integer REFERENCES elementos (id),
    PRIMARY KEY (id_nodo_hoja, id_elemento)
);

CREATE TABLE log (
    id_log serial PRIMARY KEY,
    cadena text,
    fecha timestamp DEFAULT current_timestamp
);


insert into nodos (distancia, id_pivote, nodo_padre) values ( null,null, null);

--Mas adelante se puede escribir una funcion que se llame igual distancia, pero si los se determinara cual usar dependiendo de los parametros de entrada 
CREATE OR REPLACE FUNCTION distancia(p1 text,p2 text)
RETURNS integer AS $$
DECLARE
    distancia_result integer;
BEGIN
    distancia_result := levenshtein(p1, p2);
	INSERT INTO log (cadena,fecha) VALUES (p2,current_timestamp);
    RETURN distancia_result;
END;
$$ LANGUAGE plpgsql;

-- Crear el stored procedure insterar nodo para que cree el arbol y me devuelve el id del nodo hoja 
CREATE OR REPLACE FUNCTION insertar_nodo(cadena TEXT)
RETURNS integer 
AS $$
DECLARE
    dist INTEGER;
    pivo TEXT;
	new_nodo integer;
BEGIN
    -- Iniciar el bucle FOR de i 1 a 10
	new_nodo:= 1;
    FOR i IN 1..(SELECT count(*) FROM pivotes) LOOP  
        -- Se asigna a la variable el siguiente pivote a controlar 
        pivo := (SELECT p.pivote FROM pivotes p WHERE id_pivote = i);
        
        -- Calculamos la función distancia entre la cadena que se quiere insertar y el pivote
        dist := distancia(pivo, cadena);

        IF EXISTS (SELECT 1 FROM nodos n WHERE n.nodo_padre = new_nodo AND n.distancia = dist) THEN
            -- Si existe un nodo que tiene el mismo padre y distancia, lo utilizamos
            new_nodo := (SELECT n.id_nodo FROM nodos n WHERE n.nodo_padre = new_nodo AND n.distancia = dist);
        ELSE
            -- Caso contrario, creamos un nuevo nodo y luego lo utilizamos 
            INSERT INTO nodos (distancia,id_pivote, nodo_padre) VALUES (dist,i, new_nodo) RETURNING id_nodo INTO new_nodo;
        END IF;
    END LOOP;
	RETURN new_nodo;
END;
$$ LANGUAGE plpgsql;


-- Crear la función que se ejecutará despúes de la inserción insertando un elemento en la tabla nodos_hoja
CREATE OR REPLACE FUNCTION after_insert_elementos()
RETURNS TRIGGER AS $$
DECLARE
	new_nodo integer;
BEGIN
	SELECT insertar_nodo(new.cadena) INTO new_nodo;	
	INSERT INTO nodos_hoja (id_nodo_hoja, id_elemento) VALUES (new_nodo,new.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger
CREATE TRIGGER after_insert_elementos_trigger
AFTER INSERT ON elementos
FOR EACH ROW
EXECUTE FUNCTION after_insert_elementos();



-- Crear una función que se ejecutará despues de la eliminación de un elemento 
CREATE OR REPLACE FUNCTION after_delete_elementos()
RETURNS TRIGGER AS $$
BEGIN
	DELETE FROM nodos_hoja WHERE id_elemento = old.id;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

-- Crear el trigger que se ejecutará despues de la eliminación AFTER
CREATE TRIGGER elementos_after_delete
AFTER DELETE ON elementos
FOR EACH ROW
EXECUTE FUNCTION after_delete_elementos();



-- Crear una función que se ejecutará antes de la actualización de una tupla AFTER
CREATE OR REPLACE FUNCTION after_update_elementos() 
RETURNS TRIGGER AS $$
DECLARE
    i integer;
    dist integer;
    new_nodo integer;
	pivo text;
BEGIN
	SELECT insertar_nodo (new.cadena) INTO new_nodo;	
 	--update sobre la tabla nodos modificando la hoja a la que apunta 
    UPDATE nodos_hoja SET id_nodo_hoja = new_nodo where id_elemento = old.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Crear el trigger que se ejecutará antes de la actualización
CREATE TRIGGER elementos_after_update
after UPDATE OF cadena ON elementos
FOR EACH ROW
EXECUTE FUNCTION after_update_elementos();

INSERT INTO pivotes (pivote) VALUES
    ('Ana'),
    ('Juan'),
    ('Maria'),
    ('Carlos'),
    ('Laura'),
    ('Diego'),
    ('Sofia'),
    ('Manuel'),
    ('Claudia'),
    ('Alejandro');

insert into elementos (cadena) values 
    ('Ana');
	
update elementos set cadena = 'Anita' where cadena = 'Ana';

select * from elementos;
select * from nodos;
select * from pivotes;
select * from nodos_hoja;

insert into elementos (cadena) values 
    ('Maria'),
    ('Carlos'),
    ('Laura'),
    ('Diego'),
    ('Sofia'),
    ('Manuel'),
    ('Claudia'),
    ('Alejandro'),
    ('Juan');
	
INSERT INTO elementos (cadena) VALUES 
    ('Ángel'),
    ('Carla'),
    ('Hugo'),
    ('Valentina'),
    ('Emilio'),
    ('Sandra'),
    ('Martín'),
    ('Isabella'),
    ('Raúl'),
    ('Camila'),
    ('Roberto'),
    ('Daniela'),
    ('Guillermo'),
    ('Melissa'),
    ('Gonzalo'),
    ('Verónica'),
    ('Luis'),
    ('Patricia'),
    ('Sebastián'),
    ('Aurora'),
    ('Ricardo'),
    ('Fabiola'),
    ('Mateo'),
    ('Lucía'),
    ('Javier'),
    ('Alejandra'),
    ('Nicolás'),
    ('Adriana'),
    ('Pedro'),
    ('Laura');
	
INSERT INTO elementos (cadena) VALUES 
    ('Roberto'),
    ('Carolina'),
    ('Hector'),
    ('Victoria'),
    ('Daniel'),
    ('Rosa'),
    ('Lorenzo'),
    ('Alicia'),
    ('Ivan'),
    ('Lourdes'),
    ('Alberto'),
    ('Olga'),
    ('Felix'),
    ('Miriam'),
    ('Julio'),
    ('Susana'),
    ('Oscar'),
    ('Gloria'),
    ('Mauricio'),
    ('Eva'),
    ('Arturo'),
    ('Adriana'),
    ('Gustavo'),
    ('Marina'),
    ('Rodrigo'),
    ('Beatriz'),
    ('Pedro'),
    ('Monica'),
    ('Raul'),
    ('Pilar');

INSERT INTO elementos (cadena) VALUES 
    ('Luis'),
    ('Guadalupe'),
    ('Miguel'),
    ('Isabel'),
    ('Javier'),
    ('Elena'),
    ('Gabriel'),
    ('Carmen'),
    ('Ricardo'),
    ('Patricia'),
    ('Francisco'),
    ('Sara'),
    ('Jorge'),
    ('Lautaro'),
    ('Alejandro'),
    ('Natalia'),
    ('Carlota'),
    ('Raquel'),
    ('Antonio'),
    ('Monica'),
    ('Dylan'),
    ('Marian'),
    ('Manuel'),
    ('Eva'),
    ('Pedro'),
    ('Beatriz'),
    ('Fernando'),
    ('Lorena'),
    ('Juan'),
    ('Silvia');
	
CREATE OR REPLACE FUNCTION consulta2(caden text)
RETURNS TABLE(distancia integer, pivote text, id_pivote integer) AS $$
DECLARE
    i integer;
BEGIN
    FOR i IN 1..(SELECT COUNT(*) FROM pivotes) LOOP
        SELECT p.pivote, p.id_pivote into pivote, id_pivote FROM pivotes p WHERE p.id_pivote = i;
        distancia := distancia(pivote, caden);
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

	
CREATE OR REPLACE FUNCTION consulta(caden text, simil integer)
RETURNS TABLE(id_elemento integer, cad text, ejecuciones integer) AS $$
DECLARE
	i integer;
BEGIN
	i:=1;
    CREATE TEMPORARY TABLE temporal AS
        SELECT * FROM consulta2(caden);
		
	RETURN QUERY
    WITH RECURSIVE lista_nodos AS (    
        SELECT n.id_nodo, n.distancia,n.id_pivote, n.nodo_padre, i 
        FROM nodos n inner join temporal t on t.id_pivote = n.id_pivote
        WHERE 	n.distancia BETWEEN (t.distancia - simil) AND (t.distancia + simil) 
				and n.nodo_padre = i 
				and n.id_pivote = i        
	UNION
        SELECT n.id_nodo, n.distancia, n.id_pivote, n.nodo_padre, ln.i + 1
        FROM nodos n inner join temporal t on t.id_pivote = n.id_pivote, lista_nodos ln
        WHERE
              	n.distancia BETWEEN  (t.distancia - simil) AND (t.distancia + simil) 
				AND	n.nodo_padre = ln.id_nodo 			
				and n.id_pivote = ln.i + 1
    )
	SELECT e.id, e.cadena, contar_distancia(caden)
	from lista_nodos ln, temporal t, nodos_hoja nh, elementos e
	where 
		ln.id_nodo = nh.id_nodo_hoja 
		and ln.distancia BETWEEN  (t.distancia - simil) AND (t.distancia + simil)
		and e.id = nh.id_elemento
		and distancia (e.cadena, caden) <= simil
	group by e.id, e.cadena;					
	DROP TABLE temporal;

END;
$$ LANGUAGE plpgsql;

--Consulta que podria terminar siendo una siendo una funcion dentro de la propia consulta 
--el intervalo puede cambiar de la siguiente manera: interval '1 day 2 hours 30 minutes 15 seconds' dependiendo lo que establezca 

CREATE OR REPLACE FUNCTION contar_distancia(caden text)
RETURNS integer AS $$
DECLARE
	contador integer;
BEGIN
		contador := (SELECT count(*) AS contador
		FROM log
		WHERE cadena = caden
		AND fecha BETWEEN current_timestamp - interval '1 seconds'
		AND current_timestamp + interval '1 seconds'
		GROUP BY cadena);

	RETURN contador;
END;
$$ LANGUAGE plpgsql;


select * from consulta ('Vanina',3); 
select * from consulta ('Mary', 2);
select * from consulta ('Andrea', 2);
select * from consulta ('Tamara', 3);
select * from consulta ('Ismael', 4);
select * from consulta ('Hector', 3);
select * from consulta ('Roberto', 4);
select * from consulta ('Gabriela', 2);
select * from consulta ('Daiana', 3);
select * from consulta ('Dino', 2);

