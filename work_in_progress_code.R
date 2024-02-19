library(terra)
library(geodata)
library(rgbif)
library(sf)
library(sfheaders)
library(dplyr)


#Polygon for Aarhus municipality
Aarhus <- geodata::gadm(country = "denmark", level = 2, path = getwd())

Aarhus <- Aarhus[Aarhus$NAME_2 == "Århus",]

Aarhus_txt <- Aarhus|>       #Here we make it as a square polygon (bounding box)
  st_as_sf() |>
  st_bbox() |>
  st_as_sfc() |>
  st_as_text()


#Function to load fiedlwork data from existing nature plots
get_field_presences <- function(file) {
  Temp <- readRDS(file) %>%
    dplyr::filter(PA == 1) %>%
    janitor::clean_names() %>%
    dplyr::select(lat, lon, familie, slaegt, latinsk_navn) %>%
    dplyr::rename(decimalLatitude = lat, decimalLongitude = lon, family = familie, genus =slaegt, species = latinsk_navn)
}

#Function to laod field data from new nature plots
get_field_presences_csv <- function(file) {
  Temp <- read.csv(file, sep = ";") %>%
    dplyr::filter(PA == 1) %>%
    janitor::clean_names() %>%
    dplyr::select(lat, lon, familie, slaegt, latinsk_navn) %>%
    dplyr::rename(decimalLatitude = lat, decimalLongitude = lon, family = familie, genus =slaegt, species = latinsk_navn)
}

#Field data from existing nature plots
species_obs_exnat <- get_field_presences("feltdata_exisiting_nature_plots.rds") %>% group_by(species)

#Field data from new nature plots
species_obs_newnat <- get_field_presences_csv("feltdata_new_nature_plots.csv") %>% group_by(species)

#Species presences from GBIF
GBIF_obs <- rgbif::occ_count(hasCoordinate = T,
                             geometry = Aarhus_txt,
                             year = '1999,2023',
                             facet = 'scientificName',
                             facetLimit=100000,
                             kingdomKey=6)
GBIF_obs <- SDMWorkflows::Clean_Taxa(Taxons = GBIF_obs$scientificName)
