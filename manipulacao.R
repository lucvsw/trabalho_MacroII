# Importando os dados do trabalho

# Pacotes necessários
pacotes <- c("GetBCBData", "rvest", "dplyr", "fredr")
invisible(lapply(pacotes, function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
  library(pkg, character.only = TRUE)
}))

# Importando dados do SGS - Sistema Gerenciador de Séries Temporais
dados_sgs <- GetBCBData::gbcbd_get_series(
  id = c("Selic" = 4390, 
         "IBC" = 24363, 
         "IPCA" = 433,
         "cambio_real" = 11752),
  first.date = "2003-01-01",
  last.date = "2024-02-01",
  format.data = "wide"
)
tail(dados_sgs)

# Importando dados do preço petróleo
url <- "https://www.indexmundi.com/commodities/?commodity=crude-oil&months=360"
# Ler o conteúdo da página
webpage <- read_html(url)
# Usando o CSS Selector para pegar a tabela
oil_table <- webpage %>%
  html_node("table#gvPrices") %>%
  html_table()
# Visualizar os primeiros dados da tabela
head(oil_table) # agora temo os dados do preço do petróleo (Crude Oil (petroleum) Monthly Price - US Dollars per Barrel)
# Selecionar as observações a partir da linha 103 (para começar o dataframe a partir da data: 2003-01-01)
oil_table_filtered <- oil_table %>%
  select(-Change) %>%
  slice(103:(n() - 2))

# Importando dados da inflação americana do FRED
# fredr_set_key("38101a558752bc4868ebc999d5dcb7fa") # API key, FRED
ipc <- fredr(
  series_id = "CPALTT01USM657N",
  observation_start = as.Date("2003-01-01"),
  observation_end = as.Date("2024-02-01")) %>%
  select(date, value)

# Combinando as tabelas
dados_completo <- dados_sgs %>%
  mutate(oil = oil_table_filtered$Price,
         ipc_us = ipc$value)
