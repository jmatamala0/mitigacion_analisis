## -------------------------------------------------------------------
## Figuras de la sección de Resultados (español e inglés)
##
## Lee las salidas de mitigacion_analisis.Rmd, incluidas las predicciones de
## predicciones_interacciones.xlsx (no reestima modelos) y guarda
## PNG (300 dpi) y PDF en output/figuras/es/ y output/figuras/en/.
## Ejecutar desde la raíz del proyecto:
##   Rscript rscripts/01_figuras_resultados.R
##
##   Figura 1: efecto del NSE dentro y entre escuelas, por sistema (M1a)
##   Figura 2: mapa de calor de las interacciones M3 (agregado) y M4 (percibido)
##   Figura 3: mosaico de la brecha por NSE donde hay mitigación (M3 y M4)
##   Figura S1: ídem, donde hay aceleración (material suplementario)
## -------------------------------------------------------------------

suppressPackageStartupMessages({
  library(readxl); library(dplyr); library(tidyr); library(purrr)
  library(ggplot2); library(patchwork)
})

dir_mod <- "output/modelos_multinivel"
dir_des <- "output/descriptivos"
dir_fig <- "output/figuras"
idiomas <- c("es", "en")
for (i in idiomas) if (!dir.exists(file.path(dir_fig, i))) dir.create(file.path(dir_fig, i), recursive = TRUE)

## Traducción: devuelve el texto según el idioma activo del bucle
tr <- function(es, en) if (idioma == "es") es else en

## ic3g13b se excluyó del análisis; si el archivo antiguo existe, se ignora
vars_mod <- c("ic3g13a", "s_civlrn", "s_schpart", "s_valparts",
              "s_opdisc", "s_stutrel", "s_intact", "s_abuse")

## Dimensión de cada variable (código) y etiquetas por idioma
dim_cod <- c(ic3g13a = "ens", s_civlrn = "ens", s_schpart = "par", s_valparts = "par",
             s_opdisc = "cli", s_stutrel = "cli", s_intact = "cli", s_abuse = "cli")
dim_lbl <- list(
  es = c(ens = "Enseñanza", par = "Participación", cli = "Clima y convivencia"),
  en = c(ens = "Teaching", par = "Participation", cli = "Climate and school life"))
etq_lbl <- list(
  es = c("Asignatura separada", "Aprendizaje cívico",
         "Participación en la escuela", "Valoración de la participación",
         "Apertura a la discusión", "Relación estudiante-docente",
         "Interacción social en el aula", "Abuso físico y verbal"),
  en = c("Separate subject", "Civic learning",
         "School participation", "Value of participation",
         "Open classroom discussion", "Student–teacher relations",
         "Classroom social interaction", "Physical and verbal abuse"))

## Tabla de dimensiones en el idioma activo. `reclasificar` mueve variables
## a otra dimensión (p. ej., en la Figura 2, apertura a la discusión va en
## Participación); el resto de las figuras usa la clasificación original.
dimensiones_idioma <- function(reclasificar = character(0)) {
  cod <- dim_cod
  cod[names(reclasificar)] <- reclasificar
  niv <- dim_lbl[[idioma]]
  tibble(Variable  = vars_mod,
         Dimension = factor(unname(niv[cod[vars_mod]]), levels = unname(niv)),
         Etiqueta  = factor(etq_lbl[[idioma]], levels = rev(etq_lbl[[idioma]])))
}

## Paleta (validada: azul/naranja para dos series; divergente azul-gris-rojo)
col_within  <- "#2a78d6"
col_between <- "#eb6834"
col_ink     <- "#0b0b0b"
col_muted   <- "#898781"
col_grid    <- "#e1e0d9"
div_cols    <- c("#184f95", "#5598e7", "#f0efec", "#ec7b7a", "#a72f2e")

tema <- theme_minimal(base_size = 9) +
  theme(panel.grid.minor   = element_blank(),
        panel.grid.major   = element_line(colour = col_grid, linewidth = 0.25),
        axis.text          = element_text(colour = "#52514e"),
        axis.title         = element_text(colour = "#52514e"),
        plot.title         = element_text(colour = col_ink, face = "bold", size = 10),
        plot.subtitle      = element_text(colour = "#52514e"),
        plot.caption       = element_text(colour = col_muted, hjust = 0, size = 7),
        plot.caption.position = "plot",
        plot.title.position   = "plot",
        legend.position    = "top",
        legend.justification = "left",
        strip.text         = element_text(colour = col_ink, face = "bold", hjust = 0))

guardar <- function(p, nombre, ancho, alto) {
  ruta <- file.path(dir_fig, idioma, nombre)
  ggsave(paste0(ruta, ".png"), p, width = ancho, height = alto, dpi = 300, bg = "white")
  ggsave(paste0(ruta, ".pdf"), p, width = ancho, height = alto, bg = "white",
         device = cairo_pdf)
}

leer_modelos <- function(var) {
  f <- file.path(dir_mod, paste0("modelos_", var, ".xlsx"))
  map_dfr(excel_sheets(f), ~ read_excel(f, sheet = .x))
}

## -------------------------------------------------------------------
## Datos (se leen una vez)
## -------------------------------------------------------------------

modelos <- map_dfr(vars_mod, leer_modelos)
diag    <- read_excel(file.path(dir_mod, "diagnosticos_modelos.xlsx"))

## DE de los moderadores para estandarizar las interacciones:
##   M3 (promedio escolar): DE entre escuelas; M4 (desviación): DE dentro
de_mod <- read_excel(file.path(dir_des, "descriptivos_manuscrito.xlsx"),
                     sheet = "T2 Descriptivos") %>%
  transmute(Variable, DE_within = as.numeric(`DE within`),
            DE_between = as.numeric(`DE between`)) %>%
  filter(Variable %in% vars_mod)

## ic3g13a es dicotómica: DE de una proporción de escuelas con "Sí"
p_sí <- read_excel(file.path(dir_des, "descriptivos_manuscrito.xlsx"),
                   sheet = "T2b Dicotomicas") %>%
  filter(País == "Total") %>%
  pull(`ic3g13a: % Sí`) %>%
  sub(" %", "", .) %>% as.numeric() / 100
de_mod <- bind_rows(de_mod,
                    tibble(Variable = "ic3g13a", DE_within = NA_real_,
                           DE_between = sqrt(p_sí * (1 - p_sí))))

## Orden común de los sistemas: de menor a mayor CCI
orden_paises <- diag %>% arrange(ICC_M0) %>% pull(Pais)

clasif <- read_excel(file.path(dir_mod, "clasificacion_modelos.xlsx"),
                     sheet = "Clasificacion") %>%
  filter(Variable %in% vars_mod) %>%
  select(Modelo, Pais, Variable, Tipo, Beta_interaccion, SE, p_valor, Singular)

f_pred <- file.path(dir_mod, "predicciones_interacciones.xlsx")
pred   <- read_excel(f_pred, sheet = "Predicciones")
pend   <- read_excel(f_pred, sheet = "Pendientes") %>% filter(Variable %in% vars_mod)

## Escala simétrica fija de la Figura 2 (±5 abarca todos los valores; se satura en el borde)
lim <- 5

## Niveles del moderador en las predicciones (valores de los datos)
niveles <- c("-1 DE", "+1 DE")
col_niv <- c("-1 DE" = "#86b6ef", "+1 DE" = "#184f95")

fmt1 <- function(x) sub("-", "−", formatC(x, format = "f", digits = 1,
                                          decimal.mark = tr(",", ".")))

## -------------------------------------------------------------------
## Funciones de las figuras 2, 3 y S1 (leen `idioma` al llamarse)
## -------------------------------------------------------------------

panel_calor <- function(d_all, modelo, titulo, eje_x = TRUE) {
  d <- filter(d_all, Modelo == modelo) %>% droplevels()
  ggplot(d, aes(x = Pais, y = Etiqueta, fill = Beta_std)) +
    geom_tile(colour = "white", linewidth = 0.6) +
    geom_text(data = filter(d, is.na(Beta_std)), label = "–",
              colour = col_muted, size = 2.5) +
    geom_point(data = filter(d, sig), aes(shape = tr("p < 0,05", "p < .05")),
               size = 1.4, colour = col_ink) +
    facet_grid(rows = vars(Dimension), scales = "free_y", space = "free_y",
               labeller = labeller(Dimension = label_wrap_gen(12))) +
    scale_fill_gradientn(colours = div_cols, limits = c(-lim, lim),
                         oob = scales::squish, na.value = "white",
                         breaks = seq(-4, 4, 2),
                         name = tr("Cambio en la pendiente del NSE por 1 DE del moderador",
                                   "Change in the SES slope per 1 SD of the moderator")) +
    scale_shape_manual(values = 16, name = NULL) +
    labs(subtitle = titulo, x = NULL, y = NULL) +
    tema +
    theme(panel.grid.major = element_blank(),
          plot.subtitle = element_text(colour = col_ink, face = "bold", size = 8.5),
          axis.text.x = if (eje_x) element_text(angle = 90, vjust = 0.5, hjust = 1, size = 7)
                        else element_blank(),
          strip.text.y = element_text(angle = 0, hjust = 0, size = 7),
          panel.spacing.y = unit(0.3, "lines"))
}

panel_mosaico <- function(sel, titulo, ncol = 4) {
  etq_niv <- c("-1 DE" = tr("−1 DE del moderador", "−1 SD of the moderator"),
               "+1 DE" = tr("+1 DE del moderador", "+1 SD of the moderator"))
  sel <- sel %>% arrange(Dimension, Etiqueta, Cambio_pct) %>%
    mutate(caso = factor(caso, levels = unique(caso)))
  d <- pred %>%
    inner_join(sel %>% select(Modelo, Pais, Variable, caso), by = c("Modelo", "Pais", "Variable")) %>%
    mutate(Nivel = factor(Nivel, levels = niveles))
  ggplot(d, aes(x = nse_cwc, y = pred, colour = Nivel, fill = Nivel)) +
    geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.18, colour = NA) +
    geom_line(linewidth = 0.8) +
    geom_text(data = sel, aes(label = rotulo), x = -1.5, y = Inf,
              hjust = 0, vjust = 1.6, size = 2.2, colour = "#52514e", inherit.aes = FALSE) +
    facet_wrap(~ caso, ncol = ncol, scales = "free_y", drop = TRUE,
               labeller = label_wrap_gen(24)) +
    scale_colour_manual(values = col_niv, labels = etq_niv, name = NULL, drop = FALSE) +
    scale_fill_manual(values = col_niv, labels = etq_niv, name = NULL, drop = FALSE) +
    scale_x_continuous(breaks = c(-1, 0, 1), labels = c("−1", "0", "1")) +
    scale_y_continuous(expand = expansion(mult = c(0.05, 0.22))) +
    labs(subtitle = titulo, x = NULL, y = NULL) +
    tema +
    theme(plot.subtitle = element_text(colour = col_ink, face = "bold", size = 8.5),
          strip.text = element_text(size = 7, face = "bold", hjust = 0, colour = col_ink),
          axis.text = element_text(size = 6.5),
          panel.spacing = unit(0.6, "lines"))
}

## Encabezado de panel como texto (para que no dependa del ancho del panel)
encabezado <- function(txt) {
  wrap_elements(full = grid::textGrob(txt, x = 0, hjust = 0,
                                      gp = grid::gpar(fontface = "bold", fontsize = 8.5,
                                                      col = col_ink)))
}

## Fila de paneles con ancho de columna fijo: si hay menos de 4 casos,
## se completa con un espacio vacío en vez de estirar los paneles
fila_fija <- function(p, n, ncol = 4) {
  if (n >= ncol) return(p)
  p + plot_spacer() + plot_layout(widths = c(n, ncol - n))
}

mosaico <- function(casos, tipo, excluir_m3 = character(0), titulo, subtitulo, nota,
                    nombre, alto) {
  sel_m3 <- casos %>% filter(Modelo == "M3", Tipo == tipo, !Pais %in% excluir_m3)
  sel_m4 <- casos %>% filter(Modelo == "M4", Tipo == tipo)
  filas_m3 <- ceiling(nrow(sel_m3) / 4); filas_m4 <- ceiling(nrow(sel_m4) / 4)
  fig <- wrap_plots(
    encabezado(tr("A. Moderador agregado (M3): escuelas con −1 y +1 DE en el promedio escolar",
                  "A. Aggregate moderator (M3): schools at −1 and +1 SD of the school mean")),
    fila_fija(panel_mosaico(sel_m3, NULL), nrow(sel_m3)),
    encabezado(tr("B. Moderador percibido (M4): estudiantes con −1 y +1 DE respecto de su escuela",
                  "B. Perceived moderator (M4): students at −1 and +1 SD relative to their school")),
    fila_fija(panel_mosaico(sel_m4, NULL), nrow(sel_m4)),
    ncol = 1, heights = c(0.12, filas_m3, 0.12, filas_m4)) +
    plot_layout(guides = "collect") +
    plot_annotation(
      title = titulo,
      ## Los ejes son comunes a todos los paneles: se describen aquí
      subtitle = paste0(subtitulo, tr(
        "\nEje X: NSE del estudiante respecto del promedio de su escuela. Eje Y: conocimiento cívico predicho (escala libre por panel).",
        "\nX axis: student SES relative to the school mean. Y axis: predicted civic knowledge (free scale per panel).")),
      caption = nota, theme = tema) &
    theme(legend.position = "bottom", legend.justification = "left")
  guardar(fig, nombre, ancho = 7.5, alto = alto)
}

## -------------------------------------------------------------------
## Construcción de las figuras en cada idioma
## -------------------------------------------------------------------

for (idioma in idiomas) {

  dimensiones <- dimensiones_idioma()

  ## -----------------------------------------------------------------
  ## Figura 1. Efecto del NSE dentro y entre escuelas (M1a)
  ## -----------------------------------------------------------------

  comp_lbl <- c(s_nisb_cwc = tr("Dentro de la escuela", "Within schools"),
                s_nisb_m   = tr("Entre escuelas", "Between schools"))

  nse <- modelos %>%
    filter(Variable == "s_civlrn", Modelo == "M1a",
           Termino %in% c("s_nisb_cwc", "s_nisb_m")) %>%
    transmute(Pais, Termino, Estimacion,
              lo = Estimacion - 1.96 * SE, hi = Estimacion + 1.96 * SE) %>%
    left_join(diag, by = "Pais") %>%
    mutate(Componente = factor(comp_lbl[Termino], levels = unname(comp_lbl)),
           Pais = factor(Pais, levels = orden_paises))

  segmentos <- nse %>%
    select(Pais, Termino, Estimacion) %>%
    pivot_wider(names_from = Termino, values_from = Estimacion)

  etiq_icc <- diag %>%
    mutate(Pais = factor(Pais, levels = orden_paises),
           txt  = formatC(ICC_M0, format = "f", digits = 2,
                          decimal.mark = tr(",", ".")))

  fig1 <- ggplot(nse, aes(y = Pais)) +
    geom_vline(xintercept = 0, colour = "#c3c2b7", linewidth = 0.3) +
    geom_segment(data = segmentos,
                 aes(x = s_nisb_cwc, xend = s_nisb_m, yend = Pais),
                 colour = "#c3c2b7", linewidth = 0.6) +
    geom_errorbarh(aes(xmin = lo, xmax = hi, colour = Componente),
                   height = 0, linewidth = 0.5) +
    geom_point(aes(x = Estimacion, colour = Componente), size = 2.2) +
    geom_text(data = etiq_icc, aes(y = Pais, label = txt), x = 134,
              hjust = 1, size = 2.5, colour = col_muted) +
    annotate("text", x = 134, y = length(orden_paises) + 0.9, label = tr("CCI", "ICC"),
             hjust = 1, size = 2.5, colour = col_muted, fontface = "bold") +
    scale_colour_manual(values = c(col_within, col_between), name = NULL) +
    scale_x_continuous(limits = c(-10, 135), breaks = seq(0, 100, 25)) +
    coord_cartesian(clip = "off") +
    labs(title = tr("Figura 1. Efecto del nivel socioeconómico sobre el conocimiento cívico",
                    "Figure 1. Effect of socioeconomic status on civic knowledge"),
         subtitle = tr("Coeficientes de M1a e IC 95 %. Sistemas ordenados por CCI (de menor a mayor)",
                       "M1a coefficients and 95% CI. Systems ordered by ICC (lowest to highest)"),
         x = tr("Puntos de conocimiento cívico por unidad de NSE",
                "Civic knowledge points per unit of SES"),
         y = NULL,
         caption = tr(
           paste("Dentro de la escuela: s_nisb_cwc (desviación del estudiante respecto",
                 "del promedio de su escuela). Entre escuelas: s_nisb_m (promedio escolar).",
                 "\nSin ponderadores; primer valor plausible."),
           paste("Within schools: s_nisb_cwc (student deviation from",
                 "the school mean). Between schools: s_nisb_m (school mean).",
                 "\nUnweighted; first plausible value."))) +
    tema +
    theme(panel.grid.major.y = element_blank())

  guardar(fig1, "figura1_nse_dentro_entre", ancho = 6.5, alto = 5.5)

  ## -----------------------------------------------------------------
  ## Figura 2. Mapa de calor de las interacciones (M3 y M4)
  ## En esta figura, apertura a la discusión se agrupa en Participación.
  ## -----------------------------------------------------------------

  inter_grid <- clasif %>%
    left_join(de_mod, by = "Variable") %>%
    left_join(dimensiones_idioma(reclasificar = c(s_opdisc = "par")), by = "Variable") %>%
    mutate(Beta_std = Beta_interaccion * ifelse(Modelo == "M3", DE_between, DE_within),
           Pais     = factor(Pais, levels = orden_paises),
           sig      = p_valor < 0.05) %>%
    select(Modelo, Pais, Variable, Dimension, Etiqueta, Beta_std, sig) %>%
    ## Combinaciones sin estimación (ítem no administrado) como celdas vacías
    complete(nesting(Modelo, Variable, Dimension, Etiqueta), Pais,
             fill = list(sig = FALSE))

  fig2 <- (panel_calor(inter_grid, "M3",
                       tr("A. Moderador agregado (M3: promedio escolar × NSE)",
                          "A. Aggregate moderator (M3: school mean × SES)"),
                       eje_x = FALSE) /
           panel_calor(inter_grid, "M4",
                       tr("B. Moderador percibido (M4: desviación del estudiante × NSE)",
                          "B. Perceived moderator (M4: student deviation × SES)"))) +
    patchwork::plot_layout(guides = "collect", heights = c(8, 7)) +
    patchwork::plot_annotation(
      title = tr("Figura 2. Moderación de la brecha socioeconómica por las características escolares",
                 "Figure 2. Moderation of the socioeconomic gap by school characteristics"),
      subtitle = tr(
        paste("Azul: la brecha por NSE dentro de la escuela es menor donde el moderador es mayor (mitigación).",
              "\nRojo: es mayor (aceleración). Sistemas ordenados por CCI, de menor a mayor."),
        paste("Blue: the within-school SES gap is smaller where the moderator is higher (mitigation).",
              "\nRed: it is larger (acceleration). Systems ordered by ICC, lowest to highest.")),
      caption = tr(
        paste("Coeficiente de interacción multiplicado por la DE del moderador (M3: DE entre escuelas; M4: DE dentro de la escuela;",
              "\nasignatura separada: DE de la proporción de escuelas). Abuso mide un clima negativo: azul indica una brecha menor",
              "donde hay\nmás abuso. –: ítem no administrado. p sin ajustar; sin ponderadores; primer valor plausible."),
        paste("Interaction coefficient multiplied by the moderator's SD (M3: between-school SD; M4: within-school SD;",
              "\nseparate subject: SD of the proportion of schools). Abuse measures a negative climate: blue indicates a smaller gap",
              "where there\nis more abuse. –: item not administered. Unadjusted p; unweighted; first plausible value.")),
      theme = tema) &
    theme(legend.position = "bottom", legend.justification = "left",
          legend.key.width = unit(1.2, "cm"), legend.key.height = unit(0.25, "cm"),
          legend.title = element_text(size = 7.5, colour = "#52514e")) &
    guides(fill = guide_colourbar(order = 1, title.position = "top"),
           shape = guide_legend(order = 2, title.position = "top"))

  guardar(fig2, "figura2_mapa_interacciones", ancho = 7.5, alto = 7)

  ## -----------------------------------------------------------------
  ## Figura 3 (y S1). Mosaico de la brecha por NSE a −1 y +1 DE del moderador
  ## Lee predicciones_interacciones.xlsx (exportado por el Rmd), con IC 95 %.
  ## -----------------------------------------------------------------

  casos <- pend %>%
    left_join(dimensiones %>% mutate(Etiqueta = as.character(Etiqueta)), by = "Variable") %>%
    mutate(caso = paste0(Pais, if_else(Singular, " †", ""), " · ", Etiqueta),
           rotulo = paste0(fmt1(Pendiente_menos1DE), " → ", fmt1(Pendiente_mas1DE),
                           " (", if_else(Cambio_pct > 0, "+", "−"),
                           formatC(abs(Cambio_pct), format = "f", digits = 0),
                           tr(" %", "%"), ")"))

  nota_comun <- tr(
    paste("Rectas predichas para una escuela promedio del sistema (demás covariables en su media), con IC 95 %.",
          "\nRótulo: pendiente del NSE a −1 DE → +1 DE del moderador (cambio respecto de la pendiente del modelo).",
          "† Ajuste singular. p sin ajustar;\nsin ponderadores; primer valor plausible."),
    paste("Predicted lines for an average school in the system (other covariates at their mean), with 95% CI.",
          "\nLabel: SES slope at −1 SD → +1 SD of the moderator (change relative to the model slope).",
          "† Singular fit. Unadjusted p;\nunweighted; first plausible value."))

  mosaico(casos, "Mitigación", excluir_m3 = "HKG",
          titulo = tr("Figura 3. La brecha por NSE dentro de la escuela donde se observa mitigación",
                      "Figure 3. The within-school SES gap where mitigation is observed"),
          subtitulo = tr("Interacciones con p < 0,05 y coeficiente negativo (4 de 189 en M3; 12 de 168 en M4)",
                         "Interactions with p < .05 and a negative coefficient (4 of 189 in M3; 12 of 168 in M4)"),
          nota = paste(nota_comun,
                       tr("Se omite Hong Kong (M3, relación estudiante-docente): su pendiente del NSE dentro de la escuela es ≈ 0.",
                          "Hong Kong is omitted (M3, student–teacher relations): its within-school SES slope is ≈ 0.")),
          nombre = "figura3_mosaico_mitigacion", alto = 8.5)

  mosaico(casos, "Aceleración",
          titulo = tr("Figura S1. La brecha por NSE dentro de la escuela donde se observa aceleración",
                      "Figure S1. The within-school SES gap where acceleration is observed"),
          subtitulo = tr("Interacciones con p < 0,05 y coeficiente positivo (2 de 189 en M3; 7 de 168 en M4)",
                         "Interactions with p < .05 and a positive coefficient (2 of 189 in M3; 7 of 168 in M4)"),
          nota = nota_comun,
          nombre = "figuraS1_mosaico_aceleracion", alto = 6.5)

  cat("✓ Figuras guardadas en", file.path(dir_fig, idioma), "\n")
}
