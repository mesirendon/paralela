# Calcular el número Pi con hilos (pthread) en C

## Compilar
`gcc pi-hilos.c -pthread -o pi-hilos`

## Ejecutar
`./pi-hilos`

## Ejemplo de salida
<pre>
Calculo de Pi con hilos
hilos: 4, tiempo: 46.49 seg
parcialPi[0] = 3.14159265308807666983
parcialPi[1] = 0.00000000024999999998
parcialPi[2] = 0.00000000000000000000
parcialPi[3] = 0.00000000004166666667
Pi = 3.14159265337974336063
</pre>

## Tiempos de ejecución
<pre>
hilos: 1, tiempo: 10.62 seg
hilos: 2, tiempo: 21.03 seg
hilos: 4, tiempo: 46.03 seg
hilos: 8, tiempo: 92.04 seg
hilos: 16, tiempo: 183.98 seg
</pre>

