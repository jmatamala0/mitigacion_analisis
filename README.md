# Análisis de Mitigación — Modelos Multinivel (ICCS 2016)

Proyecto de investigación cuantitativa en R que analiza si características del
entorno escolar **moderan la asociación entre nivel socioeconómico (NSE) y
conocimiento cívico**. Utiliza datos de estudiantes y directores de ICCS 2016
de 24 sistemas educativos de Europa, América Latina y Asia.

**Autor:** Jorge Matamala. **Documentación revisada:** 1 de octubre de 2026.

## Pregunta de investigación

¿En qué medida las características del entorno escolar se asocian con una
menor brecha de conocimiento cívico según el nivel socioeconómico del estudiante?
Los modelos estiman asociaciones e interacciones; por sí solos no identifican
efectos causales del entorno escolar.

## Datos y muestra

| Archivo | Descripción |
|---------|-------------|
| `data/Data/isg<pais>c3.sas7bdat` | Cuestionario de estudiante: escalas, cinco valores plausibles y variables del diseño muestral |
| `data/Data/icg<pais>c3.sas7bdat` | Cuestionario de director: indicadores sobre organización de la educación cívica |
| `data/Documents/Codebook/ICCS2016MS_Codebook.xlsx` | Codebook oficial |
| `data/ICCS2016_IDB_User_Guide.pdf` | Manual de usuario del IDB |
| `data/mit_data.Rdata` | Base construida por `rscripts/00_construir_base.R`; contiene el objeto `mit_data` |

La unión estudiante–director es **m:1 sobre `IDCNTRY` + `IDSCHOOL`**.
`IDSCHOOL` solo identifica una escuela de forma única dentro de cada sistema.

| Etapa | Estudiantes | Escuelas |
|-------|------------:|---------:|
| Base completa | 94.603 | 3.752 |
| Casos con `pv1civ` y `s_nisb` válidos | 93.383 | 3.749 |
| Muestra de trabajo: además, al menos 5 estudiantes válidos por escuela | 93.221 | 3.696 |

Se excluyen primero 1.220 estudiantes por datos faltantes y luego 162 estudiantes
en 53 escuelas por tamaño. Los 24 sistemas permanecen en la muestra de trabajo.
M2, M3 y M4 pueden utilizar menos observaciones por datos faltantes en cada moderador.

Los códigos presentes son `BFL`, `BGR`, `CHL`, `COL`, `DNK`, `DNW`, `DOM`,
`EST`, `FIN`, `HKG`, `HRV`, `ITA`, `KOR`, `LTU`, `LVA`, `MEX`, `MLT`,
`NLD`, `NOR`, `PER`, `RUS`, `SVN`, `SWE` y `TWN`. Se habla de sistemas
educativos porque no todos los códigos corresponden a países distintos.

> No usar `data/ICCS_School_Teachers_Students_Europe_LA.dta` como entrada.
> La revisión previa documentó errores en sus bloques de director y docentes.
> La base actual se reconstruye desde los archivos SAS originales; el script
> verifica la unicidad de la clave escolar y la constancia de los dos ítems de
> director dentro de cada escuela.

## Variables

La dependiente es `pv1civ` (primer valor plausible de conocimiento cívico) y el
predictor principal es `s_nisb` (índice nacional de nivel socioeconómico).
Los modelos se estiman por `country`, con estudiantes agrupados por `idschool`.

| Moderador | Descripción | Nivel de medición |
|-----------|-------------|------------------|
| `ic3g13a` | Educación cívica como asignatura separada; 1 = Sí, 0 = No | Escuela |
| `s_civlrn` | Aprendizaje cívico en la escuela | Estudiante |
| `s_opdisc` | Apertura a la discusión en el aula | Estudiante |
| `s_schpart` | Participación en la escuela | Estudiante |
| `s_valparts` | Valoración de la participación | Estudiante |
| `s_abuse` | Abuso físico y verbal en la escuela | Estudiante |
| `s_stutrel` | Relaciones estudiante-docente | Estudiante |
| `s_intact` | Interacción social en el aula | Estudiante |

Para las siete escalas individuales se calcula un promedio escolar (`var_m`)
y la desviación de cada estudiante respecto de ese promedio (`var_cwc`).
El código calcula estos promedios sobre la base completa, antes de aplicar los
filtros de la muestra. El ítem de director solo aporta un componente
entre escuelas y se incluye sin `var_cwc` en M2/M3; para él no se estima M4.
El R Markdown lo recodifica de la codificación original de la IEA
(1 = Sí, 2 = No) a 1 = Sí, 0 = No, de modo que un coeficiente positivo se
refiere a las escuelas que responden Sí. La base `mit_data.Rdata` conserva
la codificación original.

## Estrategia analítica implementada

1. Estimar **M0, M1a y M1b una sola vez por sistema** mediante máxima
   verosimilitud (`lmer`, `REML = FALSE`).
2. Comparar M1a con M1b mediante una prueba de razón de verosimilitudes (LRT).
   El resultado se informa, pero **no filtra** los sistemas: una interacción
   puede existir aunque la varianza de la pendiente no sea significativa.
3. En todos los sistemas, estimar **M2 y M3 por separado para cada moderador**
   y **M4 para las siete escalas individuales**. Si la estimación produce un
   error, se devuelve `NULL`.

| Modelo | Especificación para moderadores individuales | Propósito |
|--------|---------------------------------------------|-----------|
| M0 | `pv1civ ~ 1 + (1 \| idschool)` | Varianza entre escuelas y CCI del modelo nulo |
| M1a | `pv1civ ~ s_nisb_cwc + s_nisb_m + (1 \| idschool)` | Asociación del NSE con conocimiento cívico dentro y entre escuelas |
| M1b | `pv1civ ~ s_nisb_cwc + s_nisb_m + (s_nisb_cwc \| idschool)` | Variación entre escuelas de la pendiente del NSE dentro de la escuela |
| M2 | `pv1civ ~ s_nisb_cwc + s_nisb_m + var_cwc + var_m + (1 \| idschool)` | Asociaciones individuales y escolares del moderador |
| M3 | `pv1civ ~ s_nisb_cwc + s_nisb_m + var_cwc + var_m + s_nisb_cwc:var_m + (s_nisb_cwc \| idschool)` | Interacción entre NSE y moderador escolar |
| M4 | `pv1civ ~ s_nisb_cwc + s_nisb_m + var_cwc + var_m + s_nisb_cwc:var_cwc + (1 \| idschool)` | Interacción entre NSE y moderador individual |

El NSE se separa en `s_nisb_cwc` (desviación del estudiante respecto de su
escuela) y `s_nisb_m` (promedio escolar), calculados sobre la muestra
analítica. `s_nisb_m` y los `var_m` se centran en la media de las escuelas de
cada país. Solo M3 incluye la pendiente aleatoria `(s_nisb_cwc | idschool)`,
porque su interacción es entre niveles y omitirla tiende a subestimar los
errores estándar; M2 y M4 usan intercepto aleatorio. Por eso la comparación
M2→M3 cambia también la parte aleatoria. Donde la pendiente casi no varía, el
ajuste de M3 puede ser singular; la columna `Singular` de las salidas lo
registra.

`ic3g13a` no fue administrado en BFL, BGR y LTU. No hay estimaciones M2/M3
disponibles para ese ítem en esos sistemas. El ítem `ic3g13b` (educación
cívica a cargo de docentes de ciencias sociales o humanidades) se excluyó del
análisis por su escasa variabilidad.

**Muestras de estimación:** M0/M1a/M1b comparten la muestra de trabajo de cada
sistema. M2/M3/M4 de un mismo moderador comparten sus casos completos, pero pueden
diferir de los modelos base y de otros moderadores. No se debe asumir que los
AIC/BIC de todos los modelos son directamente comparables sin comprobar las
observaciones utilizadas. El umbral de cinco estudiantes tampoco se vuelve a
aplicar después de las exclusiones por datos faltantes de cada moderador.

La clasificación automática de M3 y M4 usa el signo y el valor p de la
interacción: «Mitigación» si es negativa y significativa, «Aceleración» si es
positiva y significativa, y «Reproducción» en los demás casos. `Tipo` usa el
valor p sin ajustar; por ahora no se aplica corrección por comparaciones
múltiples. Son **etiquetas operativas**: la interpretación debe considerar que
`s_abuse` mide un clima negativo. Una interacción no significativa no
demuestra reproducción ni ausencia de moderación.

## Organización y ejecución

```text
mitigacion_analisis/
├── data/                          # Fuentes originales y base analítica
├── rscripts/
│   ├── 00_construir_base.R        # Construcción y controles de la base
│   └── mitigacion_analisis.Rmd    # Preparación, descriptivos, modelos y exportación
├── manuscripts/
│   └── resultados_descriptivos.md
├── output/
│   ├── mitigacion_analisis.html
│   ├── descriptivos/             # Tablas para el manuscrito
│   └── modelos_multinivel/       # Coeficientes, diagnósticos y clasificación
└── mitigacion_analisis.Rproj
```

Abrir el proyecto en RStudio. Se requieren R, `pacman`, `rmarkdown`, `knitr`
y Pandoc (incluido en RStudio). Los scripts cargan sus demás dependencias
con `pacman::p_load`, que puede instalarlas si faltan. Entre las principales
están `haven`, `dplyr`, `purrr`, `psych`, `lme4`, `lmerTest` y `writexl`.
No hay un archivo de bloqueo de versiones de paquetes.

Desde la raíz del proyecto, en una sesión de R:

```r
# Solo si es necesario instalar las herramientas de ejecución:
install.packages(c("pacman", "rmarkdown", "knitr"))

# Opcional si ya se dispone de mit_data.Rdata; requiere los SAS originales:
source("rscripts/00_construir_base.R")

# Ejecuta el análisis y sobrescribe las salidas correspondientes:
rmarkdown::render(
  "rscripts/mitigacion_analisis.Rmd",
  output_format = "html_document",
  output_dir = "output"
)
```

También se puede usar **Knit** en el R Markdown. Sus rutas `../data` y
`../output` asumen que los chunks se ejecutan desde `rscripts/`, como ocurre
al renderizar el archivo. La salida PDF opcional requiere además LaTeX.
Los datos SAS originales y `output/` están excluidos de Git; una copia del
repositorio no necesariamente los incluye.

## Salidas y estado de los resultados

- `output/descriptivos/descriptivos_manuscrito.xlsx`: muestra, exclusiones,
  descriptivos, frecuencias del ítem de director y correlaciones.
- `output/modelos_multinivel/modelos_<variable>.xlsx`: ocho libros, cada uno
  con una hoja por sistema. Contienen los modelos base, M2, M3 y M4 (este
  último salvo para el ítem de director), con la columna `Singular`.
- `output/modelos_multinivel/diagnosticos_modelos.xlsx`: CCI de M0 y LRT por sistema.
- `output/modelos_multinivel/clasificacion_modelos.xlsx`: interacciones de M3
  y M4 con `p_valor`, `Tipo`, `Singular` y `Pasa_LRT`, más una hoja `Resumen` con los conteos.
- `output/mitigacion_analisis.html`: informe con código, tablas y resultados.

Con la especificación actual (NSE separado en `s_nisb_cwc` y `s_nisb_m`, sin
`ic3g13b` y sin corrección por comparaciones múltiples) se clasifican 189
interacciones de M3 (24 sistemas × 8 moderadores, menos los 3 sistemas que no
administraron `ic3g13a`) y 168 de M4 (24 × 7). Las cifras de resultados deben
tomarse del informe renderizado más reciente.

`output/descriptivos/tablas_descriptivas.md` es una salida histórica con
cifras y etiquetas anteriores: **no usarla como tabla vigente**. El R Markdown
actual no genera ese archivo. Para el manuscrito se usaron las tablas del HTML
guardado y se comprobaron los tamaños de muestra y algunos descriptivos contra
`mit_data.Rdata`.


## Fuente

International Civic and Citizenship Education Study 2016 (ICCS 2016), IEA.
La base incluye estudiantes de 8.º grado y cuestionarios de sus directores.
