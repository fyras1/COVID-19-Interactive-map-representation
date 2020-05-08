library(leaflet)
library(openxlsx)
library(dplyr)

date<-Sys.Date()-1
URL<-paste0("http://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-",date,".xlsx")
filename<-paste0("data\\covid_",date,".xlsx")
if (!file.exists(filename))
    download.file(URL,
                  destfile=filename,
                  mode="wb")


covid<- read.xlsx(filename,sheet=1)
countries<-read.csv("data\\countries.csv")
codes<-read.csv("data\\codes.csv")

df<-group_by(covid,countryCode=countryterritoryCode) %>% summarise(cases=sum(cases),deaths=sum(deaths),population=mean(popData2018))

codes<-codes[,c(2,3)]

combined<-merge(codes,countries,by.x="Alpha.2.code",by.y="country")

df<-merge(df,combined[,c(2:5)],by.x="countryCode",by.y="Alpha.3.code")



map<-df%>% 
    leaflet() %>% 
    addTiles() %>% 
    addCircles(lng=df$longitude,lat=df$latitude, weight=1,radius=sqrt(df$cases)*1500,label = paste0("Cases in ",df$name," : ",format(df$cases, big.mark=",")),color = "blue",labelOptions = labelOptions(interactive=TRUE,textsize="17px")) %>% 
    addCircles(lng=df$longitude,lat=df$latitude, weight=1,radius=sqrt(df$deaths)*1500,label = paste0("Deaths in ",df$name," : ",format(df$deaths, big.mark=",")),color = "red",labelOptions = labelOptions(interactive=TRUE,textsize="17px")) 
    
print(map)