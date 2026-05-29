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
| `data/ICCS_School_Teachers_Students_Europe_LA.dta` | Base de datos ICCS 2016 (Europa y América Latina) — formato Stata |
| `data/ICCS2016_IDB_User_Guide.pdf` | Manual de usuario del IDB (codebook oficial) |
| `data/mit_data.Rdata` | Subconjunto de variables generado por el script (se crea al correr el análisis) |

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
| `ic3g13a` / `ic3g13b` | Ítems de participación cívica en el aula |
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
├── data/                          # Datos de entrada
├── rscripts/
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
