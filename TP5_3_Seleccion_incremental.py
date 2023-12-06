import psycopg2
import Levenshtein
import random
import numpy as np
import math
import io
import requests
from bs4 import BeautifulSoup
import psycopg2

def obtener_elementos_de_tabla(puntero, columna, tabla):
    puntero.execute(f"SELECT {columna} FROM {tabla}")
    elementos = puntero.fetchall()
    return(elementos)

def obtener_datos(db_name):
    conn = psycopg2.connect(
        host="localhost",
        port=5432,
        database=db_name,
        user="postgres",
        password = "1"
    )
    cur = conn.cursor()
    results = obtener_elementos_de_tabla(cur, 'cadena', 'elementos')
    for i in range(0, len(results)):
        results[i] = str(results[i]).strip("(),'") 
    cur.close()
    return results


# Generar la lista de pares de elementos aleatorios tomando como entrada la 
# cantidad de pares que queremos, y el nombre de la base de datos de donde obtener los resultados
def TuplePick(cantidad_pares,datos):
    tuple_list = []
    lista = datos
    for _ in range(cantidad_pares):
        pair = random.sample(lista, 2)
        for par in pair:
          lista.remove(par)
        tuple_list.append(pair)
    return tuple_list

#maximo de todos los pivotes para este par
def distancia_max (grupo_pivotes,par):
    maximo = 0
    for i in range(0,len(grupo_pivotes)):
        siguiente = math.fabs(Levenshtein.distance(grupo_pivotes[i],par[0]) - Levenshtein.distance(grupo_pivotes[i],par[1]))
        if siguiente > maximo:
            maximo = siguiente
    return maximo
#ciclar sobre los pivotes


def distancia_maxima_promedio(grupo_pivotes,pares):
    sp = 0
    for i in range (0, len(pares)):
        sp = sp + (distancia_max(grupo_pivotes,pares[i]))
    return (sp/len(grupo_pivotes))

#ciclar sobre los pares 
#Distancia del grupo de pivotes al los pares, por lo que hay que recorrer los pares 

#for grupos de pivotes, for pares para un grupo, for pivotes corerspondiente al grupo 
def seleccion_incremental_pivotes(cantidad_pivotes,tam_muestra,cant_pares,datos):
    pivotes_finales = []
    pivotes_provisorios = []
    par = TuplePick(cant_pares,datos)
    lista = datos
    for i in range(0,cantidad_pivotes):
        p = []
        pivotes_provisorios = []
        pivote = random.sample(lista,tam_muestra)
        print(pivote)
        for i in range(0,len(pivote)):
            lista.remove(pivote[i])
        for j in range(0,len(pivote)):
            if pivotes_finales != []:
                for k in range(0,len(pivotes_finales)):
                    pivotes_provisorios.append(pivotes_finales[k])
            pivotes_provisorios.append(pivote[j])
            print(pivotes_provisorios)
            p.append(distancia_maxima_promedio(pivotes_provisorios,par))
            pivotes_provisorios = []
            print(p)
        pivotes_finales.append(pivote[p.index(max(p))])
        print(pivotes_finales)
    return pivotes_finales

#insertarmos en una base de datos de pgadmin un vector de cadenas que seran los pivotes
def insertar_pivotes (pivotes,db_name):
    conn = psycopg2.connect(
    host="localhost",
    database=db_name,
    user="postgres",
    password="1"
    )
    cur = conn.cursor()
    for i in range(0,len(pivotes)):
        cur.execute("INSERT INTO pivotes (pivote) VALUES (%s);", (pivotes[i],))
    conn.commit()
    conn.close()
    return print("Pivotes insertados")


def punto1tp5_3(db_name,cantidad_pares,cantidad_pivotes,muestra_size):
    results = obtener_datos(db_name)
    pivotes = seleccion_incremental_pivotes(cantidad_pivotes,muestra_size, cantidad_pares, results)
    print(pivotes)
    return pivotes


def get_nombres():
  # Obtener el contenido de la página web
  url = "https://www.diezminutos.es/maternidad/embarazo/g29016764/nombres-originales-nino-bebe/"
  r = requests.get(url)
  soup = BeautifulSoup(r.text, "html.parser")
  # Encontrar todas las secciones <ol>
  secciones = soup.find_all("ol")
  lista = []
  # Iterar sobre las secciones
  for seccion in secciones:
      # Encontrar todas las secciones <li>
      nombres = seccion.find_all("strong")
      # Iterar sobre los nombres
      for nombre in nombres:
          lista.append(((str(nombre).split("<strong>")[1]).split(":")[0]).split("<")[0])
  Lista_final = []
  for i in range(0,len(lista)):
      if len(lista[i]) >= 2:
          Lista_final.append(lista[i])
      else:
        print(lista[i])    
  return Lista_final


def insertar_cadenas(Lista_final,db_name):
  conn = psycopg2.connect(
    host="localhost",
    database=db_name,
    user="postgres",
    password="1"
  )
  # Creamos un cursor
  cur = conn.cursor()
  # Insertamos los valores en la tabla
  for i in range(0,len(Lista_final)):
    cur.execute("INSERT INTO elementos (cadena) VALUES (%s);", (Lista_final[i],))
  # Commiteamos las transacciones
  conn.commit()
  # Cerramos la conexión
  conn.close()
  print("Cadenas insertadas")
  # truncate o alter table 
  # TRUNCATE TABLE pivotes RESTART IDENTITY;

def write_names ():
  resultados = get_nombres()
  archivo = io.open("nombres.txt", "w",encoding="utf-8")
  db = obtener_datos("TP5_1")

  for result in resultados:
    archivo.write(result + "\n")
  for d in db:
    archivo.write(d + "\n")
  archivo.close()

def read_names():
    #Abre el archivo 
    archivo = io.open("nombres.txt", "r", encoding="utf-8")
    datos = []
    for linea in archivo:
        #Cada linea del archivo la agrega a la lista, quitando en el proceso la cadena "\n"
        datos.append(linea.split("\n")[0])
    archivo.close()
    return datos

#insertar_cadenas(read_names(),"TP5_1")


#insertar_pivotes(random.sample(obtener_datos("TP5_2"),10),"TP5_2")

#insertar_pivotes(punto1tp5_3("TP5_2",130,10,50),"TP5_3")

#punto1tp5_3("TP5_2",130,10,50)
#tomar 10% de pares y muestra chica 
#results = obtener_datos("TP5_2")

#Este es para insertar pivotes de manera random en TP5_2
#insertar_pivotes(random.sample(results,10),"TP5_2")    
