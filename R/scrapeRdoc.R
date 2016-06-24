library(jsonlite)
scapeRdoc<-function(package="base",website="http://stat.ethz.ch/R-manual/R-patched/library/"){
	require(pryr)
	require(rvest)
	require(magrittr)
	montest<-read_html(paste0(website,package,'/html/00Index.html'))
	myscrap<-montest %>% html_nodes("table a") %>% html_attr(name = "href")
	myscraptext<-montest %>% html_nodes("table a") %>% html_text()

	myscrap<-myscrap[2:length(myscrap)]
	myscrap<-myscrap[grepl('^[a-zA-Z]',myscraptext)]
	myscrap<-unique(myscrap)
	scrapeRoutine<-function(addr,x) {
		if(!is.na(x)){

			core = read_html(paste0(addr,x))

			if(length(core %>% html_nodes('pre')%>% html_text())!=0 && any(core %>% html_nodes('h3') %>% html_text()=='Usage') && grepl(pattern='\\(', core %>% html_node('pre') %>% html_text())) {
				Text= strsplit(core %>% html_node('title')%>% html_text(),split=":")[[1]][2]
				rightLabel = core %>% html_node('h2')%>% html_text()
				Snippet = core %>% html_node('pre')%>% html_text()
				SnippetDisp = gsub("\\##(.*?)\\n","",Snippet)
				Snippet = gsub("\\##(.*?)\\n","",Snippet)


				#SnippetDisp = strsplit(SnippetDisp,'(\\)\n|\\), \n)',perl=TRUE)[[1]]
				SnippetDisp = strsplit(SnippetDisp,'\n\n')[[1]]
				SnippetDisp<-lapply(SnippetDisp,function(x){
					out<-strsplit(x,'(\\)\n)',perl=TRUE)[[1]]
					out<-paste0(out,')')
					return(out)
				})
				SnippetDisp<-unlist(SnippetDisp)
				SnippetDisp = gsub('\\n','',SnippetDisp)
				SnippetDisp = gsub('  ','',SnippetDisp)
				SnippetDisp = gsub('\\)\\)$',')',SnippetDisp,perl=TRUE)

				SnippetDisp = SnippetDisp[grepl("\\(",SnippetDisp)]
				SnippetDisp = SnippetDisp[!grepl("<-",SnippetDisp)]
				#SnippetDisp = SnippetDisp[!grepl(" \\- ",SnippetDisp)]

				#SnippetDisp = SnippetDisp[!grepl(" \\+ ",SnippetDisp)]

				SnippetDisp = SnippetDisp[!grepl("TRUEFALSE",SnippetDisp)]
				#SnippetDisp = SnippetDisp[!grepl("$",SnippetDisp)]

				# #SnippetDisp = strsplit(SnippetDisp,'(\\), \n)',perl=TRUE)[[1]]
				#
				# SnippetDisp = toString(lapply(SnippetDisp,function(x) {
				#  paste0(x,')')
				# }))
				# SnippetDisp = gsub('\\n','',SnippetDisp)
				# SnippetDisp = gsub('  ','',SnippetDisp)



				SnippetList<-vector("character",length=length(SnippetDisp))
				prefix<-vector("character",length=length(SnippetDisp))
				type<-vector("character",length=length(SnippetDisp))

				for(i in 1:length(SnippetDisp)) {
					part1<-regmatches(SnippetDisp[i],regexpr("(?)(\\(.*)",SnippetDisp[i]),invert=TRUE)[[1]][1]
					prefix[i]<-part1
					type[i]<-ftype(substitute(part1))
					part2<-regmatches(SnippetDisp[i],regexpr("(?)(\\(.*)",SnippetDisp[i]))
					part2a<-unlist(regmatches(part2,regexpr("(?)(\\,.*)",part2),invert=TRUE))[1]
					# part2a1<-regmatches(part2a,regexpr("\\(",part2a),invert=TRUE)[[1]][2]
					part2a<-paste0(gsub('\\(','\\(${1:',part2a),'}')
					if(length(part2)>0&&grepl("\\,", part2)==TRUE){
						part2b<-regmatches(part2,regexpr("(?)(\\,.*)",part2))
						part2b<-sub('^\\, ','\\, ${2:',part2b)
						s2<-gsub('\\)','',part2b,)
						occur<-nchar(part2b) - nchar(s2)
						if(occur%%2==0){
							part2b<-gsub('\\)$','\\)\\}\\)',part2b)
						} else {
							part2b<-gsub('\\)$','\\}\\)',part2b)
						}
						SnippetList[i]<-paste0(part1,part2a,part2b)
					} else {
						SnippetList[i]<-paste0(part1,sub('\\)\\}','}\\)',part2a))
					}
				}
				# paste0(part1,part2a,part2b)
				functionname<-part1
				Description= gsub('\n',' ',core %>% html_node('h3+p')%>% html_text())
				Description = gsub('  ',' ',Description)
				DescriptionMoreURL= paste0(addr,x)
				list('text'=functionname,'snippet'=SnippetList,'prefix'=prefix,'type'=type,'displayText'=SnippetDisp,'description'=Description,'leftLabel'=package,'rightLabel'=rightLabel,'descriptionMoreURL'= DescriptionMoreURL)
				}

		}
	}
	myscraplist<-lapply(myscrap,scrapeRoutine,addr=paste0(website,package,'/html/'))
	myscraplist<-myscraplist[unlist(lapply(myscraplist,function(x) !is.null(x)))]
	names(myscraplist)<-lapply(myscraplist,function(x) x$text)
	return(myscraplist)

}
basej<-scapeRdoc('base')
statsj<-scapeRdoc('stats')
toolsj<-scapeRdoc('tools')
utilsj<-scapeRdoc('utils')
methodsj<-scapeRdoc('methods') # error
graphicsj<-scapeRdoc('graphics')
cat(toJSON(list('keywords'=c(basej,statsj,toolsj,utilsj,methodsj)),auto_unbox=TRUE),file='completions.json')
