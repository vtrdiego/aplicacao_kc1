library(shiny)
library(tidyverse)
library(readxl)
library(ggplot2)

# Carrega o dataset
dados_originais <- read_excel("dataset_KC1_classlevel_numdefect.xlsx")

# Define variáveis preditoras
variaveis_predictoras <- names(dados_originais)[names(dados_originais) != "NUMDEFECTS"]

# Cria modelo
formula_modelo <- as.formula(paste("NUMDEFECTS ~", paste(variaveis_predictoras, collapse = " + ")))
modelo <- lm(formula_modelo, data = dados_originais)

ui <- fluidPage(
  titlePanel("Previsão de Defeitos com Regressão Múltipla"),

  sidebarLayout(
    sidebarPanel(
      lapply(variaveis_predictoras, function(var) {
        numericInput(inputId = var, label = var, value = NA)
      }),
      actionButton("prever", "Prever"),
      hr(),
      h4("Resultado da Previsão:"),
      verbatimTextOutput("resultado")
    ),

    mainPanel(
      conditionalPanel(
        condition = "output.mostrarGraficos == true",
        h4("Gráficos com Entrada do Usuário"),
        plotOutput("grafico_defeitos"),
        plotOutput("grafico_correlacao")
      )
    )
  )
)

server <- function(input, output, session) {

  # Armazena se houve previsão e os dados atualizados
  estado <- reactiveValues(
    previsao_feita = FALSE,
    dados = dados_originais
  )

  # Atualiza previsão e dados
  observeEvent(input$prever, {
    entrada <- map_dfc(variaveis_predictoras, ~ input[[.x]]) %>%
      set_names(variaveis_predictoras)

    if (any(is.na(entrada))) {
      output$resultado <- renderPrint({
        "Preencha todos os campos antes de prever."
      })
      estado$previsao_feita <- FALSE
    } else {
      # Faz a previsão
      predicao <- predict(modelo, newdata = entrada)
      output$resultado <- renderPrint({
        paste("Número previsto de defeitos:", round(predicao, 2))
      })

      # Adiciona a nova entrada como linha temporária nos dados
      nova_linha <- entrada %>%
        mutate(NUMDEFECTS = round(predicao, 2))

      estado$dados <- bind_rows(dados_originais, nova_linha)
      estado$previsao_feita <- TRUE
    }
  })

  # Exibe os gráficos apenas após previsão
  output$mostrarGraficos <- reactive({
    estado$previsao_feita
  })
  outputOptions(output, "mostrarGraficos", suspendWhenHidden = FALSE)

  # Gráfico 1: Distribuição dos defeitos (incluindo previsão)
  output$grafico_defeitos <- renderPlot({
    req(estado$previsao_feita)

    ggplot(estado$dados, aes(x = NUMDEFECTS)) +
      geom_histogram(binwidth = 1, fill = "#0073C2FF", color = "white") +
      theme_minimal() +
      labs(title = "Distribuição de Defeitos (com Previsão)", x = "NUMDEFECTS", y = "Frequência")
  })

  # Gráfico 2: Correlação com NUMDEFECTS (incluindo previsão)
  output$grafico_correlacao <- renderPlot({
    req(estado$previsao_feita)

    corr_data <- estado$dados %>%
      select(all_of(variaveis_predictoras), NUMDEFECTS) %>%
      summarise(across(all_of(variaveis_predictoras), ~ cor(.x, estado$dados$NUMDEFECTS, use = "complete.obs"))) %>%
      pivot_longer(everything(), names_to = "variavel", values_to = "correlacao")

    ggplot(corr_data, aes(x = reorder(variavel, correlacao), y = correlacao)) +
      geom_col(fill = "darkgreen") +
      coord_flip() +
      theme_minimal() +
      labs(title = "Correlação com NUMDEFECTS (com Previsão)", x = "Variável", y = "Correlação")
  })
}

shinyApp(ui, server)