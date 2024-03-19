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
Budget <- sum(values(!is.na(NormPD)))


###Creating the problem###
# Define Cells
TroublemakeR::define_cells(Rasterdomain = NormPD[[1]], name = "ProblemVilhelmsborg")

# Define Edges
TroublemakeR::find_connections(Rasterdomain = NormPD[[1]], name = "ProblemVilhelmsborg")

TroublemakeR::landuse_names(landuses = PDNames, name = "ProblemVilhelmsborg")

TroublemakeR::species_suitability(Rastercurrent = NormPD, species_names = PDNames, parameter = "PhyloDiversity", name = "ProblemVilhelmsborg")

TroublemakeR::species_suitability(Rastercurrent = NormRichness, species_names = RichnessNames, parameter = "Richness", name = "ProblemVilhelmsborg")

TroublemakeR::species_suitability(Rastercurrent = NormRarity, species_names = RarityNames, parameter = "Rarity", name = "ProblemVilhelmsborg")

TroublemakeR::write_ampl_lines("param TransitionCost default 1", name = "ProblemVilhelmsborg")

TroublemakeR::write_ampl_lines(paste("param b :=", Budget), name = "ProblemVilhelmsborg")
