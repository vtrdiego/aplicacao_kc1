## O projeto contém as seguintes aplicações:

**analise_kc1.R**

Esse script executa as seguintes tarefas no console RStudio:

1)Análise Estatística Descritiva  
• Carrega o dataset.  
• Apresenta para cada coluna numérica:  
* Medidas de tendência central (média, mediana, moda),  
     o Medidas de dispersão (desvio padrão, mínimo, máximo, amplitude).  
• Gera visualizações:  
     o Histogramas com curvas de densidade,  
     o Boxplots,  
     o Testes de normalidade (Shapiro-Wilk ou Kolmogorov-Smirnov).  

2)Análise de Correlação  
• Gera uma matriz de correlação entre todas as variáveis numéricas.  
• Interpreta os resultados, destacando quais variáveis possuem maior correlação com NUMDEFECTS.  
• Cria gráficos de dispersão com linha de tendência para as variáveis mais correlacionadas com NUMDEFECTS.  

3)Regressão Linear  
• Contém um modelo de regressão linear simples, com NUMDEFECTS como variável dependente, que apresenta:  
    o Coeficientes estimados,  
    o R2 e R2 ajustado,  
    o Valores-p,  
    o Diagnóstico dos resíduos.  

**plumber.R**

Esse script implementa uma API via console RStudio que utiliza um modelo de regressão linear, no qual é possível  
inserir métricas para previsão de NUMDEFECTS. A utilização da API é feita através das seguintes etapas:

Etapa 1 (Ativar a API via console RStudio):<br>  

library(plumber)<br>  
r <- plumb("C:/Users/victor.diego/Desktop/trabalho_G2/plumber.R")  
r$run(port = 5000)  

Etapa 2 (Testar input de métricas via POST através de um segundo console RStudio):  

library(httr)<br>  
library(jsonlite)  

- Criar o JSON com os valores das métricas:<br>  
entrada <- list(  
    COUPLING_BETWEEN_OBJECTS = 10,  
    DEPTH_INHERITANCE = 2,  
    LACK_OF_COHESION_OF_METHODS = 85,  
    FAN_IN = 1,  
    RESPONSE_FOR_CLASS = 30,  
    WEIGHTED_METHODS_PER_CLASS = 25,  
    sumLOC_TOTAL = 400  
)  

- Fazer a requisição POST:<br>  
resposta <- POST(  
    url = "http://localhost:8000/prever",  
    body = toJSON(entrada, auto_unbox = TRUE),  
    encode = "json"  
)  

- Ver resultado:<br>  
content(resposta, as = "parsed", simplifyVector = TRUE)  

**app.R**

Esse script cria uma aplicação no qual utiliza a lógica do modelo de regressão e cria uma interface interativa com Shiny que permita ao usuário:  

•Inserir valores para as métricas do modelo,  
•Visualizar a previsão de NUMDEFECTS,  
•Ver os gráficos utilizados na análise.  

# Link da aplicação disponibilizada via Shiny:  
https://victor-diego.shinyapps.io/shiny_app_g2/
