### Scraping Data
# Load pckgs
library(rvest)
library(httr)
library(dplyr)
library(stringr)
library(tibble)

# Pass URLs
URL_Bilanz_am_Mittag <- "https://dev2.sr-mediathek.sr-multimedia.de/index.php?seite=8&sen=SR2_BAM_P&tbl=pf"
URL_Bilanz_am_Abend <- "https://dev2.sr-mediathek.sr-multimedia.de/index.php?seite=8&sen=SR2_BAA_P&tbl=pf"

# Scrape html
html_Bilanz_am_Mittag <- read_html(GET(URL_Bilanz_am_Mittag,
                                  config(ssl_verifypeer = 0L, ssl_verifyhost = 0L),
                                  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0")))
html_Bilanz_am_Abend <- read_html(GET(URL_Bilanz_am_Abend,
                                  config(ssl_verifypeer = 0L, ssl_verifyhost = 0L),
                                  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0")))

# Extract data
# Themen
Themen_Mittag <- html_Bilanz_am_Mittag %>%
  html_nodes("div#picturearticle_collection_box p.teaser__text__paragraph") %>% 
  html_text() %>%
  str_remove("^.+(Themen: |Themen:|Themen :|Themen;)|Rep: ") #wtf SR

Themen_Abend <- html_Bilanz_am_Abend %>%
  html_nodes("div#picturearticle_collection_box p.teaser__text__paragraph") %>% 
  html_text() %>%
  str_remove("^.+(Themen: |Themen:|Themen :|Themen;)|Rep: ")

# Links
Links_Mittag <- html_Bilanz_am_Mittag %>%
  html_nodes("h3 a") %>%
  html_attr("href")
Links_Mittag <- paste0("https://dev2.sr-mediathek.sr-multimedia.de/", Links_Mittag)

Links_Abend <- html_Bilanz_am_Abend %>%
  html_nodes("h3 a") %>% html_attr("href")
Links_Abend <- paste0("https://dev2.sr-mediathek.sr-multimedia.de/", Links_Abend)

# Länge und Datum
Laenge_Datum_Mittag <- html_Bilanz_am_Mittag %>%
  html_nodes("div#picturearticle_collection_box div.teaser__text__footer__wrapper") %>% 
  html_text() %>% 
  str_extract_all("Länge.{10}|Datum.{12}")
# Clean Länge und Datum
Laenge_Datum_Mittag <-
  matrix(unlist(Laenge_Datum_Mittag),
         nrow = length(Laenge_Datum_Mittag),
         byrow = TRUE) %>%
  as_tibble() %>% 
  mutate(Laenge = str_trim(str_sub(V1, start = -8)),
         Datum = str_trim(str_sub(V2, start = -11))) %>% 
  select(Laenge, Datum)

Laenge_Datum_Abend <- html_Bilanz_am_Abend %>%
  html_nodes("div#picturearticle_collection_box div.teaser__text__footer__wrapper") %>% 
  html_text() %>% 
  str_extract_all("Länge.{10}|Datum.{12}")
# Clean Länge und Datum
Laenge_Datum_Abend <-
  matrix(unlist(Laenge_Datum_Abend),
         nrow = length(Laenge_Datum_Abend),
         byrow = TRUE) %>%
  as_tibble() %>% 
  mutate(Laenge = str_trim(str_sub(V1, start = -8)),
         Datum = str_trim(str_sub(V2, start = -11))) %>% 
  select(Laenge, Datum)

# Autor
Autor_Mittag <- 0
for (i in 1:length(Links_Mittag)) {
  Autor_Mittag[i] <-
    read_html(GET(Links_Mittag[i],
                  config(ssl_verifypeer = 0L, ssl_verifyhost = 0L),
                  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0"))) %>%
    html_nodes("div.article__content div p") %>% 
    html_text()
}
# Clean Autor
Autor_Mittag <- Autor_Mittag %>%
  str_extract_all("SR 2 - .+") %>%
  str_sub(start = 8) %>% 
  str_trim()

Autor_Abend <- 0
for (i in 1:length(Links_Abend)) {
  Autor_Abend[i] <-
    read_html(GET(Links_Abend[i],
                  config(ssl_verifypeer = 0L, ssl_verifyhost = 0L),
                  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0"))) %>%
    html_nodes("div.article__content div p") %>% 
    html_text()
}
# Clean Autor
Autor_Abend <- Autor_Abend %>%
  str_extract_all("SR 2 - .+") %>%
  str_sub(start = 8) %>% 
  str_trim()

# Create data frame
Bilanz_am_Mittag <- data.frame(Themen = Themen_Mittag,
                               Links = Links_Mittag,
                               Autor = Autor_Mittag,
                               Laenge_Datum_Mittag,
                               stringsAsFactors = FALSE)

Bilanz_am_Abend <- data.frame(Themen = Themen_Abend,
                               Links = Links_Abend,
                               Autor = Autor_Abend,
                               Laenge_Datum_Abend,
                               stringsAsFactors = FALSE)

# Final data frame
Bilanz <- bind_rows("Mittag" = Bilanz_am_Mittag,
                    "Abend" = Bilanz_am_Abend,
                    .id = "Format")
