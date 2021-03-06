library(rvest)

#to iterate for different report types, sub in "incidentReport", "fieldInterviews" or "trafficStops" for reportType
reportType <- "incidentReport"
today <- format(Sys.Date(), "%m/%d/%y")
startdate <- #Add desired start date here in mm/dd/yyyy format. Data was first released on 6/1/2015.
myurl <- paste0("https://incidentreports.uchicago.edu/",reportType,"Archive.php?startDate=",startdate,"&endDate=",today)
filename = paste0(reportType,".html")
download.file(myurl, destfile=filename)
myhtml <- readChar(filename, file.info(filename)$size)
myhtml <- gsub("</tr>", "</tr><tr>", myhtml, fixed = TRUE)
mydata <- read_html(myhtml)

mydf <- mydata %>%
  html_node("table") %>%
  html_table(fill = TRUE)

numpages <- mydata %>%
  html_node(".page-count span") %>%
  html_text() 

# extract number of pages from the first Web page
numpages <- as.numeric(gsub(".*\\/\\s(\\d+).*", "\\1", numpages))
morepages <- numpages - 1
myoffsets <- seq(from=5, by=5, length.out=morepages)

for(i in myoffsets){
  url <- paste0(myurl,"&offset=", i)
  download.file(url, destfile="temp.html")
  temphtml <- readChar("temp.html", file.info("temp.html")$size)
  temphtml <- gsub("</tr>", "</tr><tr>", temphtml, fixed = TRUE)
  tempdata <- html(temphtml)
  tempdf <- tempdata %>%
    html_node("table") %>%
    html_table(fill = TRUE)
  mydf <- rbind(mydf, tempdf)
}
mydf <- na.omit(mydf)
write.csv(mydf, file = paste0(reportType,".csv"))
