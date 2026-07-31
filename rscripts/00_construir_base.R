## ---------------------------------------------------------------------------
## Construcción de la base analítica desde los archivos originales del IDB
## ICCS 2016 (formato SAS).
##
## Reemplaza al archivo ICCS_School_Teachers_Students_Europe_LA.dta, en el que
## los bloques de director (IC3G*) y de docentes (IT3G*) estaban corruptos:
## solo 268 de 3.529 escuelas (7,6%) tenían el cuestionario de director que les
## correspondía; el resto coincidía con el valor real a nivel de azar. El nivel
## estudiante de ese archivo sí era correcto y coincide con esta base.
##
## Estructura de los archivos originales:
##   isg<pais>c3.sas7bdat -> cuestionario de estudiante: escalas S_*, PV*CIV,
##                           ponderadores. Un registro por estudiante.
##   icg<pais>c3.sas7bdat -> cuestionario de director: ítems IC3G*.
##                           Un registro por escuela.
##
## El merge correcto es m:1 sobre IDCNTRY + IDSCHOOL: cada estudiante recibe el
## único registro de su escuela. IDSCHOOL solo es único dentro de país, por eso
## IDCNTRY va en la llave.
##
## Salida: data/mit_data.Rdata (objeto mit_data), compatible con
##         rscripts/mitigacion_analisis.Rmd
## ---------------------------------------------------------------------------

pacman::p_load(haven, dplyr, purrr, stringr)

dir_data <- "data/Data"

## Variables a extraer de cada archivo -----------------------------------------
vars_est <- c("IDCNTRY", "COUNTRY", "IDSTUD", "IDSCHOOL", "IDCLASS",
              "TOTWGTS", "JKZONES", "JKREPS",
              "S_NISB",
              "S_CIVLRN", "S_OPDISC", "S_SCHPART", "S_VALPARTS",
              "S_ABUSE", "S_STUTREL", "S_INTACT",
              "PV1CIV", "PV2CIV", "PV3CIV", "PV4CIV", "PV5CIV")

vars_esc <- c("IDCNTRY", "IDSCHOOL", "IC3G13A", "IC3G13B")

## Códigos de país presentes en la carpeta -------------------------------------
paises <- list.files(dir_data, pattern = "^icg.*c3\\.sas7bdat$") %>%
  str_sub(4, 6)

message("Países detectados: ", length(paises))

## Lectura y merge por país ----------------------------------------------------
armar_pais <- function(cnt) {

  est <- read_sas(file.path(dir_data, paste0("isg", cnt, "c3.sas7bdat")),
                  col_select = all_of(vars_est))

  esc <- read_sas(file.path(dir_data, paste0("icg", cnt, "c3.sas7bdat")),
                  col_select = all_of(vars_esc))

  ## El archivo de escuelas debe tener una fila por escuela; si no, el merge
  ## dejaría de ser m:1 y volvería a duplicar estudiantes.
  stopifnot(!any(duplicated(esc[, c("IDCNTRY", "IDSCHOOL")])))

  est %>% left_join(esc, by = c("IDCNTRY", "IDSCHOOL"))
}

mit_data <- map_dfr(paises, armar_pais) %>%
  rename_all(tolower)

## Verificación: un solo valor por escuela en las variables de nivel 2 ---------
chequeo <- mit_data %>%
  group_by(country, idschool) %>%
  summarise(across(c(ic3g13a, ic3g13b),
                   ~ n_distinct(.x[!is.na(.x)])),
            .groups = "drop")

stopifnot(all(chequeo$ic3g13a <= 1), all(chequeo$ic3g13b <= 1))

message("OK: ic3g13a e ic3g13b tienen a lo más un valor por escuela")
message("Estudiantes: ", nrow(mit_data),
        " | Escuelas: ", nrow(chequeo),
        " | Países: ", n_distinct(mit_data$country))

save(mit_data, file = "data/mit_data.Rdata")
message("Guardado: data/mit_data.Rdata")
