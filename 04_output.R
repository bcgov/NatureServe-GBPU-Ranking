# Copyright 2017 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


#Make a shape file from Nature Serve Calculator data
require(rgdal)
require(gdata)
require(reshape2)
require(dplyr)

GBPU_NatureServe<- read.csv(file = paste(dataOutDir,"ProvGBPUs_NatServe.csv",sep=''))
GBPU<-readOGR(dsn=GISdir, layer="GBPU")
#GBPU@data$POPULATION

GBPUData<-GBPU@data
GBPUSummaryShp<-GBPUData %>% group_by(POPULATION) %>% summarise_at(vars(GEOMETRY_A),funs(sum(GEOMETRY_A)))
GBPUSummaryShp$AreaHa<-GBPUSummaryShp$GEOMETRY_A/10000
#GBPUSummaryShp$POPULATION<-sub("-","_",GBPUSummaryShp$POPULATION)
#GBPUSummaryShp$POPULATION<-sub(" ","",GBPUSummaryShp$POPULATION)

GBPUMerge<-merge(GBPU_NatureServe, GBPUSummaryShp, by.x="GBPU",by.y="POPULATION", all=TRUE)

GBPU@data = data.frame(GBPU@data, GBPUMerge[match(GBPU@data$POPULATION, GBPUMerge$GBPU),])

#Plot showing ranks
pdf(file=paste(figsOutDir,"GBPUNatureServeRank.pdf",sep=""))

plotvar2<-(GBPU@data$AssignedRank)
plotclr<-(c("R1","R1R2","R2","R2R3","R3","R3R4","R4","R4R5","R5"))
nclr<-length(plotclr)
names(plotclr) <- c('orange2','orange2','orange4','orange4','yellow2','yellow3','green2','green2','green4')
match.idx <- match(plotvar2, plotclr)
colcode <- ifelse(is.na(match.idx), plotvar2, names(plotclr)[match.idx])

plot(GBPU, col=colcode)

legend("topright", legend=c("M1","M1M2","M2","M2M3","M3","M3M4","M4","M4M5","M5"), fill=c((names(plotclr))), cex=0.7, title="Grizzly Bear-Status") #bty="n", bg='white'',
dev.off()

writeOGR(GBPU, dsn=dataOutDir, layer = 'GBPUNSRank', driver="ESRI Shapefile")
