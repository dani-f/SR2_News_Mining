SR2 News Mining
================

<!-- analysis.md is generated from analysis.Rmd -->

# Introduction

Topics are set and public opinion is framed by broadcasting stations.
This project wants to analyze the daily news broadcasted by German radio
station SR2.

``` r
# Setup
# Load pckgs
library(knitr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(tidytext)
library(tidyr)

# Load data
date_of_data_to_load <- "2021-10-05"
load(file = paste0("data/", "news_", date_of_data_to_load, ".Rdata"))
```

# Analysis

The data collected from the webpage go from 2017-08-31 to 2021-10-05.

``` r
# Articles by month
news %>%
  count(Monat = floor_date(Datum, "month"),
        name = "Artikelanzahl") %>%
  ggplot(aes(x = Monat, y = Artikelanzahl)) +
  geom_col() +
  scale_x_date(date_breaks = "3 months") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
```

![](analysis_files/figure-gfm/articles%20by%20month-1.png)<!-- -->

Unfortunately, SR2 seems to have deleted their data or they simply did
not upload their editions consequently before August 2020. Therefore, to
not bias our analysis, the 10 articles from before August 2020 are
deleted (listwise deletion, since these are just a few cases).

``` r
# Listwise deletion
news_clean <- news %>% filter(Datum >= "2020-08-01")
```

We then observe, while Bilanz am Abend is published on weekdays, Bilanz
am Mittag also appears on Saturdays. Sunday is holiday.

``` r
# Articles by day of week
news_clean %>%
  count(Format,
        Wochentag = wday(Datum, locale = "German", label = TRUE),
        name = "Anzahl") %>% 
  ggplot(aes(x = Wochentag, y = Anzahl, fill = Format)) +
  geom_col()
```

![](analysis_files/figure-gfm/articles%20by%20day%20of%20week-1.png)<!-- -->

When focusing on the narrators, it is interesting to note how the SR
webpage content managers do not know the names of their colleagues. See
how many different spellings appear here.

``` r
# Distinct authors/narrators
news_clean %>% distinct(Autor) %>% arrange(Autor)
```

    ##                    Autor
    ## 1          Florian Mayer
    ## 2          Folrian Mayer
    ## 3         Isabel Tentrup
    ## 4       Isabell Tentrupp
    ## 5       Isabelle Tentrup
    ## 6       Îsabelle Tentrup
    ## 7      Isabelle Tentrupp
    ## 8           Janek Böffel
    ## 9          Jochen Marmit
    ## 10           Karin Mayer
    ## 11           Kathrin Aue
    ## 12            Katrin Aue
    ## 13          Lisa Krauser
    ## 14       Peter Weitzmann
    ## 15      SR 2 Kulturradio
    ## 16      SR 2 KulturRadio
    ## 17         Stefan Deppen
    ## 18        Stephan Deppen
    ## 19       Stephan Deppenh
    ## 20        Thomas Shihabi
    ## 21        Thomas SHihabi
    ## 22 Thomas Shihabi et al.
    ## 23     Yvonne Scheinhege
    ## 24    Yvonne Schleinhege

Let’s head on to analyse the content and check which news appear within
the daily news blocks.

## Keywords by number of appearence

First, we load a dictionary with german stop-words so then we can delete
unnecessary words of the news messages.

``` r
# Load dictionary
stop_words_german <-
  data.frame("Wort" = stopwords::stopwords("de", source = "snowball"))
# Delete stopwords
news_clean_unnested <- news_clean %>%
  unnest_tokens(output = "Wort", input = Themen) %>% 
  anti_join(stop_words_german, by = "Wort")
```

Now, let’s print the top keywords by number of appearance.

``` r
# Keyword frecuency
top_n_keywords <- 30
news_clean_unnested %>% 
  count(Wort, name = "Anzahl", sort = TRUE) %>% 
  head(top_n_keywords)
```

    ##           Wort Anzahl
    ## 1       corona    243
    ## 2           eu    110
    ## 3     saarland     83
    ## 4         lage     79
    ## 5         neue     56
    ## 6  afghanistan     54
    ## 7    interview     52
    ## 8   reaktionen     42
    ## 9    bundestag     40
    ## 10    lockdown     40
    ## 11     debatte     38
    ## 12         usa     38
    ## 13        mehr     37
    ## 14        wahl     37
    ## 15       china     36
    ## 16   kommentar     35
    ## 17          us     34
    ## 18 deutschland     30
    ## 19       jahre     30
    ## 20       woche     29
    ## 21          ab     27
    ## 22       spahn     26
    ## 23  frankreich     25
    ## 24   impfstoff     25
    ## 25    aktuelle     24
    ## 26        bund     24
    ## 27       biden     23
    ## 28      länder     23
    ## 29      berlin     22
    ## 30  diskussion     22

We see, Corona clearly dominated the news and also EU related topics
were discussed. Since SR2 is a regional broadcasting station, we also
observe the keyword Saarland. If we sum up all US related keywords that
show up (Biden, Trump, USA, US) we notice it is another dominant topic,
yet before news about the EU.

``` r
# Frecuency US related words
news_clean_unnested %>% 
  mutate(Wort = ifelse(Wort %in% c("biden", "trump", "usa", "us"),
                       "US_keywords_summary", Wort)) %>% 
  count(Wort, name = "Anzahl", sort = TRUE) %>% 
  head(3)
```

    ##                  Wort Anzahl
    ## 1              corona    243
    ## 2 US_keywords_summary    114
    ## 3                  eu    110

On top of the list we also find Afghanistan, which might have entered
the daily news just recently. Let’s confirm this statement with the data
and print keywords over time.

## Keywords over time

``` r
# Select keywords
keywords <- c("lockdown", "corona", "afghanistan", "kabul")

# Selected keywords over time
news_clean_unnested %>% 
  count(Wort, Monat = floor_date(Datum, "month"), name = "Anzahl") %>% 
  filter(Wort %in% keywords) %>% 
  # If keyword does not appear in certain month, insert row with explicit 0
  complete(Monat = seq(
    from = floor_date(min(news_clean_unnested$Datum), "month"),
    to = max(news_clean_unnested$Datum),
    by = "month"),
    Wort,
    fill = list(Anzahl = 0)) %>% 
  ggplot(aes(x = Monat, y = Anzahl, color = Wort)) +
  geom_line(size = 1) +
  scale_x_date(breaks = "1 month") +
  theme(axis.text.x = element_text(angle = 75, vjust = 0.58))
```

![](analysis_files/figure-gfm/keywords%20over%20time-1.png)<!-- -->

Indeed, we see that Afghanistan and its capital Kabul were almost not
present in the news till early 2021 and then increased heavily from July
2021. While the discourse about Corona is slowly decreasing, although
still present, we see that the word lockdown had a boom in December 2020
and suddenly disappeard after April 2021. Shall we assume there was an
internal SR2-guideline that prohibited using that word or may the reason
be that since May 2021 lockdown measures were removed step by step?

*work in progress*
