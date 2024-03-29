# Load pckgs
library(rvest)
library(xml2)
library(httr)
library(dplyr)
library(stringr)
library(tibble)
library(lubridate)

# Pass URLs
URL_Bilanz_am_Mittag <- "https://www.sr-mediathek.de/index.php?seite=8&sen=SR2_BAM_P"
URL_Bilanz_am_Abend <- "https://www.sr-mediathek.de/index.php?seite=8&sen=SR2_BAA_P"

# Scrape html
html_Bilanz_am_Mittag <- read_html(GET(URL_Bilanz_am_Mittag,
                                       config(ssl_verifypeer = 0L, ssl_verifyhost = 0L)))
html_Bilanz_am_Abend <- read_html(GET(URL_Bilanz_am_Abend,
                                      config(ssl_verifypeer = 0L, ssl_verifyhost = 0L)))

# Extract data
## Links Mittag
Links_Mittag <- html_Bilanz_am_Mittag %>%
  html_nodes("h3 a") %>%
  html_attr("href")
Links_Mittag <- paste0("https://www.sr-mediathek.de/", Links_Mittag)

## Links Abend
Links_Abend <- html_Bilanz_am_Abend %>%
  html_nodes("h3 a") %>% html_attr("href")
Links_Abend <- paste0("https://www.sr-mediathek.de/", Links_Abend)

## Länge and Datum Mittag
Laenge_Datum_Mittag <- html_Bilanz_am_Mittag %>%
  html_nodes("div#picturearticle_collection_box div.teaser__text__footer__wrapper") %>% 
  html_text() %>%
  str_extract_all("Länge: \\d{2}:\\d{2}:\\d{2}|Datum: \\d{2}\\.\\d{2}\\.\\d{4}")
### Clean Länge and Datum
Laenge_Datum_Mittag_clean <-
  matrix(unlist(Laenge_Datum_Mittag),
         nrow = length(Laenge_Datum_Mittag),
         byrow = TRUE) %>%
  as_tibble() %>% 
  mutate(Laenge = str_trim(str_sub(V1, start = -8)),
         Laenge = hms(str_split(Laenge, ":")),
         Datum = str_trim(str_sub(V2, start = -11)),
         Datum = as.Date(Datum, format = "%d.%m.%Y")) %>% 
  select(Laenge, Datum)

## Länge and Datum Abend
Laenge_Datum_Abend <- html_Bilanz_am_Abend %>%
  html_nodes("div#picturearticle_collection_box div.teaser__text__footer__wrapper") %>% 
  html_text() %>% 
  str_extract_all("Länge: (\\d{2}:\\d{2}:\\d{2})?|Datum: \\d{2}\\.\\d{2}\\.\\d{4}") # '?' means that the numerical part of Länge is optional. This was necessary as this numerical part was missing for 16/11/2023.
### Clean Länge and Datum
Laenge_Datum_Abend_clean <-
  matrix(unlist(Laenge_Datum_Abend),
         nrow = length(Laenge_Datum_Abend),
         byrow = TRUE) %>%
  as_tibble() %>% 
  mutate(Laenge = str_trim(str_sub(V1, start = -8)),
         Laenge = hms(str_split(Laenge, ":")),
         Datum = str_trim(str_sub(V2, start = -11)),
         Datum = as.Date(Datum, format = "%d.%m.%Y")) %>% 
  select(Laenge, Datum)

## Autor and Themen Mittag
Autor_Mittag <- 0
Themen_Mittag <- 0
for (i in 1:length(Links_Mittag)) { 
  Detail_Mittag <- read_html(GET(Links_Mittag[i],
                                 config(ssl_verifypeer = 0L, ssl_verifyhost = 0L)))
  Autor_Mittag[i] <- Detail_Mittag %>%
    html_nodes("div.article__content div p") %>% 
    html_text(trim = TRUE)
  # Caution with xml_remove(), save and assign frequently!
  Themen_parent <- Detail_Mittag %>% html_node("div.article__container")
  Themen_child <- Themen_parent %>% html_nodes("div") 
  xml_remove(Themen_child)
  Themen_Mittag[i] <- Themen_parent %>% html_text(trim = TRUE)
}
### Clean Autor
Autor_Mittag <- Autor_Mittag %>%
  str_extract_all("SR 2 - .+") %>%
  str_sub(start = 8)
### Clean Themen
Themen_Mittag <- Themen_Mittag %>%
  # Match start of the input, then everything including \n
  str_remove(regex("\\A.*(Themen: |Themen:|Themen :|Themen;|Rep: )", # Does anyone have a more robust solution to detect those incoherent spellings?
                   dotall = TRUE)) %>% 
  # Match end of the input, then any whitespace including \n \t
  str_remove("\\s+Artikel mit anderen teilen\\z")

## Autor and Themen Abend
Autor_Abend <- 0
Themen_Abend <- 0
for (i in 1:length(Links_Abend)) { 
  Detail_Abend <- read_html(GET(Links_Abend[i],
                                 config(ssl_verifypeer = 0L, ssl_verifyhost = 0L)))
  Autor_Abend[i] <- Detail_Abend %>%
    html_nodes("div.article__content div p") %>% 
    html_text(trim = TRUE)
  # Caution with xml_remove(), save and assign frequently!
  Themen_parent <- Detail_Abend %>% html_nodes("div.article__container")
  Themen_child <- Themen_parent %>% html_nodes("div") 
  xml_remove(Themen_child)
  Themen_Abend[i] <- Themen_parent %>% html_text(trim = TRUE)
}
### Clean Autor
Autor_Abend <- Autor_Abend %>%
  str_extract_all("SR 2 - .+") %>%
  str_sub(start = 8)
### Clean Themen
Themen_Abend <- Themen_Abend %>%
  # Match start of the input, then everything including \n
  str_remove(regex("\\A.*(Themen: |Themen:|Themen :|Themen;|Rep: )",
                   dotall = TRUE)) %>% 
  # Match end of the input, then any whitespace including \n \t
  str_remove("\\s+Artikel mit anderen teilen\\z")

# Create data frames
Bilanz_am_Mittag <- data.frame(Themen = Themen_Mittag,
                               Links = Links_Mittag,
                               Autor = Autor_Mittag,
                               Laenge_Datum_Mittag_clean,
                               stringsAsFactors = FALSE)

Bilanz_am_Abend <- data.frame(Themen = Themen_Abend,
                              Links = Links_Abend,
                              Autor = Autor_Abend,
                              Laenge_Datum_Abend_clean,
                              stringsAsFactors = FALSE)

# Final data frame
news <- bind_rows("Mittag" = Bilanz_am_Mittag,
                  "Abend" = Bilanz_am_Abend,
                  .id = "Format")

# Save data frame
save(news, file = paste0("data/", "news_", Sys.Date(), ".Rdata"))
write.csv2(news, file = paste0("data/", "news_", Sys.Date(), ".csv"))
