# SR2 News Mining
_Analysing news broadcasted by German radio station SR2_

Topics are set and public opinion is framed by broadcasting stations. This project wants to analyze the daily news broadcasted by German radio station SR2. The guiding idea of this analysis is to see how many times a certain news-message is transmitted and how the main news-themes develop over time.

## Source
The data should be gathered from officially accessible documents, in order not to directly depend on the willingness of somebody to provide information. In this case, the data are scraped from the SR2 web page; precisely from the two main news formats the channel transmits (Bilanz am Mittag and Bilanz am Abend).

## Structure
Data are first scraped with R/get_data.R, then saved as a .csv or .Rdata file. Data exploration and visualizations are created within analysis.md (generated from within RStudio by analysis.Rmd).

## Software
- R (version 3.6.2)
- RStudio (version 1.1.423)
- Running under Windows >= 8 (x64)
- Packages: stopwords_2.1, tidytext_0.3.1, knitr_1.30, tibble_3.1.1, stringr_1.4.0, dplyr_1.0.6, httr_1.4.2,
rvest_1.0.1, lubridate_1.7.10, ggplot2_3.3.3

No need to say that most web scraping projects of these times have been inspired by David Kriesel's amazing Spiegel Mining project (www.dkriesel.com/spiegelmining).
