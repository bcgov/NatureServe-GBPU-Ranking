# Copyright 2017 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless  required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require(gdata)
require(reshape2)
require(dplyr)

# Read in NatureServe file
GBPU_NatureServe<- data.frame(read.csv(file = paste(dataOutDir,"ProvGBPUs_NatServe.csv",sep=''), sep=",", strip.white=TRUE))

#Read Provincial GBPU data from LU data set
LU_Summ_in <- data.frame(read.csv(header=TRUE, file=paste(GISdir, "GBear_LU_Summary_scores_v5_20160823.csv", sep=""), sep=",", strip.white=TRUE, ))

#amalgamate to GBPU
#Function for collapsing indicators to strata
#Collapse to strata and summarize, using reporting function
StratIndFn <- function(dataset, StratIN, IndsIN){
  dataset %>% 
    group_by_(.dots=StratIN) %>%
    summarise_at((.dot=IndsIN), funs(sum))
  #return(dataset)
}

Strata<-c('MAX_GBPU_POPULATION_NAME')
Indicators<-c('LU_AREA_KM2','LU_AREA_KM2_noWaterIceRock','LU_gbear_pop_est_temp','OpenRoadUtil_KM_x_KM2_noWaterIceRock','Tot_BEI_cap_AreaKM2_wght','Core_BEI_cap_AreaKM2_wght','Tot_Core_AreaKM2','Tot_Salmon_kg_all','Tot_Salmon_kg_recent','prot_wghtd_AREA_KM2')
StrataDF<-data.frame(Strata)
numStrats<-1
GB1<-StratIndFn(LU_Summ_in, Strata, Indicators)

CE_NatureServe<-merge(GBPU_NatureServe,GB1, by.x='GBPU', by.y='MAX_GBPU_POPULATION_NAME', all=TRUE)

