options(warn=-1)

pkg <- .packages()

source("static_help.R")
source("scrapeRdoc.R")

allpackages <- list()

i <- 1
n <- length(pkg)

while (i <= n){
  allpackages[[i]] <- scrapeRdoc(pkg=pkg[i])
  i <- i + 1
}

allpackages <- unlist(allpackages, recursive = FALSE)

names(allpackages)<- lapply(allpackages,function(x) x$text)


cat(toJSON(list('keywords'=allpackages),auto_unbox=TRUE),
  file='../completions.json')

save(allpackages,pkg,file = ".RData")
