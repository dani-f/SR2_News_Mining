SR2 News Mining
================

<!-- analysis.md is generated from analysis.Rmd -->
# Forschungsfrage

Welche Nachrichten kommen in den stündlichen Funk SR2 Nachrichtenblöcken vor?

``` r
# Load dictionary
stop_words_german <-
  data.frame("Wort" = stopwords::stopwords("de", source = "snowball"))

# Analysis
## Keyword frecuency
Bilanz %>%
  unnest_tokens(output = "Wort", input = Themen) %>% 
  anti_join(stop_words_german, by = "Wort") %>% 
  count(Datum, Wort, name = "Anzahl", sort = TRUE) %>% 
  head(30)
```

    ##         Datum           Wort Anzahl
    ## 1  22.01.2021         corona      5
    ## 2  02.12.2020         corona      4
    ## 3  03.09.2020           fall      4
    ## 4  07.10.2020         corona      4
    ## 5  11.06.2021          hätte      4
    ## 6  12.10.2020         corona      4
    ## 7  15.03.2021     reaktionen      4
    ## 8  16.07.2021           lage      4
    ## 9  16.12.2020      bundestag      4
    ## 10 23.06.2021      antarktis      4
    ## 11 26.11.2020         corona      4
    ## 12 27.08.2020             eu      4
    ## 13 30.10.2020         corona      4
    ## 14 01.07.2021         corona      3
    ## 15 02.12.2020          trier      3
    ## 16 03.09.2020        nawalny      3
    ## 17 07.06.2021           wahl      3
    ## 18 08.04.2021        sputnik      3
    ## 19 08.12.2020         anhalt      3
    ## 20 08.12.2020        debatte      3
    ## 21 08.12.2020       lockdown      3
    ## 22 08.12.2020        sachsen      3
    ## 23 09.11.2020     reaktionen      3
    ## 24 10.03.2021         corona      3
    ## 25 10.11.2020         corona      3
    ## 26 10.11.2020             eu      3
    ## 27 10.11.2020      impfstoff      3
    ## 28 11.06.2021    lieferkette      3
    ## 29 13.04.2021       kabinett      3
    ## 30 14.05.2021 nahostkonflikt      3
