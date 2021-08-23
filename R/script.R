### Scraping Data
#load pckgs
require(rvest)
library(httr)
require(dplyr)

Link_Bilanz_am_Mittag <- "https://dev2.sr-mediathek.sr-multimedia.de/index.php?seite=8&sen=SR2_BAM_P&tbl=pf"
Link_Bilanz_am_Abend <- "https://dev2.sr-mediathek.sr-multimedia.de/index.php?seite=8&sen=SR2_BAA_P&tbl=pf"

Bilanz_am_Mittag <- read_html(GET(Link_Bilanz_am_Mittag,
                                  config(ssl_verifypeer = 0L, ssl_verifyhost = 0L),
                                  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0")))

Bilanz_am_Abend <- read_html(GET(Link_Bilanz_am_Abend,
                                  config(ssl_verifypeer = 0L, ssl_verifyhost = 0L),
                                  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0")))

Bilanz_am_Mittag %>%
  html_nodes(".teaser__text__paragraph") %>% 
  html_text()
