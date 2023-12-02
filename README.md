# SR2 News Mining
_Analysing news broadcasted by German radio station SR2_

Topics are set and public opinion is framed by broadcasting stations. This project wants to analyze the daily news broadcasted by German radio station SR2. The guiding idea of this analysis is to see how many times a certain news-message is transmitted and how the main news-themes develop over time.

## About SR2
SR2 Kulturradio is the cultural channel of Saarländischer Rundfunk, a regional state-owned broadcasting station. It aims to provide a diverse program, including background content information on politics and world affairs.

## Source
The data should be gathered from officially accessible documents, in order not to directly depend on the willingness of somebody to provide information. In this case, the data are scraped from the SR2 web page. As the webpage lacks for information about the hourly news blocks, the project focuses on the two main news formats (Bilanz am Mittag and Bilanz am Abend).

## Structure
Data are first scraped with R/get_data.R, then saved as a .csv or .Rdata file. Data exploration and visualizations are created within analysis.md (generated from within RStudio by analysis.Rmd).

## Perspective and Contribution
This project can be a tool for anyone who wants to start analyzing news formats. It could be extended for comparison with other cultural channels and examine differences between them. The analysis could also be extended sharpening the insights obtained about SR2. There is a lot of potential and it is currently a work in progress. As I create it, the code here is updated. This openness also allows users to contribute or to use it as a starting point for their own analysis if they wish.

*NB: This project was a work in progress from September 2020 until December 2023. Moving forward, I won't be sending regular updates. However, I am considering to use this experience to extend it to another media website, driving it towards a more professional level and maybe a broader audience. More to come...*

## Software
- R (version 4.2.2)
- RStudio (version 2023.09.1)
- Running under Windows 10 (x64)
- Packages: wordcloud_2.6, RColorBrewer_1.1-3, lubridate_1.9.2, forcats_1.0.0, stringr_1.5.0, dplyr_1.1.1, purrr_1.0.1, readr_2.1.4, tidyr_1.3.0, tibble_3.2.1, ggplot2_3.4.2, tidyverse_2.0.0, tidytext_0.3.3, knitr_1.45, stopwords_2.3, httr_1.4.5, xml2_1.3.3, rvest_1.0.3

No need to say that most web scraping projects of these times have been inspired by David Kriesel's amazing Spiegel Mining project (www.dkriesel.com/spiegelmining).
