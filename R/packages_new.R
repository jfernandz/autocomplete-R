options(warn=-1)

scrapPath<-path.expand("~/.atom/packages/autocomplete-R/R/")

setwd(scrapPath)

source("static_help.R")
source("scrapeRdoc.R")

load(".RData")

# https://www.r-bloggers.com/list-of-user-installed-r-packages-and-their-versions/
ip <- as.data.frame(installed.packages()[,c(1,3:4)])
rownames(ip) <- NULL
ip <- ip[!duplicated(ip$Package),]

new_pkg <- as.character(ip$Package[!(ip$Package %in% pkg)])

newpackages <- list()
badpkgs <- integer()

i <- 1
n <- length(new_pkg)

while (i <= n){
  temp <- try(scrapeRdoc(pkg=new_pkg[i]),silent = TRUE)
  if (class(temp) == "try-error"){
    badpkgs <- c(badpkgs,i)
    i <- i + 1
  } else {
    newpackages[[i]] <- temp
    i <- i + 1
  }
}

newpackages <- unlist(newpackages, recursive = FALSE)

names(newpackages)<- lapply(newpackages,function(x) x$text)

allpackages <- c(allpackages,newpackages)

cat(toJSON(list('keywords'=allpackages),auto_unbox=TRUE),
  file='../completions.json')

pkg <- unique(c(pkg, newpackages))
pkg <- pkg[-badpkgs]

save(pkg,allpackages,file = ".RData")
