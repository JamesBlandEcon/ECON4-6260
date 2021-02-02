library(knitr)

dir<- dirname(sys.frame(1)$ofile)
setwd(dir)

files<-list.files(path=dir,pattern="*.Rmd")

print(files)

for (ss in files) {
  rmarkdown::render(ss,output_file = print(paste0("ECON46260Slides/",gsub(".Rmd",".html",ss))))

}

