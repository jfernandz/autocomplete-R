# an attempt to create a CSON file

toCSON<-function(x,method="R"){
	if (is.factor(x) == TRUE) {
        tmp_names <- names(x)
        x = as.character(x)
        names(x) <- tmp_names
  }
  if (!is.vector(x) && !is.null(x) && !is.list(x)) {
      x <- as.list(x)
      warning("JSON only supports vectors and lists - But I'll try anyways")
  }
  if (is.null(x))
      return("null")
  if (is.null(names(x)) == FALSE) {
      x <- as.list(x)
  }
	tabul=rep("\t")
  if (is.list(x) && !is.null(names(x))) {
      if (any(duplicated(names(x))))
          stop("A JSON list must have unique names")
      str = ""
      first_elem = TRUE

      for (n in names(x)) {
          if (first_elem)
              first_elem = FALSE
          else {
						str = paste(str,'\n'  , sep = "")

					}
					#tabul<-paste0(tabul,'\t')
          str = paste(str, deparse(n), ": ",  toCSON(x[[n]],
              "R"), sep = "")
      }
      str = paste(str, "", sep = "")

      return(str)
  }
  if (length(x) != 1 || is.list(x)) {
      if (!is.null(names(x)))
        return(toCSON(as.list(x), "R"))
      str = "["
      first_elem = TRUE
			#tabul<-paste0(tabul,'\t')
      for (val in x) {
          if (first_elem) {
						first_elem = FALSE
						#tabul<-paste0(tabul,'\t')
					}
          else str = paste(str, "\n\t",tabul, sep = "")
          str = paste(str, tabul ,toCSON(val, "R"), sep = "")
      }
      str = paste(str, "]", sep = "")

      return(str)
  }
  if (is.nan(x))
    return("\"NaN\"")
  if (is.na(x))
      return("\"NA\"")
  if (is.infinite(x))
      return(ifelse(x == Inf, "\"Inf\"", "\"-Inf\""))
  if (is.logical(x))
      return(ifelse(x, "true", "false"))
  if (is.character(x))
      return(deparse(x))
  if (is.numeric(x))
      return(as.character(x))
  stop("shouldnt make it here - unhandled type not caught")
}
