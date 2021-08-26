SR2 News Mining
================

<!-- analysis.md is generated from analysis.Rmd -->
# Introduction

Topics are set and public opinion is framed by broadcasting stations. This project wants to analyze the daily news broadcasted by German radio station SR2.

# Analysis

## Part 1

Which news appear within the daily news blocks?

### Keywords by number of appearence

Let's have a look on the keywords. First, we load a dictionary with german stop-words in order to be able to delete unnecessary words of the news messages.

``` r
# Load dictionary
stop_words_german <-
  data.frame("Wort" = stopwords::stopwords("de", source = "snowball"))
```

Now, let's print the top 30 keywords by number of appearance.

``` r
# Analysis
## Keyword frecuency
news %>%
  unnest_tokens(output = "Wort", input = Themen) %>% 
  anti_join(stop_words_german, by = "Wort") %>% 
  count(Wort, name = "Anzahl", sort = TRUE) %>% 
  head(30)
```

    ##           Wort Anzahl
    ## 1       corona    258
    ## 2           eu    110
    ## 3         lage     74
    ## 4     saarland     73
    ## 5    interview     53
    ## 6   reaktionen     49
    ## 7         neue     48
    ## 8    bundestag     43
    ## 9     lockdown     41
    ## 10 afghanistan     40
    ## 11     debatte     37
    ## 12   kommentar     34
    ## 13         usa     34
    ## 14        mehr     33
    ## 15 deutschland     32
    ## 16       jahre     32
    ## 17       trump     32
    ## 18       china     29
    ## 19          us     29
    ## 20       spahn     27
    ## 21       woche     27
    ## 22        bund     26
    ## 23        wahl     26
    ## 24          ab     25
    ## 25       biden     25
    ## 26      merkel     25
    ## 27  diskussion     24
    ## 28    aktuelle     23
    ## 29      berlin     23
    ## 30  frankreich     23

We see, Corona clearly dominated the news and also EU related topics were discussed. Since SR2 is a regional broadcasting station, we also observe the keyword Saarland. If we sum up all US related keywords (Biden, Trump, USA, US) we notice it seems to be another dominant topic yet before topics regarding the EU.

``` r
# Analysis
## Keyword frecuency US related
news %>%
  unnest_tokens(output = "Wort", input = Themen) %>% 
  anti_join(stop_words_german, by = "Wort") %>% 
  mutate(Wort = ifelse(Wort %in% c("biden", "trump", 
                                   "usa", "us"),
                "US_keyword", Wort)) %>% 
  count(Wort, name = "Anzahl", sort = TRUE) %>% 
  head(3)
```

    ##         Wort Anzahl
    ## 1     corona    258
    ## 2 US_keyword    120
    ## 3         eu    110

At the end of the top ten we see Afghanistan, which might have entered the daily news just recently. Let's confirm this statement with our data and print keywords over time.

### Keywords over time

*work in progress*
