Clean <- tar_read("Clean_GBIF_obs")

test_function <- function(x){
  if(is.data.frame(x)){
    Result <- nrow(x) > 0
  } else if(!is.data.frame(x)){
    Result <- FALSE
  }
  return(Result)
}

Presences <-  1:nrow(Clean) %>%
  purrr::map(~tar_read("Presences", branches = .x)) %>%
  purrr::keep(function(x) test_function(x)) %>%
  purrr::map(~dplyr::pull(.x, species)) %>%
  purrr::map(unique) %>%
  purrr::reduce(c)

#THis is a vector of the species that does not work when we try to extract the presences
Missing <- Clean$species[!(Clean$species %in% Presences)]

DF1 <- list()
DF2 <- data.frame(a = 1)
DF3 <- DF2 %>% dplyr::filter(a > 1)

test_function(DF1)

test_function(DF2)

test_function(DF3)


Clean_obs <- Clean[!(Clean$species %in% Missing),]

write.csv2(Clean_obs,
           file = "GBIF_observations.csv")

GBIF_observations <- read_delim("GBIF_observations.csv",
                                delim = ";", escape_double = FALSE, trim_ws = TRUE)


write.csv2(Presences,
           file = "GBIF_presences.csv")


# Lookup table
library(readxl)
species_lookup <- read_excel("species_lookup.xlsx")

###########
#Plot of observations
library(ggplot2)
library(ggmap)
library(ggspatial)
library(stars)
library(tidyterra)

Lu_Aarhus <- rast("Dir/LU_Aarhus.tif")
ggplot()+
  geom_spatraster(data = Lu_Aarhus) +
  geom_point(data = Presences, mapping = aes(x = decimalLongitude, y = decimalLatitude))
