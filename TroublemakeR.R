library(terra)
library(tidyterra)
library(ggplot2)
library(TroublemakeR)

#setwd("C:/Users/Frederikke Natorp/OneDrive/Dokumenter/AU/Kandidat/Speciale#/Targets_vilhelmsborg_community")

###For GBIF data, cropped and masked###
#As inputs we have our Phylogenetic Diversity files
PD <- list.files(path = "Cropped_masked_rasters/GBIF_data/PD/", pattern = "^PD_.*\\.tif$", full.names = T) |> rast()

PDNames <- list.files(path = "Cropped_masked_rasters/GBIF_data/PD/", pattern = "^PD_.*\\.tif$", full.names = F) |>
  stringr::str_remove_all("_GBIF.tif") |>
  stringr::str_remove_all("PD_")

names(PD) <- PDNames

#We normalize the PD:
NormPD <- round((PD/max(minmax(PD))), 2)

Rain <- terra::rast("Future_wet_areas_85mmrain_Vilhelmsborg.tif") |>
  terra::project(terra::crs(PD[[1]]), "near")

Rain <- ifel(is.na(Rain), 0, Rain)

Rainb <- Rain |>
  terra::aggregate(fun =  "mean", 500, cores = 3) |>
  terra::resample(PD[[1]], method = "bilinear", threads = T)

Rainb <- ifel(is.na(Rainb), 0, Rainb)


BDRUtils::write_cog(Rainb, "Future_wet_areas_85mmrain_resamp.tif")

Rain2 <- terra::rast("Wet_areas_SCALGO_Vilhelmsborg.tif") |>
  terra::project(terra::crs(PD[[1]]), "near")

Rain2 <- ifel(is.na(Rain2), 0, Rain2)
Rain2b <- Rain2 |>
  terra::crop(PD[[1]]) |>
  terra::aggregate(fun =  "mean", 1000, cores = 3) |>
  terra::resample(PD[[1]], method = "bilinear", threads = T)

Rain2b <- ifel(is.na(Rain2b), 0, Rain2b)

BDRUtils::write_cog(Rain2b, "Wet_areas_SCALGO_Vilhelmsborg_resamp.tif")

#We do the same with richness:
Richness <- list.files(path = "Cropped_masked_rasters/GBIF_data/Richness/", pattern = "^Richness_.*\\.tif$", full.names = T) |> rast()

RichnessNames <- list.files(path = "Cropped_masked_rasters/GBIF_data/Richness/", pattern = "^Richness_.*\\.tif$", full.names = F) |>
  stringr::str_remove_all("_GBIF.tif") |>
  stringr::str_remove_all("Richness_")

names(Richness) <- RichnessNames

#We normalize Richness:
NormRichness <- round((Richness/max(minmax(Richness))), 2)

#We do the same for Rarity:
Rarity <- list.files(path = "Cropped_masked_rasters/GBIF_data/Rarity/", pattern = "^Rarity_.*\\.tif$", full.names = T) |> rast()

RarityNames <- list.files(path = "Cropped_masked_rasters/GBIF_data/Rarity/", pattern = "^Rarity_.*\\.tif$", full.names = F) |>
  stringr::str_remove_all("_GBIF.tif") |>
  stringr::str_remove_all("Rarity_")

names(Rarity) <- RarityNames

#We normalize Richness:
NormRarity <- round((Rarity/max(minmax(Rarity))), 2)

##Budget of cells:
Budget <- length(cells(NormPD))


###Creating the problem###
# Define Cells
TroublemakeR::define_cells(Rasterdomain = NormPD[[1]], name = "ProblemVilhelmsborg_GBIF")

# Define Edges
TroublemakeR::find_connections(Rasterdomain = NormPD[[1]], name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::landuse_names(landuses = PDNames, name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::species_suitability(Rastercurrent = NormPD, species_names = PDNames, parameter = "PhyloDiversity", name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::species_suitability(Rastercurrent = NormRichness, species_names = RichnessNames, parameter = "Richness", name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::species_suitability(Rastercurrent = NormRarity, species_names = RarityNames, parameter = "Rarity", name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::write_ampl_lines("param TransitionCost default 1", name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::write_ampl_lines(paste("param b :=", Budget), name = "ProblemVilhelmsborg_GBIF")


###For GBIF+field data, cropped and masked###
#As inputs we have our Phylogenetic Diversity files
PD_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/PD/", pattern = "^PD_.*\\.tif$", full.names = T) |> rast()

PDNames_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/PD/", pattern = "^PD_.*\\.tif$", full.names = F) |>
  stringr::str_remove_all("_field.tif") |>
  stringr::str_remove_all("PD_")

names(PD_field) <- PDNames_field

#We normalize the PD:
NormPD_field <- round((PD_field/max(minmax(PD_field))), 2)


#We do the same with richness:
Richness_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/Richness/", pattern = "^Richness_.*\\.tif$", full.names = T) |> rast()

RichnessNames_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/Richness/", pattern = "^Richness_.*\\.tif$", full.names = F) |>
  stringr::str_remove_all("_field.tif") |>
  stringr::str_remove_all("Richness_")

names(Richness_field) <- RichnessNames_field

#We normalize Richness:
NormRichness_field <- round((Richness_field/max(minmax(Richness_field))), 2)

#We do the same for Rarity:
Rarity_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/Rarity/", pattern = "^Rarity_.*\\.tif$", full.names = T) |> rast()

RarityNames_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/Rarity/", pattern = "^Rarity_.*\\.tif$", full.names = F) |>
  stringr::str_remove_all("_field.tif") |>
  stringr::str_remove_all("Rarity_")

names(Rarity_field) <- RarityNames_field

#We normalize Richness:
NormRarity_field <- round((Rarity_field/max(minmax(Rarity_field))), 2)

##Budget of cells:
Budget_field <- length(cells(NormPD_field))


###Creating the problem###
# Define Cells
TroublemakeR::define_cells(Rasterdomain = NormPD_field[[1]], name = "ProblemVilhelmsborg_field")

# Define Edges
TroublemakeR::find_connections(Rasterdomain = NormPD_field[[1]], name = "ProblemVilhelmsborg_field")

TroublemakeR::landuse_names(landuses = PDNames_field, name = "ProblemVilhelmsborg_field")

TroublemakeR::species_suitability(Rastercurrent = NormPD_field, species_names = PDNames_field, parameter = "PhyloDiversity", name = "ProblemVilhelmsborg_field")

TroublemakeR::species_suitability(Rastercurrent = NormRichness_field, species_names = RichnessNames_field, parameter = "Richness", name = "ProblemVilhelmsborg_field")

TroublemakeR::species_suitability(Rastercurrent = NormRarity_field, species_names = RarityNames_field, parameter = "Rarity", name = "ProblemVilhelmsborg_field")

TroublemakeR::write_ampl_lines("param TransitionCost default 1", name = "ProblemVilhelmsborg_field")

TroublemakeR::write_ampl_lines(paste("param b :=", Budget_field), name = "ProblemVilhelmsborg_field")

## Optimization 3

# Define Cells
TroublemakeR::define_cells(Rasterdomain = NormPD[[1]], name = "ProblemVilhelmsborg_GBIF_wet")

# Define Edges
TroublemakeR::find_connections(Rasterdomain = NormPD[[1]], name = "ProblemVilhelmsborg_GBIF_wet")

TroublemakeR::landuse_names(landuses = PDNames, name = "ProblemVilhelmsborg_GBIF_wet")

NormPD2 <- NormPD

NormPD2[[c(1,2,5,6)]] <- NormPD2[[c(1,2,5,6)]]*(1-Rain2b)


TroublemakeR::species_suitability(Rastercurrent = NormPD2, species_names = PDNames, parameter = "PhyloDiversity", name = "ProblemVilhelmsborg_GBIF_wet")

NormRichness2 <- NormRichness

NormRichness2[[c(1,2,5,6)]] <- NormRichness2[[c(1,2,5,6)]]*(1-Rain2b)


TroublemakeR::species_suitability(Rastercurrent = NormRichness2, species_names = RichnessNames, parameter = "Richness", name = "ProblemVilhelmsborg_GBIF_wet")

NormRarity2 <- NormRarity

NormRarity2[[c(1,2,5,6)]] <- NormRarity2[[c(1,2,5,6)]]*(1-Rain2b)

TroublemakeR::species_suitability(Rastercurrent = NormRarity2, species_names = RarityNames, parameter = "Rarity", name = "ProblemVilhelmsborg_GBIF_wet")

TroublemakeR::write_ampl_lines("param TransitionCost default 1", name = "ProblemVilhelmsborg_GBIF_wet")

TroublemakeR::write_ampl_lines(paste("param b :=", Budget), name = "ProblemVilhelmsborg_GBIF_wet")

## Optimization 4

# Define Cells
TroublemakeR::define_cells(Rasterdomain = NormPD_field[[1]], name = "ProblemVilhelmsborg_field_wet")

# Define Edges
TroublemakeR::find_connections(Rasterdomain = NormPD_field[[1]], name = "ProblemVilhelmsborg_field_wet")

TroublemakeR::landuse_names(landuses = PDNames_field, name = "ProblemVilhelmsborg_field_wet")

NormPD_field2 <- NormPD_field

NormPD_field2[[c(1,2,5,6)]] <- NormPD_field2[[c(1,2,5,6)]]*(1-Rainb)

TroublemakeR::species_suitability(Rastercurrent = NormPD_field, species_names = PDNames_field, parameter = "PhyloDiversity", name = "ProblemVilhelmsborg_field_wet")

NormRichness_field2 <- NormRichness_field

NormRichness_field2[[c(1,2,5,6)]] <- NormRichness_field2[[c(1,2,5,6)]]*(1-Rainb)

TroublemakeR::species_suitability(Rastercurrent = NormRichness_field2, species_names = RichnessNames_field, parameter = "Richness", name = "ProblemVilhelmsborg_field_wet")

NormRarity_field2 <- NormRarity_field

NormRarity_field2[[c(1,2,5,6)]] <- NormRarity_field2[[c(1,2,5,6)]]*(1-Rainb)

TroublemakeR::species_suitability(Rastercurrent = NormRarity_field2, species_names = RarityNames_field, parameter = "Rarity", name = "ProblemVilhelmsborg_field_wet")

TroublemakeR::write_ampl_lines("param TransitionCost default 1", name = "ProblemVilhelmsborg_field_wet")

TroublemakeR::write_ampl_lines(paste("param b :=", Budget_field), name = "ProblemVilhelmsborg_field_wet")

## Optimization 5

Rain2b <- terra::rast("Wet_areas_SCALGO_Vilhelmsborg_resamp.tif")

# Define Cells
TroublemakeR::define_cells(Rasterdomain = NormPD[[1]], name = "ProblemVilhelmsborg_GBIF_prop_wet")

# Define Edges
TroublemakeR::find_connections(Rasterdomain = NormPD[[1]], name = "ProblemVilhelmsborg_GBIF_prop_wet")

TroublemakeR::landuse_names(landuses = PDNames, name = "ProblemVilhelmsborg_GBIF_prop_wet")

TroublemakeR::write_ampl_lines(paste(c("set ForestLanduses :=", PDNames[stringr::str_detect(PDNames, "Forest")]), collapse = " "), name = "ProblemVilhelmsborg_GBIF_prop_wet")

TroublemakeR::write_ampl_lines(paste(c("set OpenLanduses :=", PDNames[stringr::str_detect(PDNames, "Open")]), collapse = " "), name = "ProblemVilhelmsborg_GBIF_prop_wet")

NormPD2 <- NormPD

NormPD2[[c(1,2,5,6)]] <- NormPD2[[c(1,2,5,6)]]*(1-Rain2b)


TroublemakeR::species_suitability(Rastercurrent = NormPD2, species_names = PDNames, parameter = "PhyloDiversity", name = "ProblemVilhelmsborg_GBIF_prop_wet")

NormRichness2 <- NormRichness

NormRichness2[[c(1,2,5,6)]] <- NormRichness2[[c(1,2,5,6)]]*(1-Rain2b)


TroublemakeR::species_suitability(Rastercurrent = NormRichness2, species_names = RichnessNames, parameter = "Richness", name = "ProblemVilhelmsborg_GBIF_prop_wet")

NormRarity2 <- NormRarity

NormRarity2[[c(1,2,5,6)]] <- NormRarity2[[c(1,2,5,6)]]*(1-Rain2b)

TroublemakeR::species_suitability(Rastercurrent = NormRarity2, species_names = RarityNames, parameter = "Rarity", name = "ProblemVilhelmsborg_GBIF_prop_wet")

TroublemakeR::write_ampl_lines("param TransitionCost default 1", name = "ProblemVilhelmsborg_GBIF_prop_wet")

TroublemakeR::write_ampl_lines(paste("param b :=", Budget), name = "ProblemVilhelmsborg_GBIF_prop_wet")

## Optimization 6

Forest <- terra::rast("Forest_AAK_v2.tif")
Forest <- ifel(Forest == 0, 2, Forest)

Forest <- Forest - 1

# Define Cells
TroublemakeR::define_cells(Rasterdomain = NormPD_field[[1]], name = "ProblemVilhelmsborg_field_wet_forest")

# Define Edges
TroublemakeR::find_connections(Rasterdomain = NormPD_field[[1]], name = "ProblemVilhelmsborg_field_wet_forest")

TroublemakeR::landuse_names(landuses = PDNames_field, name = "ProblemVilhelmsborg_field_wet_forest")

NormPD_field2 <- NormPD_field

NormPD_field2[[c(1,2,5,6)]] <- NormPD_field2[[c(1,2,5,6)]]*(1-Rainb)
NormPD_field2[[c(5,6,7,8)]] <- NormPD_field2[[c(5,6,7,8)]]*Forest

TroublemakeR::species_suitability(Rastercurrent = NormPD_field, species_names = PDNames_field, parameter = "PhyloDiversity", name = "ProblemVilhelmsborg_field_wet_forest")

NormRichness_field2 <- NormRichness_field

NormRichness_field2[[c(1,2,5,6)]] <- NormRichness_field2[[c(1,2,5,6)]]*(1-Rainb)
NormRichness_field2[[c(5,6,7,8)]] <- NormRichness_field2[[c(5,6,7,8)]]*Forest

TroublemakeR::species_suitability(Rastercurrent = NormRichness_field2, species_names = RichnessNames_field, parameter = "Richness", name = "ProblemVilhelmsborg_field_wet_forest")

NormRarity_field2 <- NormRarity_field

NormRarity_field2[[c(1,2,5,6)]] <- NormRarity_field2[[c(1,2,5,6)]]*(1-Rainb)
NormRarity_field2[[c(5,6,7,8)]] <- NormRarity_field2[[c(5,6,7,8)]]*Forest6

TroublemakeR::species_suitability(Rastercurrent = NormRarity_field2, species_names = RarityNames_field, parameter = "Rarity", name = "ProblemVilhelmsborg_field_wet_forest")

TroublemakeR::write_ampl_lines("param TransitionCost default 1", name = "ProblemVilhelmsborg_field_wet_forest")

TroublemakeR::write_ampl_lines(paste("param b :=", Budget_field), name = "ProblemVilhelmsborg_field_wet_forest")
TroublemakeR::define_cells(Rasterdomain = NormPD[[1]], name = "ProblemVilhelmsborg_GBIF")

# Define Edges
TroublemakeR::find_connections(Rasterdomain = NormPD[[1]], name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::landuse_names(landuses = PDNames, name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::species_suitability(Rastercurrent = NormPD, species_names = PDNames, parameter = "PhyloDiversity", name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::species_suitability(Rastercurrent = NormRichness, species_names = RichnessNames, parameter = "Richness", name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::species_suitability(Rastercurrent = NormRarity, species_names = RarityNames, parameter = "Rarity", name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::write_ampl_lines("param TransitionCost default 1", name = "ProblemVilhelmsborg_GBIF")

TroublemakeR::write_ampl_lines(paste("param b :=", Budget), name = "ProblemVilhelmsborg_GBIF")


###For GBIF+field data, cropped and masked###
#As inputs we have our Phylogenetic Diversity files
PD_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/PD/", pattern = "^PD_.*\\.tif$", full.names = T) |> rast()

PDNames_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/PD/", pattern = "^PD_.*\\.tif$", full.names = F) |>
  stringr::str_remove_all("_field.tif") |>
  stringr::str_remove_all("PD_")

names(PD_field) <- PDNames_field

#We normalize the PD:
NormPD_field <- round((PD_field/max(minmax(PD_field))), 2)


#We do the same with richness:
Richness_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/Richness/", pattern = "^Richness_.*\\.tif$", full.names = T) |> rast()

RichnessNames_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/Richness/", pattern = "^Richness_.*\\.tif$", full.names = F) |>
  stringr::str_remove_all("_field.tif") |>
  stringr::str_remove_all("Richness_")

names(Richness_field) <- RichnessNames_field

#We normalize Richness:
NormRichness_field <- round((Richness_field/max(minmax(Richness_field))), 2)

#We do the same for Rarity:
Rarity_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/Rarity/", pattern = "^Rarity_.*\\.tif$", full.names = T) |> rast()

RarityNames_field <- list.files(path = "Cropped_masked_rasters/GBIF_Field_data/Rarity/", pattern = "^Rarity_.*\\.tif$", full.names = F) |>
  stringr::str_remove_all("_field.tif") |>
  stringr::str_remove_all("Rarity_")

names(Rarity_field) <- RarityNames_field

#We normalize Richness:
NormRarity_field <- round((Rarity_field/max(minmax(Rarity_field))), 2)

##Budget of cells:
Budget_field <- length(cells(NormPD_field))


###Creating the problem###
# Define Cells
TroublemakeR::define_cells(Rasterdomain = NormPD_field[[1]], name = "ProblemVilhelmsborg_field")

# Define Edges
TroublemakeR::find_connections(Rasterdomain = NormPD_field[[1]], name = "ProblemVilhelmsborg_field")

TroublemakeR::landuse_names(landuses = PDNames_field, name = "ProblemVilhelmsborg_field")

TroublemakeR::species_suitability(Rastercurrent = NormPD_field, species_names = PDNames_field, parameter = "PhyloDiversity", name = "ProblemVilhelmsborg_field")

TroublemakeR::species_suitability(Rastercurrent = NormRichness_field, species_names = RichnessNames_field, parameter = "Richness", name = "ProblemVilhelmsborg_field")

TroublemakeR::species_suitability(Rastercurrent = NormRarity_field, species_names = RarityNames_field, parameter = "Rarity", name = "ProblemVilhelmsborg_field")

TroublemakeR::write_ampl_lines("param TransitionCost default 1", name = "ProblemVilhelmsborg_field")

TroublemakeR::write_ampl_lines(paste("param b :=", Budget_field), name = "ProblemVilhelmsborg_field")
