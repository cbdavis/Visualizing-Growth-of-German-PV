library(reshape)
library(XLConnect) #reads Excel files
library(sqldf)

# Should use the postcode data here: http://download.geonames.org/export/zip/

#never ever ever convert strings to factors
options(stringsAsFactors = FALSE)
#get data about coordinates and post codes
postCodeData = read.table('german-addresses.csv', sep='\t', head=TRUE)

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
# January to February 2013
filesAndURLs['Meldungen_JanJuli2013.xls'] = "http://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/Datenmeldungen/Meldung_2013_01-07.xls?__blob=publicationFile&v=1"

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
        
    # convert the dates to a standard format
    worksheetData$date = as.Date(worksheetData$date, format="%d.%m.%Y")
    
    pvData = rbind(pvData, worksheetData)
    xlcFreeMemory() # java heap space
    rm(worksheetData)
  }
}

pvData$address = paste(pvData$place, pvData$postcode, pvData$state, "Germany", sep=", ")
# get rid of all spaces before commas, this messes up the matching
pvData$address = gsub(" +,", ",", pvData$address)

# remove duplicated addresses, just use the first value
postCodeData = postCodeData[-which(duplicated(postCodeData$address)),]

#merge this with data about the installations
allData = merge(pvData, postCodeData, by.x =c('address'), by.y=c('address'), all.x=TRUE)

# find the addresses that don't have coordinates yet
#unfoundAddresses = unique(gsub(" ,", ",", gsub(" ,", ",", allData1$address[which(is.na(allData1$lat))])))
# write.table(file="unfoundAddresses.txt", unfoundAddresses, row.names=FALSE)

#remove bad values - this is about 13,570 of 538081 entries
#locs = which(allData$lon > 120)
#allData = allData[-locs,]

#convert this from string to date
#allData$date = as.Date(allData$date)

# if there are any NA dates, remove those entries.  Not sure what are causing those
if (any(is.na(allData$date))){
  print(paste("Removing ", length(which(is.na(allData$date))), " NA dates"))
  allData = allData[-which(is.na(allData$date)),]
}

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
  data = sqldf(paste("select lat, lon, sum(capacity) as totalCapacity from allData where date <= '", date ,"' group by address", sep=""))
  
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

