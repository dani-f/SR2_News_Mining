### Scraping Data
# Load pckgs
library(rvest)
library(httr)
library(dplyr)
library(stringr)

# Pass URLs
URL_Bilanz_am_Mittag <- "https://dev2.sr-mediathek.sr-multimedia.de/index.php?seite=8&sen=SR2_BAM_P&tbl=pf"
URL_Bilanz_am_Abend <- "https://dev2.sr-mediathek.sr-multimedia.de/index.php?seite=8&sen=SR2_BAA_P&tbl=pf"

# Scrape html
Bilanz_am_Mittag <- read_html(GET(URL_Bilanz_am_Mittag,
                                  config(ssl_verifypeer = 0L, ssl_verifyhost = 0L),
                                  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0")))
Bilanz_am_Abend <- read_html(GET(URL_Bilanz_am_Abend,
                                  config(ssl_verifypeer = 0L, ssl_verifyhost = 0L),
                                  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0")))

# Extract data
# Themen
Themen_Mittag <- Bilanz_am_Mittag %>%
  html_nodes("div#picturearticle_collection_box p.teaser__text__paragraph") %>% 
  html_text()

# Links
Links_Mittag <- Bilanz_am_Mittag %>%
  html_nodes("h3 a") %>% html_attr("href")

# Länge und Datum
#Länge_Datum_Mittag <-
Bilanz_am_Mittag %>%
  html_nodes("div#picturearticle_collection_box div.teaser__text__footer__wrapper") %>% 
  html_text() %>% 
  str_extract_all("Länge.{10}|Datum.{12}")

# Autor
Autor_Mittag <- 0
for (i in 1:length(Links_Mittag)) {
  Autor_Mittag[i] <-
    read_html(GET(paste0("https://dev2.sr-mediathek.sr-multimedia.de/",
                         Links_Mittag[i]),
                  config(ssl_verifypeer = 0L, ssl_verifyhost = 0L),
                  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0"))) %>%
    html_nodes("div.article__content div p") %>% 
    html_text()
}

Autor_Mittag <- Autor_Mittag %>%
  str_extract_all("SR 2 - .+") %>%
  str_trim()
