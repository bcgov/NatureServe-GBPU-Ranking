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

require(gdata)
require(reshape2)
require(dplyr)

OutDir<-paste('out_',Sys.Date(),'/',sep='')
figsOutDir<-paste(OutDir,'figures/',sep='')
dataOutDir<-paste(OutDir,'data/',sep='')
dir.create(file.path(OutDir), showWarnings = FALSE)
dir.create(file.path(figsOutDir), showWarnings = FALSE)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
DataDir <- ("data/")
#Location of NatureServe Ranking spreadsheets
RankBaseDir<-paste(DataDir,'Ranks/',sep='')
RegionDirs<- list.files(path=paste(RankBaseDir,sep=''), pattern='')

#Provincial GBear GIS and csv data
GISdir <- paste(DataDir,"GISdir/",sep='')

#Empty data.frames
CFdf<-data.frame(GBPU=character(),Pop=character(),OverallThreat=character(),Isolation=character(),Trend=character(),AssignedRank=character())
TAdf<-data.frame(GBPU=character(),Residential=character(),Agriculture=character(),Energy=character(),Transportation=character(),BioUse=character(),HumanIntusion=character(),NaturalSysMod=character(),Invasives=character(),Pollution=character(),GeoEvents=character(),ClimateChange=character())

#Read in provincial Population Data
ProvPop <- data.frame(read.csv(header=TRUE, file=paste(DataDir, "Prov_PopnEstimates_21Sept2017.csv", sep=""), sep=",", strip.white=TRUE, ))

#Index through each GBPU in all sub directories and build a table from the "Calculator Form" and "Threats Assessments" tabs in the NatureServe sheets
Reg<-1
for (Reg in 1:length(RegionDirs)) {
  RegionGBPU<-list.files(path=paste(RankBaseDir,RegionDirs[Reg],'/',sep=''), pattern='GBPU')
  
  GBPU<-1
  for (GBPU in 1:length(RegionGBPU)) {
    
    GBPUname<- paste(RankBaseDir,RegionDirs[Reg],'/',RegionGBPU[GBPU],sep='')
    
    CalcForm = read.xls (GBPUname, sheet = "Calculator Form", header = TRUE)
    cfdf<-data.frame(GBPU=CalcForm$X.5[8],Pop=CalcForm$X.6[9],OverallThreat=CalcForm$X.5[10],Isolation=CalcForm$X.5[12],Trend=CalcForm$X.5[13],AssignedRank=CalcForm$X.4[15])
    
    CFdf<-rbind(CFdf,cfdf)
    
    ThreatsAss = read.xls (GBPUname, sheet = "Threats Assessment", header = TRUE)
    ThreatNums<-c(1,2,3,4,5,6,7,8,9,10,11)
    ThreatNames<-c('Residential','Agriculture','Energy','Transportation','BioUse','HumanIntusion','NaturalSysMod','Invasives','Pollution','GeoEvents','ClimateChange')
    
    tadfL<-ThreatsAss[ThreatsAss$X %in% ThreatNums,]$X.3
    
    tadf<-data.frame(GBPU=ThreatsAss$X.2[4],(t(melt(tadfL))))
    colnames(tadf)[2:12]<-ThreatNames
    
    TAdf<-rbind(TAdf,tadf)
    
  }
}

#Combine data from Population Esitmates, Calaculator Form and Threats Assessment data sets and write to directory
GBPU_NatureServe<-merge(CFdf,TAdf) %>%  merge(ProvPop, by.x='GBPU', by.y='POPULATION', all=TRUE)

write.csv(GBPU_NatureServe, file = paste(dataOutDir,"ProvGBPUs_NatServe.csv",sep=''), quote=TRUE)
