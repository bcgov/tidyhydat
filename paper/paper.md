# tidyhydat: Extract and Tidy Canadian Hydrometric Data
`r Sys.Date()`  

> "Tidy datasets are all alike but every messy dataset is messy in its own way - "
@wickham2014tidy





# Introduction
Environment and Climate Change Canada (ECCC) through the Water Survey of Canada (WSC) maintains several national hydrometric data sources. These data are partially funded by provincial partners and constitute the main data product of a national integrated hydrometric network. Historical data are stored in the [HYDAT database](http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/). Real-time data are provided by ECCC through two sources: a web service and a datamart. The web service is a login only service which is faster and contains more data that the datamart. Files are updated to the datamart on an hourly basis though the lag between actual hydrometric measurement and the available of hydrometric data is more like 2.5 hours. The [datamart](http://dd.weather.gc.ca/hydrometric/) which is an open data source and is organized in a directory tree structure by province. The objective of this document is the outline the usage of `tidyhydat`, an R package that extract ECCC hydrometric data and makes it *tidy*.  The primary goal of `tidyhydat` is to provide a common API and data structure for ECCC data sources using a consistent and easy to use interface that employs tidy data principles developed by @wickham2014tidy within the R project [@RCore]. 

## Why use R in hydrology?
There are many statistical computing projects that offer great functionality for users. For `tidyhydat` we have chosen to use R. R is a mature open-source project that provides significant potential for advanced modelling, visualization and data manipulation. There are several commonly cited reasons to use R:

- R is and always will be free to use and modify
- R is flexible and can be easily adapted to a wide range of problems
- R is well established and well used.
- R has a friendly community which is an important infrastructure element of any open source project. 

There have been recent calls to use R more broadly in the field of hydrology [@moore2017watershed]. The `tidyhydat` package is an effort to push this call forward by being a standard package by which hydrologists and other users interact with WSC data in R. 

## What is tidy data?
Embedded within `tidyhydat` is the principle of *tidy data*. @wickham2014tidy defines tidy data by three principles:

- Each variable variable forms a column
- Each observation forms a row
- Each type of observational unit forms a table

It is illustrative here to provide an example of the types of data *tidying* processes that `tidyhydat` does for you automatically. The `DLY_FLOWS` table in the HYDAT database returns data that looks like this:

```
## # Source:   table<DLY_FLOWS> [?? x 73]
## # Database: sqlite 3.19.3
## #   [C:\Users\salbers\R\win-library\3.4\tidyhydat\test_db\tinyhydat.sqlite3]
##    STATION_NUMBER  YEAR MONTH FULL_MONTH NO_DAYS MONTHLY_MEAN
##             <chr> <int> <int>      <int>   <int>        <dbl>
##  1        05AA008  1910     7          0      31           NA
##  2        05AA008  1910     8          1      31         3.08
##  3        05AA008  1910     9          1      30         3.18
##  4        05AA008  1910    10          1      31         5.95
##  5        05AA008  1911     1          1      31         1.42
##  6        05AA008  1911     2          1      28         1.31
##  7        05AA008  1911     3          1      31         1.65
##  8        05AA008  1911     4          1      30         6.33
##  9        05AA008  1911     5          1      31        18.20
## 10        05AA008  1911     6          1      30        24.20
## # ... with more rows, and 67 more variables: MONTHLY_TOTAL <dbl>,
## #   FIRST_DAY_MIN <int>, MIN <dbl>, FIRST_DAY_MAX <int>, MAX <dbl>,
## #   FLOW1 <dbl>, FLOW_SYMBOL1 <chr>, FLOW2 <dbl>, FLOW_SYMBOL2 <chr>,
## #   FLOW3 <dbl>, FLOW_SYMBOL3 <chr>, FLOW4 <dbl>, FLOW_SYMBOL4 <chr>,
## #   FLOW5 <dbl>, FLOW_SYMBOL5 <chr>, FLOW6 <dbl>, FLOW_SYMBOL6 <chr>,
## #   FLOW7 <dbl>, FLOW_SYMBOL7 <chr>, FLOW8 <dbl>, FLOW_SYMBOL8 <chr>,
## #   FLOW9 <dbl>, FLOW_SYMBOL9 <chr>, FLOW10 <dbl>, FLOW_SYMBOL10 <chr>,
## #   FLOW11 <dbl>, FLOW_SYMBOL11 <chr>, FLOW12 <dbl>, FLOW_SYMBOL12 <chr>,
## #   FLOW13 <dbl>, FLOW_SYMBOL13 <chr>, FLOW14 <dbl>, FLOW_SYMBOL14 <chr>,
## #   FLOW15 <dbl>, FLOW_SYMBOL15 <chr>, FLOW16 <dbl>, FLOW_SYMBOL16 <chr>,
## #   FLOW17 <dbl>, FLOW_SYMBOL17 <chr>, FLOW18 <dbl>, FLOW_SYMBOL18 <chr>,
## #   FLOW19 <dbl>, FLOW_SYMBOL19 <chr>, FLOW20 <dbl>, FLOW_SYMBOL20 <chr>,
## #   FLOW21 <dbl>, FLOW_SYMBOL21 <chr>, FLOW22 <dbl>, FLOW_SYMBOL22 <chr>,
## #   FLOW23 <dbl>, FLOW_SYMBOL23 <chr>, FLOW24 <dbl>, FLOW_SYMBOL24 <chr>,
## #   FLOW25 <dbl>, FLOW_SYMBOL25 <chr>, FLOW26 <dbl>, FLOW_SYMBOL26 <chr>,
## #   FLOW27 <dbl>, FLOW_SYMBOL27 <chr>, FLOW28 <dbl>, FLOW_SYMBOL28 <chr>,
## #   FLOW29 <dbl>, FLOW_SYMBOL29 <chr>, FLOW30 <dbl>, FLOW_SYMBOL30 <chr>,
## #   FLOW31 <dbl>, FLOW_SYMBOL31 <chr>
```

This data structure clearly violates the principles of tidy data - this is messy data. For example, column header (e.g. `FLOW1`) contains the day number - a value. HYDAT is structured like this for very reasonable historical reasons. It does, however, significantly limit a hydrologists ability to efficiently extract hydrometric data. For example, given the current data structure, it is not possible to only extract from the 15th of one month to the 15th of the next. Rather a query would need to be made on all data from the relevant months and then further processing would need to occur.

`tidyhydat` aims to make this process simpler. If we want the same data as the example above, we can use the `DLY_FLOWS()` function to query the same data in HYDAT but return a much tidier data structure. It is now very simple to extract data between say March 15, 1992 and April 15, 1992. We just need to supply these arguments to `DLY_FLOWS()` after loading the package itself:


```r
library(tidyhydat)
DLY_FLOWS(hydat_path = "H:/Hydat.sqlite3",
          STATION_NUMBER = "08MF005",
          start_date = "1992-03-15",
          end_date = "1992-04-15")
```

```
## # A tibble: 32 x 5
##    STATION_NUMBER       Date Parameter Value Symbol
##             <chr>     <date>     <chr> <dbl>  <chr>
##  1        08MF005 1992-03-15      FLOW  1630   <NA>
##  2        08MF005 1992-03-16      FLOW  1730   <NA>
##  3        08MF005 1992-03-17      FLOW  1900   <NA>
##  4        08MF005 1992-03-18      FLOW  2040   <NA>
##  5        08MF005 1992-03-19      FLOW  2140   <NA>
##  6        08MF005 1992-03-20      FLOW  2180   <NA>
##  7        08MF005 1992-03-21      FLOW  2170   <NA>
##  8        08MF005 1992-03-22      FLOW  2150   <NA>
##  9        08MF005 1992-03-23      FLOW  2130   <NA>
## 10        08MF005 1992-03-24      FLOW  2120   <NA>
## # ... with 22 more rows
```

As you can see, this is much tidier data and is much easier to work with. In addition to these tidy principles, specific to `tidyhydat` we can also define that *for a common data structure, variables should be referred to by a common name*. For example, hydrometric stations are given a unique 7 digit identifier that contains important watershed information. This identifier is variously referred to as `STATION_NUMBER` or `ID` depending on the ECCC data source. To tidy this hydrometric data, we have renamed where necessary each instance of the unique identifier as `STATION_NUMBER`. This consistency to data formats, and in particular tidy data, situates `tidyhydat` well to interact seemlessly with the powerful tools being developed as the `tidyverse` [@wickham2017tidyverse].

# References