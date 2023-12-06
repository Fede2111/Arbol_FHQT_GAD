import math
#import Funciones
import Levenshtein
import TP5_3_Seleccion_incremental as tp_5
'''
a= ['Maria', 'Carlos', 'Laura', 'Diego', 'Sofia', 'Manuel', 'Claudia', 'Alejandro', 'Juan', 'Ángel',
           'Carla','Hugo','Valentina','Emilio','Sandra','Martín','Isabella','Raúl' ,'Camila','Roberto','Daniela',
           'Guillermo','Melissa','Gonzalo','Verónica' ,'Luis','Patricia','Sebastián','Aurora','Ricardo','Fabiola',
           'Mateo','Lucía' ,'Javier','Alejandra','Nicolás','Adriana','Pedro','Laura','Roberto','Carolina','Hector',
           'Victoria','Daniel','Rosa','Lorenzo','Alicia','Ivan','Lourdes','Alberto','Olga','Felix','Miriam',
           'Julio','Susana','Oscar','Gloria','Mauricio','Eva','Arturo','Adriana','Gustavo','Marina','Rodrigo','Beatriz' ,
           'Pedro','Monica','Raul','Pilar','Luis','Guadalupe','Miguel','Isabel' ,'Javier','Elena','Gabriel','Carmen','Ricardo',
           'Patricia','Francisco' ,'Sara','Jorge','Lautaro','Alejandrino','Natalia','Carlota','Raquel','Antonio','Monica','Dylan',
           'Marian','Manuel','Eva','Pedro','Beatriz' ,'Fernando','Lorena','Juan','Silvia']
'''

a  = tp_5.obtener_datos("TP5_1")
print(a)
pares=[]

for i in range(0, len(a)):
    for j in range(i+1, len(a)):
        pares.append([a[i],a[j]])


print('')
print('Pares ordenados: '+str(pares))
print('')
print('Cantidad de pares:' + str(len(pares)))
print('')
distancias=[]

for i in range(0,len(pares)):
    distancias.append(math.fabs(Levenshtein.distance(pares[i][0], pares[i][1])))

#print('Distancias numéricas: '+str(distancias))
print('')

cat_de_distancia=[]
cant_de_distancias=[]

for i in range(0,len(distancias)):
    if distancias[i] not in cat_de_distancia:
        cat_de_distancia.append(distancias[i])

cat_de_distancia.sort()

for i in range(0, len(cat_de_distancia)):
    cantidad= 0
    for j in range(0,len(distancias)):
        if cat_de_distancia[i] == distancias[j]:
            cantidad=cantidad+1
    cant_de_distancias.append(cantidad)

print('categorías de distancia: '+str(cat_de_distancia))
print('')

print('cantidades de distancia: '+str(cant_de_distancias))
print('')

histograma= []

for i in range(0, len(cat_de_distancia)):
    histograma.append([cat_de_distancia[i],cant_de_distancias[i]])


print('')
print('Histograma de distancias:')
print('')

for i in range(0, len(histograma)):
    print('cantidad de pares con distancia '+str(cat_de_distancia[i])+': '+str(cant_de_distancias[i]))
    print('')