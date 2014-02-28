library(reshape)
library(XLConnect) #reads Excel files
library(sqldf)

#never ever ever ever convert strings to factors
options(stringsAsFactors = FALSE)


# Postcode data is from here: http://download.geonames.org/export/zip/
#get data about coordinates and post codes
postCodeData = read.table('DE.txt', sep='\t', head=FALSE)

colnames(postCodeData) = c("country_code", 
                           "postal_code", 
                           "place_name", 
                           "admin_name1", 
                           "admin_code1", 
                           "admin_name2", 
                           "admin_code2", 
                           "admin_name3", 
                           "admin_code3", 
                           "latitude", 
                           "longitude", 
                           "accuracy")

# There are multiple coordinates for the same postcode, simplify things by taking the average per unique postcode
# To be more accurate, some sort of fuzzy string matching system would have to be set up.
postCodeData = sqldf("select postal_code, avg(latitude) as lat, avg(longitude) as lon from postCodeData group by postal_code")

# Links to data sources are at:
# Current data
# http://www.bundesnetzagentur.de/cln_1911/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/DatenMeldgn_EEG-VergSaetze/DatenMeldgn_EEG_VergSaetze.html
# Archived data
# http://www.bundesnetzagentur.de/cln_1911/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/ArchivDatenMeldgn_node.html

# the data is spread out across bunches of files
filesAndURLs = c()
# January to September 2009
filesAndURLs["MeldungenJanSept2009.xls"] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/MeldungenJanSept2009_Id17481xls.xls?__blob=publicationFile&v=2"
# October to December 2009
filesAndURLs["MeldungenOktDez2009.xls"] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/MeldungenOktDez2009xls.xls?__blob=publicationFile&v=2"
# January to May 2010
filesAndURLs["Meldungen_JanMaii2010.xls"] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/Meldungen_JanMaii2010xls.xls?__blob=publicationFile&v=2"
# June to September 2010
filesAndURLs["Meldungen_JuniSept2010.xls"] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/Meldungen_JuniSept2010xls.xls?__blob=publicationFile&v=2"
# October to December 2010
filesAndURLs["Meldungen_OktDez2010.xls"] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/Meldungen_OktDez2010xls.xls?__blob=publicationFile&v=2"
# January to May 2011
filesAndURLs["Meldungen_JanMai2011.xls"] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/Meldungen_JanMai2011xls.xls?__blob=publicationFile&v=2"
# June to September 2011
filesAndURLs["Meldungen_JuniSept2011.xls"] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/Meldungen_JuniSept2011xls.xls?__blob=publicationFile&v=2"
# October to November 2011
filesAndURLs["Meldungen_OktNov2011.xls"] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/Meldungen_OktNov2011xls.xls?__blob=publicationFile&v=2"
# December 2011
filesAndURLs["Meldungen_Dez2011.xls"] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/Meldungen_Dez2011xls.xls?__blob=publicationFile&v=2"
# January to December 2012
filesAndURLs['Meldungen_JanDez2012.zip'] = 'http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/Meldungen_JanDez2012xls.zip?__blob=publicationFile&v=2'
# January to December 2013
filesAndURLs['Meldungen_JanDez2013.xls'] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/Datenmeldungen/Meldungen_2013_01-12.xls?__blob=publicationFile&v=1"
# January 2014
filesAndURLs['Meldungen_Jan2014.xls'] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/Datenmeldungen/Meldungen_2014_01.xls?__blob=publicationFile&v=1"


pvData = data.frame()
for (file in names(filesAndURLs)){
  print(file)
  if (file.exists(file) == FALSE) {
    download.file(filesAndURLs[file], file)
    # unzip if we indicated that this is a zip file
    if (grepl(".zip", file)){ 
      unzip(file)
    }
  }
    
  # If we have a zip file, assume that the xls file has the same name but different extension
  file = gsub(".zip", ".xls", file)

  #read in the data
  # there's a sheet for every month
  
  sheets <- getSheets(loadWorkbook(file))
  
  #there's only one valid sheet for this file
  if (file == "Meldungen_Jan2013.xls"){
    sheets = sheets[1]
  }
  
  for (sheet in sheets){
    print(paste("     ", sheet))
    
    startRow = 9
    # special cases with different start rows
    if (sheet %in% c("Oktober 2012", "November 2012", "Dezember 2012", "Tabelle1") || grepl("2013", sheet)){
      startRow = 11  
    }
    
    worksheetData = readWorksheetFromFile(file, 
                                          sheet = sheet, 
                                          header = TRUE, 
                                          startCol = 1, 
                                          startRow = startRow, 
                                          endCol=0, endRow=0)  
    
    # only keep five columns 
    # some of the ones October 2012 and later have "davon Installierte Nennleistung der geförderten Anlagen (kWp)"
    worksheetData = worksheetData[,c(1:5)]
    
    # the headers in the worksheet change slightly over time, so we need to give them standard names
    colnames(worksheetData) = c("date", "postcode", "place", "state", "capacity")

    # remove rows with all NAs
    worksheetData = worksheetData[complete.cases(worksheetData),]
    
    if (any(is.na(worksheetData$date))){
      stop("something's gone horribly wrong")
    }
    
    # convert the dates to a standard format
    worksheetData$date = as.Date(worksheetData$date, format="%d.%m.%Y")
    
    pvData = rbind(pvData, worksheetData)
    xlcFreeMemory() # java heap space
    rm(worksheetData)
  }
}

#merge this with data about the locations of the postcodes
# This takes a while
allData = merge(pvData, postCodeData, by.x =c('postcode'), by.y=c('postal_code'), all.x=TRUE)

#do something to plot by date
dates = sort(unique(allData$date))

#figure out the amount of capacity installed per date
capacityPerDate = sqldf("select date, sum(capacity) as capacitySum from allData group by date order by date")

#make indices on the data
sqldf("create index dateIndex on allData(date)")

#make a plot for each date
#need fixed bounds for the plot
count=0
transparency = 50

capacityCumulativeSum = cumsum(capacityPerDate$capacitySum)

#do a dynamic transparency based on the cumulative amount of capacity installed
#with this, things get dramatically lighter if lots of capacity is installed
minTransparency = 255
maxTransparency = 120

dynamicTransparency = minTransparency - ((minTransparency - maxTransparency) * capacityCumulativeSum / max(capacityCumulativeSum))
#dynamicTransparency = seq(200, 50, length.out=length(dates))

for(date in dates){
  #sum up capacity per date
  data = sqldf(paste("select lat, lon, sum(capacity) as totalCapacity from allData where date <= '", date ,"' group by lat, lon", sep=""))
  
  if(dim(data)[1] > 0){
    count = count + 1
    print(count)
    filename=paste(sprintf('%05d', count), ".png", sep="")
    #germany is about 850 km x 640 km
    png(filename=filename, width=1080, height=1435, units="px", pointsize=18, bg="white", res=NA)
    
    par(bg="black", col="yellow", xaxt='n', yaxt='n', ann=FALSE, mar=c(0,0,15,0), pty="m", col.main="yellow", lwd=3, cex=0.1)
    scalingFactor = 0.000002
    radii = sqrt((data$totalCapacity * scalingFactor)/ pi)

    #draw lots of different size circles which indicate the installed capacity at the different locations
    symbols(data$lon, data$lat, circles=radii, lwd=0.5, cex=0.1, inches=FALSE, fg=rgb(255,255,0,dynamicTransparency[count],maxColorValue=255), bg=rgb(255,255,0,dynamicTransparency[count],maxColorValue=255), xlim=c(6, 15), ylim=c(47,55), frame.plot=FALSE)
    title(main=paste(as.Date(date, origin="1970-01-01"), 
                "   -  ", 
                sprintf('%5.1f', sum(data$totalCapacity) / 1000), 
                " MW", sep=""), cex.main=20, lwd=20, mex=20, cex=20)
    dev.off()
  }
}

