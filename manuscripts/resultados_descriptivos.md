# Resultados — Análisis descriptivo

*(Borrador para el manuscrito. Las tablas completas están en
`output/descriptivos/descriptivos_manuscrito.xlsx` y en
`output/descriptivos/tablas_descriptivas.md`.)*

## Muestra

La muestra analítica quedó conformada por 93.383 estudiantes de 8.° grado
anidados en 3.749 escuelas de 24 sistemas educativos de Europa y América
Latina que participaron en ICCS 2016. Se excluyeron 1.220 casos (1,3 %) sin
información válida en el índice nacional de nivel socioeconómico (NISB). El
tamaño promedio de conglomerado fue de 24,9 estudiantes por escuela, con
variación importante entre países (desde 17,3 en Estonia hasta 78,0 en Malta),
lo que otorga potencia suficiente para estimar efectos aleatorios a nivel de
escuela en todos los sistemas.

El desempeño medio en conocimiento cívico fue de 521,0 puntos (DE = 100,6),
con una amplitud de casi 200 puntos entre el sistema con menor y mayor
promedio (República Dominicana, M = 383,3; Suecia, M = 582,9). El NISB, por
construcción estandarizado dentro de cada país, presentó medias cercanas a
cero y desviaciones estándar cercanas a uno en todos los sistemas
(Tabla 1), lo que hace comparables los coeficientes del NSE entre países.

## Estructura anidada de los datos

El modelo nulo por país (M0) indica que una proporción sustantiva de la
varianza en conocimiento cívico se ubica entre escuelas: la CCI mediana fue de
0,22, con un rango amplio (0,064 en Noruega a 0,596 en Países Bajos). Los
sistemas con mayor segregación escolar del logro cívico son, en general, los
que combinan selección temprana o alta estratificación (NLD = 0,593;
BGR = 0,581; HKG = 0,473; PER = 0,464). Esta magnitud justifica el uso de
modelos multinivel y define el espacio de varianza sobre el cual pueden operar
los moderadores escolares.

## Variables moderadoras: descomposición within/between

La Tabla 2 presenta los descriptivos y la descomposición de varianza de las
nueve variables de clima escolar. Todas las escalas WLE del cuestionario de
estudiantes se distribuyen aproximadamente en la métrica internacional
(M ≈ 50, DE ≈ 10), con asimetría y curtosis dentro de los rangos aceptables
para estimación por máxima verosimilitud (|asimetría| ≤ 0,24;
|curtosis| ≤ 1,74).

El dato central para la estrategia analítica es la magnitud de la CCI de cada
moderador, ya que la interacción de nivel cruzado se estima sobre el
componente **between** (el promedio de escuela). Las escalas de percepción
individual concentran su varianza en el nivel del estudiante: la CCI mediana
fluctúa entre 0,040 (valoración de la participación) y 0,099 (relaciones
estudiante-docente). En términos de dispersión, la desviación estándar between
de estos moderadores es de apenas 3,1 a 3,9 puntos frente a una desviación
within de 9,0 a 9,4 puntos. Es decir, las escuelas difieren poco entre sí en
clima escolar percibido, y esa varianza limitada acota la potencia disponible
para detectar moderación de nivel cruzado — un punto que se retoma en la
discusión de los resultados nulos.

Los dos ítems de participación cívica en el aula (`ic3g13a` e `ic3g13b`)
muestran el patrón opuesto: su varianza es casi enteramente entre escuelas
(CCI mediana = 0,95), consistente con que se trata de indicadores de práctica
escolar y no de percepción individual.

## Correlaciones

La Tabla 3 presenta la matriz de correlaciones descompuesta por nivel: bajo la
diagonal, correlaciones within-school (variables centradas en la media de la
escuela); sobre la diagonal, correlaciones between-school (medias de escuela
centradas en la media del país).

A nivel individual, el NSE se asocia con el conocimiento cívico en la magnitud
esperada (r = 0,23), mientras que los moderadores muestran asociaciones
positivas pero modestas con el resultado (r = 0,09 a 0,19), con la excepción
del abuso escolar, negativa (r = −0,08), y la interacción social en el aula,
prácticamente nula (r = −0,02).

A nivel de escuela las asociaciones son marcadamente más fuertes: la
correlación entre el NSE promedio y el conocimiento cívico promedio de la
escuela alcanza r = 0,68, lo que expresa la composición socioeconómica como el
principal ordenador del logro cívico agregado. Los climas escolares también se
diferencian más nítidamente entre escuelas (apertura a la discusión, r = 0,37;
valoración de la participación, r = 0,33; abuso, r = −0,23). Los dos ítems de
participación cívica en el aula no se asocian con el conocimiento cívico en
ningún nivel (|r| ≤ 0,01).

Las correlaciones entre moderadores a nivel de escuela son de moderadas a
altas (hasta r = 0,68 entre relaciones estudiante-docente e interacción social
en el aula), razón por la cual cada moderador se modela por separado en lugar
de incluirlos simultáneamente.

---

## Notas pendientes (no van en el manuscrito)

1. **Ponderadores muestrales.** Los descriptivos y los modelos están sin
   ponderar. ICCS es una muestra compleja con probabilidades desiguales de
   selección; un revisor va a preguntar. Corresponde al menos reportar los
   descriptivos con `totwgts` (o `senwgt`) y discutirlo en limitaciones.
2. **`ic3g13a` / `ic3g13b` no son constantes dentro de la escuela.** El script
   de modelos asume que sí lo son y omite el componente CWC. En los datos, 801
   de 3.270 escuelas evaluables (24,5 %) tienen más de un valor en `ic3g13a`, y
   687 de 3.569 (19,2 %) en `ic3g13b`; la CCI es 0,95, no 1,00. Habría que
   decidir si la variable es de escuela (y agregarla formalmente) o de
   estudiante (y conservar el CWC). La comprobación completa, con cinco pruebas
   y un contraste contra una variable de nivel 2 por construcción, está en la
   sección 3 del HTML (`output/mitigacion_analisis.html`).
3. **Valores perdidos.** `ic3g13a` tiene 20,9 % de casos perdidos, muy por
   encima del resto (≤ 1,5 %). Conviene reportarlo y justificar la eliminación
   por lista, o considerar imputación.
4. **Un solo valor plausible.** Se usa `pv1civ` en lugar de los cinco PV, lo
   que subestima el error estándar. Es una limitación reportable.
