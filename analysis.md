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
library(stringr)
library(purrr)

# Load data
folder <- "data"
files <- list.files(folder, pattern = ".Rdata", full.names = TRUE)

loaded_data <- vector("list")
for (file in files) {
  load(file)
  loaded_data[[file]] <- news  # Assuming the data frames are named "news"
}

news_raw <- map2(loaded_data, names(loaded_data), ~mutate(.x, source_file = .y)) %>% 
  map(bind_rows) %>%
  list_rbind()
```

# Analysis

The data collected from the webpage goes from 2017-08-31 to 2023-11-07.

If we have a closer look on the URLs, we can see that every article has
an identification number associated which comes after the `id=`
parameter and at a similar position for each URL.

``` r
news <- news_raw %>% 
  mutate(id = str_replace(Links, ".+id=(\\d+).*", "\\1"))
news %>% select(id, Links) %>% head(3) %>% kable()
```

| id    | Links                                                                               |
|:------|:------------------------------------------------------------------------------------|
| 22060 | <https://dev2.sr-mediathek.sr-multimedia.de/index.php?seite=7&id=22060&pnr=&tbl=pf> |
| 22045 | <https://dev2.sr-mediathek.sr-multimedia.de/index.php?seite=7&id=22045&pnr=&tbl=pf> |
| 22030 | <https://dev2.sr-mediathek.sr-multimedia.de/index.php?seite=7&id=22030&pnr=&tbl=pf> |

By clicking on a link, we also note, that many pages have gone offline
already. Because we have scraped the page over time, we can now observe
that a few articles have modified their news message afterwards.
However, these were only minor changes.

``` r
news %>%
  left_join(news, join_by(id), suffix = c("_Version_A", "_Version_B")) %>%
  filter(Themen_Version_A != Themen_Version_B) %>% 
  select(id, starts_with("Themen")) %>% 
  distinct(id, .keep_all = TRUE) %>% 
  kable()
news_distinct <- news %>% distinct(id, .keep_all = TRUE)
```

| id    | Themen_Version_A                                                                                                                                                                                                           | Themen_Version_B                                                                                                                                                                                                             |
|:------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 22060 | “Planer” der IS-Miliz in Afghanistan im Visier - USA fliegen Drohnenangriff / Trotz Terrorwarnung - Tausende Menschen versuchen Kabul zu verlassen und das Interview der Woche mit Jens Spahn, Bundesgesundheitsminister   | “Planer” der IS-Miliz in Afghanistan im Visier - USA fliegen Drohnenangriff / Trotz Terrorwarnung - Tausende Menschen versuchen Kabul zu verlassen / Interview der Woche mit Jens Spahn, Bundesgesundheitsminister (CDU)     |
| 22080 | Gewagtes Schutzversprechen - Bisher nur 138 deutsche Ortskräfte ausgeflogen / Nach britischem Abzug - Kritik an Regierung Johnson / Die Preise steigen - wirklich nur vorübergehend? - Hohe Inflationsrate befürchtet      | Gewagtes Schutzversprechen - Bisher nur 138 deutsche Ortskräfte ausgeflogen / Nach britischem Abzug - Kritik an Regierung Johnson / Die Preise steigen - wirklich nur vorübergehend? Hohe Inflationsrate befürchtet          |
| 22586 | Kommentar zum Ende der Sondierungsgespräche / Ab heute Kita-Lockerungen: Fluch und Segen / Pandora Papers: Warum funktionieren Briefkastenfirmen trotz Regulierung? / EU-Parlament verurteilt Belarus / Abholzung in Kongo | Kommentar zum Ende der Sondierungsgespräche / Ab heute Kita-Lockerungen - Fluch und Segen / Pandora Papers - Warum funktionieren Briefkastenfirmen trotz Regulierung? / EU-Parlament verurteilt Belarus / Abholzung in Kongo |

Let’s examine the time frame covered by the articles.

``` r
# Articles by month
news_distinct %>%
  count(Monat = floor_date(Datum, "month"),
        name = "Artikelanzahl") %>%
  ggplot(aes(x = Monat, y = Artikelanzahl)) +
  geom_col() +
  scale_x_date(date_breaks = "3 months") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
```

![](analysis_files/figure-gfm/articles%20by%20month-1.png)<!-- -->

Apparently our data shows two time periods that are uncovered. The first
is before August 2020. Unfortunately, SR2 seems to have deleted their
data or they simply did not upload their editions consequently before
that date. Therefore, to not bias our analysis, the 50 articles from
before August 2020 are deleted (listwise deletion, since these are just
a few cases). Moreover, we identify a significant gap in information
between February and November 2022. You see, behind this code there is a
human and humans aren’t robots. Sometimes life throws in its own
surprises and a unique blend of personal events turned me into something
of a “human in vacation mode.” But I’m back in action now!😊

``` r
# Listwise deletion
news_clean <- news_distinct %>% filter(Datum >= "2020-08-01")
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

    #>                                  Autor
    #> 1                        Böffel, Janek
    #> 2                        Florian Mayer
    #> 3                        Folrian Mayer
    #> 4                        Frank Hofmann
    #> 5                   Gallmeyer, Kerstin
    #> 6                       Isabel Tentrup
    #> 7                     Isabell Tentrupp
    #> 8                     Isabelle Tentrup
    #> 9                    Isabelle Tentrupp
    #> 10                        Janek Böffel
    #> 11                       Jochem Marmit
    #> 12                       Jochen Marmit
    #> 13                         Karin Mayer
    #> 14                         Kathrin Aue
    #> 15                          Katrin Aue
    #> 16            Katrin Aue, Janek Böffel
    #> 17 Katrin AueFrankreich streikt weiter
    #> 18                   Kerstin Gallmeyer
    #> 19                        Lisa Krauser
    #> 20                      Mayer, Florian
    #> 21                     Michael Thieser
    #> 22                     Peter Weitzmann
    #> 23                    SR 2 KulturRadio
    #> 24                    SR 2 Kulturradio
    #> 25                        Sarah Sassou
    #> 26                      Staphan Deppen
    #> 27                       Stefan Deppen
    #> 28                      Stephan Deppen
    #> 29                     Stephan Deppenh
    #> 30                      Thomas SHihabi
    #> 31                      Thomas Shihabi
    #> 32               Thomas Shihabi et al.
    #> 33                   Yvonne Scheinhege
    #> 34                  Yvonne Schleinhege
    #> 35           Yvonne Schleinhege-Böffel
    #> 36                    Îsabelle Tentrup

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

    #>           Wort Anzahl
    #> 1       corona    384
    #> 2           eu    256
    #> 3         lage    193
    #> 4     saarland    176
    #> 5    bundestag    123
    #> 6    interview    122
    #> 7      ukraine    110
    #> 8         neue    108
    #> 9        china     99
    #> 10  reaktionen     97
    #> 11 deutschland     96
    #> 12       woche     87
    #> 13     debatte     83
    #> 14   kommentar     82
    #> 15        mehr     80
    #> 16      israel     75
    #> 17 afghanistan     74
    #> 18  frankreich     74
    #> 19       jahre     73
    #> 20         usa     73
    #> 21          us     71
    #> 22        wahl     71
    #> 23      gipfel     68
    #> 24      berlin     67
    #> 25         cdu     65
    #> 26    russland     63
    #> 27        geht     62
    #> 28     treffen     61
    #> 29         afd     58
    #> 30    aktuelle     58

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

    #>                  Wort Anzahl
    #> 1              corona    384
    #> 2 US_keywords_summary    259
    #> 3                  eu    256

On top of the list we also find Afghanistan, which might have entered
the daily news just recently. Let’s confirm this statement with the data
and print keywords over time.

## Keywords over time

``` r
# Select keywords
keywords <- c("lockdown", "corona", "afghanistan", "kabul", "ukraine", "russland", "gaza", "israel", "china", "türkei", "italien", "usa", "selenskyj")

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
  facet_wrap(~Wort) +
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
