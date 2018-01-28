# Extract inf
library(jsonlite)
library(pryr)
library(rvest)
library(magrittr)
library(XML)

scrapeRdoc<-function(pkg="base"){
  # static_help
  doc <- static_help(pkg = pkg)
  mylonglist <- list()
  n <- length(doc)
  i <- 3
  while (i <= n) {
    fun <- doc[[i]]
    # Title
    rightLabel <- xpathSApply(fun, path = "//title", fun = xmlValue)
    # Description
    description <- xpathSApply(fun,
      path = "//h3[.='Description']/following-sibling::p[1]", xmlValue)
    # description <- paste0(trimws(gsub("\n"," ",description)), collapse = " ")
    # leftLabel
    leftLabel <- pkg
    # Nome da função
    text <- prefix <- names(doc[i])
    # Type
    type <- ftype(names(doc)[i])
    # Snippet
    snippet <- xpathSApply(fun,
       path = "//h3[.='Usage']/following-sibling::pre[1]/text()", xmlValue)
    # snippet <- trimws(gsub("\n", " ", snippet))
    cat(paste0(pkg,": ",names(doc[i])), sep = "\n")
    mylonglist[[i]] <- list(text = text, snippet = snippet, prefix = prefix,
       type = type, description = description, leftLabel = leftLabel,
       rightLabel = rightLabel)
    i <- i + 1
  }
  mylonglist
}
