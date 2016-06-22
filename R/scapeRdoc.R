library(jsonlite)
scapeRdoc<-function(package="base",website="http://stat.ethz.ch/R-manual/R-patched/library/"){
	require(rvest)
	require(magrittr)
	montest<-read_html(paste0(website,package,'/html/00Index.html'))
	myscrap<-montest %>% html_nodes("table a") %>% html_attr(name = "href")
	myscraptext<-montest %>% html_nodes("table a") %>% html_text()


	myscrap<-myscrap[2:length(myscrap)]
	myscrap<-myscrap[grepl('^[a-zA-Z]',myscraptext)]
	myscrap<-unique(myscrap)
	scrapeRoutine<-function(addr,x) {
		core = read_html(paste0(addr,x))

		if(length(core %>% html_nodes('pre')%>% html_text())!=0 && any(core %>% html_nodes('h3') %>% html_text()=='Usage') && grepl(pattern='\\(', core %>% html_node('pre') %>% html_text())) {
			Text= strsplit(core %>% html_node('title')%>% html_text(),split=":")[[1]][2]
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
			# #SnippetDisp = strsplit(SnippetDisp,'(\\), \n)',perl=TRUE)[[1]]
			#
			# SnippetDisp = toString(lapply(SnippetDisp,function(x) {
			#  paste0(x,')')
			# }))
			# SnippetDisp = gsub('\\n','',SnippetDisp)
			# SnippetDisp = gsub('  ','',SnippetDisp)

			Snippetlist = strsplit(Snippet,split=",")[[1]]
			functionname = sub('\n','',strsplit(Snippetlist[1],'\\(')[[1]][1])
			Snippetlist[1] <- sub('\\(','\\(${1:',Snippetlist[1])
			#print(functionname)
			j=2
			for(i in 2:length(Snippetlist)) {
				if(grepl("=", Snippetlist[i])){
					Snippetlist[i]<-paste0('${',j,':',strsplit(Snippetlist[i],split="=")[[1]][1],' = ','${',j+1,':',strsplit(Snippetlist[i],split="=")[[1]][2],'}})')
					j=j+2
					} else {
						Snippetlist[i]<-paste0('${',j,':',Snippetlist[i],'})')
						j=j+1
					}
				}
				Snippet = gsub("\n","",toString(Snippetlist))
				Description= gsub('\n','',core %>% html_node('h3+p')%>% html_text())
				DescriptionMoreURL= paste0(addr,x)
				list('text'=functionname,'snippet'=functionname,'prefix'=functionname,'displayText'=SnippetDisp,'description'=Description,'leftLabel'=package,'descriptionMoreURL'= DescriptionMoreURL)
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
methodsj<-scapeRdoc('methods')
graphicsj<-scapeRdoc('graphics') #dont work need investigation
cat(toJSON(list('keywords'=c(basej,statsj,toolsj,utilsj,methodsj))),file='completions.json')
