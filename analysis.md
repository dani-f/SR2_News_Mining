SR2 News Mining
================

<!-- analysis.md is generated from analysis.Rmd -->
# Introduction

Topics are set and public opinion is framed by broadcasting stations. This project wants to analyze the daily news broadcasted by German radio station SR2.

``` r
# Setup
# Load pckgs
library(knitr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(tidytext)

# Load data
date_of_data_to_load <- "2021-08-26"
load(file = paste0("data/", "news_", date_of_data_to_load, ".Rdata"))
```

# Analysis

## Date range

The data collected from the webpage goes from 2017-08-31 to 2021-08-26.

``` r
news %>%
  count(Monat = floor_date(Datum, "month"),
        name = "Artikelanzahl") %>%
  ggplot(aes(x = Monat, y = Artikelanzahl)) +
  geom_col() +
  scale_x_date(date_breaks = "3 months") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
```

![](analysis_files/figure-markdown_github/articles%20by%20month-1.png)

Unfortunately, SR2 seems to have deleted their data or they simply did not upload their editions consequently before August 2020. Therefore, to not bias our analysis, the 10 articles from before August 2020 are deleted (listwise deletion, since these are just a few cases).

``` r
# Listwise deletion
news_clean <- news %>% filter(Datum >= "2020-08-01")
```

We then observe, while Bilanz am Abend is published on weekdays, Bilanz am Mittag also appears on Saturdays. Sunday is holiday.

``` r
# Articles by day of week
news_clean %>%
  count(Format, Wochentag = wday(Datum,
                                 locale = "German",
                                 label = TRUE)) %>% 
  ggplot(aes(x = Wochentag, y = n, fill = Format)) +
  geom_col()
```

![](analysis_files/figure-markdown_github/articles%20by%20day%20of%20week-1.png)

When focusing on the narrators, it is interesting to note how the SR webpage content managers do not know the names of their colleagues. See how many different spellings appear here.

``` r
# Distinct authors/narrators
news_clean %>% distinct(Autor) %>% arrange(Autor)
```

    ##                    Autor
    ## 1          Florian Mayer
    ## 2         Isabel Tentrup
    ## 3       Isabell Tentrupp
    ## 4       Isabelle Tentrup
    ## 5      Isabelle Tentrupp
    ## 6           Janek Böffel
    ## 7          Jochen Marmit
    ## 8            Karin Mayer
    ## 9            Kathrin Aue
    ## 10            Katrin Aue
    ## 11          Lisa Krauser
    ## 12        Mayer, Florian
    ## 13       Peter Weitzmann
    ## 14      SR 2 Kulturradio
    ## 15      SR 2 KulturRadio
    ## 16         Stefan Deppen
    ## 17        Stephan Deppen
    ## 18       Stephan Deppenh
    ## 19        Thomas Shihabi
    ## 20        Thomas SHihabi
    ## 21 Thomas Shihabi et al.
    ## 22     Yvonne Scheinhege
    ## 23    Yvonne Schleinhege

Let's head on to analyse the content and check which news appear within the daily news blocks.

## Keywords by number of appearence

First, we load a dictionary with german stop-words so then, we can delete unnecessary words of the news messages.

``` r
# Load dictionary
stop_words_german <-
  data.frame("Wort" = stopwords::stopwords("de", source = "snowball"))
```

Now, let's print the top 30 keywords by number of appearance.

``` r
# Keyword frecuency
news_clean %>%
  unnest_tokens(output = "Wort", input = Themen) %>% 
  anti_join(stop_words_german, by = "Wort") %>% 
  count(Wort, name = "Anzahl", sort = TRUE) %>% 
  head(top_n_keywords)
```

    ##           Wort Anzahl
    ## 1       corona    257
    ## 2           eu    109
    ## 3         lage     76
    ## 4     saarland     73
    ## 5    interview     51
    ## 6   reaktionen     49
    ## 7         neue     48
    ## 8    bundestag     44
    ## 9  afghanistan     42
    ## 10    lockdown     41
    ## 11     debatte     37
    ## 12   kommentar     34
    ## 13 deutschland     33
    ## 14       jahre     32
    ## 15        mehr     32
    ## 16         usa     32
    ## 17       china     29
    ## 18       trump     29
    ## 19          us     29
    ## 20       spahn     27
    ## 21        bund     26
    ## 22        wahl     26
    ## 23       woche     26
    ## 24          ab     25
    ## 25       biden     25
    ## 26    aktuelle     24
    ## 27  diskussion     24
    ## 28      merkel     24
    ## 29      berlin     23
    ## 30  frankreich     23

We see, Corona clearly dominated the news and also EU related topics were discussed. Since SR2 is a regional broadcasting station, we also observe the keyword Saarland. If we sum up all US related keywords (Biden, Trump, USA, US) we notice it is another dominant topic, yet before news about the EU.

``` r
# Frecuency US related words
news_clean %>%
  unnest_tokens(output = "Wort", input = Themen) %>% 
  anti_join(stop_words_german, by = "Wort") %>% 
  mutate(Wort = ifelse(Wort %in% c("biden", "trump", 
                                   "usa", "us"),
                "US_keywords_summary", Wort)) %>% 
  count(Wort, name = "Anzahl", sort = TRUE) %>% 
  head(3)
```

    ##                  Wort Anzahl
    ## 1              corona    257
    ## 2 US_keywords_summary    115
    ## 3                  eu    109

On top of the list we also find Afghanistan, which might have entered the daily news just recently. Let's confirm this statement with our data and print keywords over time.

## Keywords over time

*work in progress*
