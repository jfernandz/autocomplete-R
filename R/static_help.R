# Install packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(jsonlite, pryr, rvest, magrittr, XML)

# https://yihui.name/en/2012/10/build-static-html-help/
static_help = function(pkg, links = tools::findHTMLlinks()) {
  pkgRdDB = tools:::fetchRdDB(file.path(find.package(pkg), 'help', pkg))
  force(links); topics = names(pkgRdDB)
  n <- length(topics)
  # str(topics)
  i <- 1
  doc <- list()
  while(i <= n) {
    doc[[i]] <- htmlParse(paste0(capture.output(
      tools::Rd2HTML(pkgRdDB[[topics[i]]],
      package = pkg, Links = links, no_links = is.null(links))), collapse = ""))
      i <- i + 1
  }
  names(doc) <- topics
  doc
}
