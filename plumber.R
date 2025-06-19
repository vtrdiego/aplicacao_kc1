# Carregar pacotes
library(tidyverse)
library(readxl)
library(plumber)

# Carregar o dataset
dados <- read_excel("C:/Users/victor.diego/Desktop/trabalho_G2/dataset_KC1_classlevel_numdefect.xlsx")

# Definir as variáveis preditoras (todas as colunas exceto NUMDEFECTS)
variaveis_predictoras <- names(dados)[names(dados) != "NUMDEFECTS"]

# Criar o modelo de regressão múltipla
formula_modelo <- as.formula(paste("NUMDEFECTS ~", paste(variaveis_predictoras, collapse = " + ")))
modelo <- lm(formula_modelo, data = dados)

#* @apiTitle API Regressão Múltipla - Previsão NUMDEFECTS

#* Faz previsão de NUMDEFECTS com base nas métricas fornecidas
#* @param body:json JSON contendo os valores das métricas
#* @post /prever
function(req) {
  # Ler o JSON do corpo da requisição
  entrada <- jsonlite::fromJSON(req$postBody)

  # Verificar se todas as variáveis necessárias estão presentes
  faltantes <- setdiff(variaveis_predictoras, names(entrada))
  if (length(faltantes) > 0) {
    return(list(
      erro = paste("Faltando as seguintes variáveis na entrada:", paste(faltantes, collapse = ", "))
    ))
  }

  # Criar data frame com os valores recebidos
  novo_dado <- as_tibble(entrada)

  # Fazer a previsão
  predicao <- predict(modelo, newdata = novo_dado)

  # Retornar resultado
  list(
    input = entrada,
    predicao_NUMDEFECTS = predicao
  )
}
