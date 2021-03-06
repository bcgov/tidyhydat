% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hy_plot.R
\name{hy_plot}
\alias{hy_plot}
\title{This function is deprecated in favour of generic plot methods}
\usage{
hy_plot(
  station_number = NULL,
  Parameter = c("Flow", "Level", "Suscon", "Load")
)
}
\arguments{
\item{station_number}{A (or several) seven digit Water Survey of Canada station number.}

\item{Parameter}{Parameter of interest. Either "Flow" or "Level".}
}
\description{
This is an easy way to visualize a single station using base R graphics.
More complicated plotting needs should consider using \code{ggplot2}. Inputting more
5 stations will result in very busy plots and longer load time. Legend position will
sometimes overlap plotted points.
}
