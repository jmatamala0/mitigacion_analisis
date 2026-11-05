# Resultados — Análisis descriptivo

*Borrador revisado el 1 de octubre de 2026. Cifras correspondientes a la muestra
filtrada del análisis actual. Las tablas de referencia son las del informe
`output/mitigacion_analisis.html`; el análisis también exporta
`output/descriptivos/descriptivos_manuscrito.xlsx`. La tabla Markdown histórica
`output/descriptivos/tablas_descriptivas.md` está desactualizada y no debe usarse
para este borrador. Los resultados son descriptivos sin ponderación.*

## Muestra

La base completa contiene 94.603 estudiantes en 3.752 escuelas de 24 sistemas
educativos de Europa, América Latina y Asia que participaron en ICCS 2016.
Al exigir información válida en conocimiento cívico (`pv1civ`) y nivel
socioeconómico (`s_nisb`), se excluyeron 1.220 estudiantes y quedaron 93.383
en 3.749 escuelas. Posteriormente se excluyeron 53 escuelas con menos de cinco
estudiantes válidos, que reunían 162 casos. La muestra de trabajo final quedó
conformada por **93.221 estudiantes en 3.696 escuelas**, conservando los 24
sistemas educativos (Tablas 1 y 1b).

El tamaño promedio de escuela en esta muestra fue de 25,2 estudiantes. Los
promedios por sistema variaron entre 17,4 en Finlandia y 78,0 en Malta. Estos
tamaños describen la muestra disponible; no constituyen por sí solos una
evaluación de potencia para detectar interacciones.

El desempeño medio en conocimiento cívico fue de 521,0 puntos (DE = 100,6).
Los promedios por sistema oscilaron entre 383,3 en República Dominicana y
587,7 en Dinamarca. El índice nacional de nivel socioeconómico presentó una
media global de 0,04 y una desviación estándar de 1,00, con medias próximas
a cero dentro de cada sistema (Tabla 1).

## Estructura anidada de los datos

La CCI del conocimiento cívico calculada en la Tabla 2 mediante modelos nulos
por sistema y estimación REML tiene una mediana de 0,223 y un rango de 0,064
a 0,596. Esto indica diferencias importantes en la proporción de varianza
que se ubica entre escuelas.

Los modelos M0 de la sección de diagnósticos se estiman por máxima
verosimilitud, por lo que sus CCI difieren ligeramente de las descriptivas.
En esos modelos, las CCI son 0,594 en Países Bajos, 0,583 en Bulgaria, 0,479
en Hong Kong y 0,462 en Perú, frente a 0,064 en Noruega. Estas diferencias
describen la concentración del desempeño entre escuelas sin identificar sus
causas institucionales.

## Variables moderadoras: componentes individuales y escolares

Se consideran siete escalas del cuestionario de estudiantes y un ítem del
cuestionario de director sobre la organización de la educación cívica.
Las siete escalas individuales presentan medias aproximadamente próximas a
50 y desviaciones estándar próximas a 10. Sus valores absolutos de asimetría
no superan 0,24 y los de curtosis no superan 1,74 (Tabla 2).

En las escalas individuales, la CCI mediana por sistema varía entre 0,040
para valoración de la participación y 0,099 para relaciones estudiante-docente.
Las desviaciones estándar del componente entre escuelas, descontando las
diferencias entre sistemas, varían aproximadamente entre 3,0 y 3,8 puntos;
las del componente dentro de las escuelas, entre 9,0 y 9,4. La mayor parte de
la variación se encuentra, por tanto, entre estudiantes de una misma escuela.
Los modelos de moderación utilizan el promedio escolar de cada escala en la
interacción con el NSE.

El ítem de director es constante dentro de cada escuela y no tiene un
componente individual variable. Entre las escuelas de la muestra final con
información válida, 1.603 de 2.984 (53,7 %) imparten educación cívica como
asignatura separada (`ic3g13a`; Tabla 2b). En los análisis, el ítem se
codifica 1 = Sí y 0 = No.

## Correlaciones

La Tabla 3 distingue correlaciones dentro de las escuelas, calculadas con
variables centradas en la media escolar, y entre escuelas, calculadas con
promedios escolares centrados en la media de cada sistema. Se utilizan los
casos disponibles para cada par de variables.

A nivel individual, la correlación entre NSE y conocimiento cívico es de
0,23. Las correlaciones del conocimiento cívico con aprendizaje cívico,
apertura a la discusión, participación, valoración de la participación y
relaciones estudiante-docente son positivas y oscilan entre 0,09 y 0,19.
La correlación con abuso escolar es negativa (−0,08), mientras que la
correlación con interacción social en el aula es cercana a cero (−0,02).

Entre escuelas, la correlación entre NSE promedio y conocimiento cívico
promedio alcanza 0,69. Las correlaciones del desempeño con apertura a la
discusión, valoración de la participación y abuso escolar son 0,38, 0,34 y
−0,25, respectivamente. La correlación con el ítem de organización de la
educación cívica es cercana a cero (0,03). Este ítem no tiene correlaciones
dentro de las escuelas porque no varía en ese nivel.

Las correlaciones entre moderadores a nivel escolar alcanzan 0,68 entre
relaciones estudiante-docente e interacción social en el aula. La estrategia
implementada analiza cada moderador por separado; sus coeficientes no
representan asociaciones ajustadas simultáneamente por los otros moderadores.

## Notas de revisión metodológica y trazabilidad (no van en el manuscrito)

1. **Muestra de cada modelo.** Los 93.221 casos constituyen la muestra de
   partida. Los modelos base comparten la muestra de su sistema; M2/M3 pueden
   perder casos adicionales por datos faltantes del moderador. El código no
   vuelve a aplicar el mínimo de cinco estudiantes tras esas pérdidas. Antes
   de comparar AIC/BIC entre modelos base y moderadores, comprobar y, cuando
   corresponda, igualar sus muestras efectivas.
2. **Diseño muestral y valores plausibles.** Los resultados actuales no
   incorporan ponderadores ni replicación del diseño muestral y utilizan solo
   `pv1civ`. La base contiene `totwgts`, `jkzones`, `jkreps` y los cinco valores
   plausibles. Falta incorporarlos antes de cerrar la inferencia estadística.
3. **Datos faltantes.** En la muestra final, `ic3g13a` tiene 16,1 % de datos
   faltantes a nivel de estudiante; las siete escalas individuales tienen
   entre 0,8 % y 1,5 %. La documentación del proyecto identifica no
   administración de `ic3g13a` en BFL, BGR y LTU. Estos casos deben
   distinguirse de la falta de respuesta. La base analítica reducida no basta
   por sí sola para atribuir toda ausencia de este ítem a la falta de
   respuesta del cuestionario completo de director. El ítem `ic3g13b` se
   excluyó del análisis por su escasa variabilidad.
4. **Selección e interpretación de las interacciones.** En la corrida
   anterior, con `s_nisb` sin separar, BFL, MEX, PER y RUS pasaban el LRT de
   pendiente aleatoria; el LRT no filtra. El Rmd ya separa el NSE en
   `s_nisb_cwc` y `s_nisb_m`: M3 usa `(s_nisb_cwc | idschool)` y M2/M4 usan
   `(1 | idschool)`. Falta reestimar y actualizar estas cifras. Se clasifican 189
   interacciones de M3 y 168 de M4, con el p sin ajustar; por ahora no se
   aplica corrección por comparaciones múltiples. El ítem de director se
   recodificó 1 = Sí, 0 = No. Las
   categorías automáticas requieren revisión según la dirección de cada
   escala, en particular `s_abuse`. «Reproducción» es una etiqueta del
   programa para resultados no significativos, no una conclusión sustantiva
   demostrada.
5. **Corrección de la base.** La revisión previa documentó errores en los
   bloques de director y docentes del antiguo archivo
   `ICCS_School_Teachers_Students_Europe_LA.dta`. El script
   `rscripts/00_construir_base.R` reconstruye la base desde los SAS originales
   mediante `IDCNTRY` + `IDSCHOOL` y verifica que los ítems de director sean
   constantes por escuela. Las tablas de la base antigua no son referencias
   válidas para esos ítems.
6. **Procedencia de las cifras.** Esta revisión utilizó las tablas del HTML
   guardado; se comprobaron directamente en `mit_data.Rdata` los tamaños de
   muestra, la media y DE de conocimiento cívico, las frecuencias de los ítems
   de director y las correlaciones entre escuelas con conocimiento cívico.
   No se reestimaron los modelos. Tras modificar el análisis, se deben regenerar
   las salidas y sincronizar este borrador. La tabla Markdown histórica no se
   regenera con el R Markdown actual.
