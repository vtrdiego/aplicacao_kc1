# Carregar pacotes
library(tidyverse)
library(readxl)
library(PerformanceAnalytics)
library(ggpubr)
library(car)
library(modeest)
library(broom)

# 1) Análise Estatística Descritiva ----

# Carregar o dataset
dados <- read_excel("C:/Users/victor.diego_ipnet.IPM658/Desktop/topicas2/dataset_KC1_classlevel_numdefect.xlsx")

# Exibir estrutura
glimpse(dados)

# Função personalizada para as estatísticas descritivas
calcular_estatisticas <- function(x) {
  tibble(
    media = mean(x, na.rm = TRUE),
    mediana = median(x, na.rm = TRUE),
    moda = mfv(x),  # Moda (moda estatística)
    desvio_padrao = sd(x, na.rm = TRUE),
    minimo = min(x, na.rm = TRUE),
    maximo = max(x, na.rm = TRUE),
    amplitude = max(x, na.rm = TRUE) - min(x, na.rm = TRUE)
  )
}

# Aplicar para todas as variáveis numéricas
estatisticas <- dados %>%
  select(where(is.numeric)) %>%
  map_dfr(calcular_estatisticas, .id = "Variavel")

print(estatisticas)

# Histogramas com curvas de densidade
dados_long <- dados %>%
  pivot_longer(cols = where(is.numeric), names_to = "Variavel", values_to = "Valor")

ggplot(dados_long, aes(x = Valor)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "skyblue", color = "black") +
  geom_density(color = "red", size = 1) +
  facet_wrap(~ Variavel, scales = "free") +
  theme_minimal() +
  labs(title = "Histogramas com Curva de Densidade")

# Boxplots
ggplot(dados_long, aes(x = Variavel, y = Valor)) +
  geom_boxplot(fill = "lightgreen") +
  theme_minimal() +
  coord_flip() +
  labs(title = "Boxplots das Variáveis Numéricas")

# Testes de Normalidade (Shapiro-Wilk)
teste_normalidade <- dados %>%
  select(where(is.numeric)) %>%
  map_df(~ broom::tidy(shapiro.test(.)), .id = "Variavel")

print(teste_normalidade)

# 2) Análise de Correlação ----

# Selecionar apenas variáveis numéricas
dados_numeric <- dados %>% select(where(is.numeric))

# Matriz de Correlação (Pearson) com PerformanceAnalytics
chart.Correlation(dados_numeric, histogram = TRUE, pch = 19)

# Calcular correlações com NUMDEFECTS
correlacoes <- cor(dados_numeric, use = "complete.obs")

# Mostrar as correlações de cada variável com NUMDEFECTS
cor_numdefects <- correlacoes[,"NUMDEFECTS"] %>%
  sort(decreasing = TRUE)

print(cor_numdefects)

# Scatterplots das 3 variáveis mais correlacionadas com NUMDEFECTS (excluindo o próprio NUMDEFECTS)
variaveis_top <- names(sort(abs(cor_numdefects[-which(names(cor_numdefects) == "NUMDEFECTS")]), decreasing = TRUE))[1:3]

# Gráficos de dispersão com linha de tendência
for (var in variaveis_top) {
  print(
    ggplot(dados, aes_string(x = var, y = "NUMDEFECTS")) +
      geom_point(color = "blue") +
      geom_smooth(method = "lm", se = TRUE, color = "red") +
      theme_minimal() +
      labs(title = paste("Relação entre", var, "e NUMDEFECTS"))
  )
}

# 3) Regressão Linear Simples ----

# Usar a variável com maior correlação como preditora
variavel_preditor <- variaveis_top[1]

modelo <- lm(as.formula(paste("NUMDEFECTS ~", variavel_preditor)), data = dados)

# Resumo do modelo
summary(modelo)

# Diagnóstico dos resíduos
par(mfrow = c(2, 2))
plot(modelo)
par(mfrow = c(1, 1))