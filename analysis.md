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
library(tidyr)

# Load data
date_of_data_to_load <- "2021-08-30"
load(file = paste0("data/", "news_", date_of_data_to_load, ".Rdata"))
```

# Analysis

The data collected from the webpage go from 2017-08-31 to 2021-08-30.

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
  count(Format,
        Wochentag = wday(Datum, locale = "German", label = TRUE),
        name = "Anzahl") %>% 
  ggplot(aes(x = Wochentag, y = Anzahl, fill = Format)) +
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
    ## 12       Peter Weitzmann
    ## 13      SR 2 Kulturradio
    ## 14      SR 2 KulturRadio
    ## 15         Stefan Deppen
    ## 16        Stephan Deppen
    ## 17       Stephan Deppenh
    ## 18        Thomas Shihabi
    ## 19        Thomas SHihabi
    ## 20 Thomas Shihabi et al.
    ## 21     Yvonne Scheinhege
    ## 22    Yvonne Schleinhege

Let's head on to analyse the content and check which news appear within the daily news blocks.

## Keywords by number of appearence

First, we load a dictionary with german stop-words so then we can delete unnecessary words of the news messages.

``` r
# Load dictionary
stop_words_german <-
  data.frame("Wort" = stopwords::stopwords("de", source = "snowball"))
news_clean_unnested <- news_clean %>%
  unnest_tokens(output = "Wort", input = Themen) %>% 
  anti_join(stop_words_german, by = "Wort")
```

Now, let's print the top keywords by number of appearance.

``` r
# Keyword frecuency
top_n_keywords <- 30
news_clean_unnested %>% 
  count(Wort, name = "Anzahl", sort = TRUE) %>% 
  head(top_n_keywords)
```

    ##           Wort Anzahl
    ## 1       corona    256
    ## 2           eu    108
    ## 3         lage     81
    ## 4     saarland     78
    ## 5         neue     53
    ## 6    interview     52
    ## 7   reaktionen     49
    ## 8  afghanistan     46
    ## 9    bundestag     46
    ## 10    lockdown     41
    ## 11     debatte     38
    ## 12        mehr     36
    ## 13 deutschland     35
    ## 14         usa     35
    ## 15   kommentar     34
    ## 16       china     32
    ## 17       jahre     31
    ## 18       trump     31
    ## 19          us     30
    ## 20    aktuelle     28
    ## 21       spahn     28
    ## 22        wahl     28
    ## 23       woche     28
    ## 24        bund     27
    ## 25          ab     26
    ## 26  diskussion     26
    ## 27       biden     25
    ## 28   impfstoff     25
    ## 29  frankreich     24
    ## 30      länder     24

We see, Corona clearly dominated the news and also EU related topics were discussed. Since SR2 is a regional broadcasting station, we also observe the keyword Saarland. If we sum up all US related keywords that show up (Biden, Trump, USA, US) we notice it is another dominant topic, yet before news about the EU.

``` r
# Frecuency US related words
news_clean_unnested %>% 
  mutate(Wort = ifelse(Wort %in% c("biden", "trump", "usa", "us"),
                       "US_keywords_summary", Wort)) %>% 
  count(Wort, name = "Anzahl", sort = TRUE) %>% 
  head(3)
```

    ##                  Wort Anzahl
    ## 1              corona    256
    ## 2 US_keywords_summary    121
    ## 3                  eu    108

On top of the list we also find Afghanistan, which might have entered the daily news just recently. Let's confirm this statement with the data and print keywords over time.

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

![](analysis_files/figure-markdown_github/keywords%20over%20time-1.png)

Indeed, we see that Afghanistan and its capital Kabul were almost not present in the news till early 2021 and then increased heavily from July 2021. While the discourse about Corona is slowly decreasing, although still present, we see that the word lockdown had a boom in December 2020 and suddenly disappeard after April 2021. Shall we assume there was an internal SR2-guideline that prohibited using that word or may the reason be that since May 2021 lockdown measures were removed step by step?

*work in progress*
