library(terra)
library(tidyterra)
library(ggplot2)
library(TroublemakeR)

setwd("C:/Users/Frederikke Natorp/OneDrive/Dokumenter/AU/Kandidat/Speciale/Targets_vilhelmsborg_community")

###For GBIF data, cropped and masked###
#As inputs we have our Phylogenetic Diversity files
PD <- list.files(path = "Cropped_masked_rasters/GBIF_data/PD/", pattern = "^PD_.*\\.tif$", full.names = T) |> rast()

PDNames <- list.files(path = "Cropped_masked_rasters/GBIF_data/PD/", pattern = "^PD_.*\\.tif$", full.names = F) |>
  stringr::str_remove_all("_GBIF.tif") |>
  stringr::str_remove_all("PD_")

names(PD) <- PDNames

#We normalize the PD:
NormPD <- round((PD/max(minmax(PD))), 2)


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
