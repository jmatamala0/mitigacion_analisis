# Análisis de Mitigación — Modelos Multinivel (ICCS 2016)

Proyecto de análisis cuantitativo que investiga si variables del clima escolar **moderan** (mitigan) el efecto del nivel socioeconómico (NSE) sobre el conocimiento cívico de los estudiantes, usando datos del estudio ICCS 2016 para países de Europa y América Latina.

**Autor:** Jorge Matamala

---

## Pregunta de investigación

¿En qué medida las características del entorno escolar reducen la brecha de conocimiento cívico asociada al nivel socioeconómico del estudiante?

---

## Datos

| Archivo | Descripción |
|---------|-------------|
| `data/Data/isg<pais>c3.sas7bdat` | Cuestionario de estudiante ICCS 2016 (escalas `S_*`, valores plausibles, ponderadores) — 24 países |
| `data/Data/icg<pais>c3.sas7bdat` | Cuestionario de director ICCS 2016 (ítems `IC3G*`) — 24 países |
| `data/Documents/Codebook/ICCS2016MS_Codebook.xlsx` | Codebook oficial |
| `data/ICCS2016_IDB_User_Guide.pdf` | Manual de usuario del IDB |
| `data/mit_data.Rdata` | Base analítica, generada por `rscripts/00_construir_base.R` |

La base analítica une estudiante y director con un merge **m:1 sobre
`IDCNTRY` + `IDSCHOOL`** (`IDSCHOOL` solo es único dentro de cada país).
Resultado: 94.603 estudiantes, 3.752 escuelas, 24 países.

> No usar `ICCS_School_Teachers_Students_Europe_LA.dta` (versión anterior): sus
> bloques de director (`IC3G*`) y de docentes (`IT3G*`) están corruptos — solo
> 268 de 3.529 escuelas tenían el cuestionario de director correcto. El nivel
> estudiante de ese archivo sí es correcto y coincide bit a bit con esta base.

### Variables clave

| Variable | Descripción |
|----------|-------------|
| `pv1civ` | Conocimiento cívico — variable dependiente (plausible value 1) |
| `s_nisb` | Nivel socioeconómico del estudiante (predictor principal, nivel 1) |
| `country` | País |
| `idschool` | ID de escuela |

### Variables moderadoras (9)

| Variable | Descripción |
|----------|-------------|
| `ic3g13a` | Ed. cívica se enseña como asignatura separada (director; 1 = Sí, 2 = No) — **nivel escuela** |
| `ic3g13b` | Ed. cívica a cargo de docentes de cs. sociales/humanas (director; 1 = Sí, 2 = No) — **nivel escuela** |
| `s_civlrn` | Aprendizaje cívico |
| `s_opdisc` | Apertura a la discusión en el aula |
| `s_schpart` | Participación en la escuela |
| `s_valparts` | Valoración de la participación |
| `s_abuse` | Abuso escolar (clima negativo) |
| `s_stutrel` | Relaciones estudiante-docente |
| `s_intact` | Interacción en el aula |

---

## Estructura del proyecto

```
mitigacion_analisis/
├── data/                          # Datos de entrada (IDB ICCS 2016)
├── rscripts/
│   ├── 00_construir_base.R       # Merge estudiante + director -> mit_data.Rdata
│   └── mitigacion_analisis.Rmd   # Script principal de análisis
├── output/
│   └── modelos_multinivel/        # Resultados en Excel (generados al correr)
└── mitigacion_analisis.Rproj      # Proyecto RStudio
```

---

## Estrategia analítica

Para cada combinación **país × variable moderadora** (9 variables × N países) se estiman 5 modelos multinivel anidados:

| Modelo | Especificación | Propósito |
|--------|---------------|-----------|
| **M0** | `pv1civ ~ 1 + (1 \| idschool)` | ICC: varianza entre escuelas |
| **M1a** | `pv1civ ~ s_nisb + (1 \| idschool)` | Efecto del NSE (intercepto aleatorio) |
| **M1b** | `pv1civ ~ s_nisb + (s_nisb \| idschool)` | Pendiente aleatoria del NSE |
| **M2** | `pv1civ ~ s_nisb + var_cwc + var_m + (s_nisb \| idschool)` | Efecto del contexto escolar |
| **M3** | `pv1civ ~ s_nisb + var_cwc + var_m + s_nisb:var_m + (s_nisb \| idschool)` | **Interacción NSE × contexto escolar** |

**Centrado within-cluster (CWC):** cada variable moderadora se descompone en:
- `var_cwc`: valor individual centrado en la media del grupo (efecto within-school, nivel 1)
- `var_m`: promedio de escuela (efecto between-school, nivel 2)

---

## Fuente de datos

International Civic and Citizenship Education Study 2016 (ICCS 2016) — IEA.
Muestra: estudiantes de 8.° grado en países de Europa y América Latina.
