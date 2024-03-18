# _targets.R file
library(targets)
source("R/functions.R")
library(crew)
library(tarchetypes)
library(terra)
library(geodata)
library(rgbif)
library(sf)
library(dplyr)
library(readxl)
library(readr)
library(data.table)


tar_option_set(packages = c("data.table", "dplyr", "ENMeval","janitor", "magrittr", "maxnet", "purrr", "Rarity", "readxl",
                            "SDMWorkflows", "stringr", "tidyr", "tibble","terra", "V.PhyloMaker", "BDRUtils", "readr"),
               controller = crew_controller_local(workers = 4),
               error = "null") # Force skip non-debugging outdated targets)

#Polygon for Aarhus municipality
Aarhus <- geodata::gadm(country = "denmark", level = 2, path = getwd())

Aarhus <- Aarhus[Aarhus$NAME_2 == "Århus",]

Aarhus_txt <- Aarhus|>       #Here we make it as a square polygon (bounding box)
  st_as_sf() |>
  st_bbox() |>
  st_as_sfc() |>
  st_as_text()

#Polygon for 2000m radius around Vilhelmsborg
c2000m <- vect("circle_2000_Vilhelm.shp")
c2000m_proj <- project(c2000m,"+proj=longlat +datum=WGS84")
Vilhelm_txt <- c2000m_proj %>% st_as_sf() %>% st_bbox() %>% st_as_sfc() %>% st_as_text()

list(
#Path to the Habitat model raster output of potential habitat types
  tar_target(LanduseSuitability,
             "HabSut/Aarhus.tif",
             format = "file"),

#Path to the raster of current land use in terms of habitat types
  tar_target(LandUseTiff,
             "Dir/LU_Aarhus.tif",
             format = "file"),

#Path to the presences data of plant species in existing nature plots (from fieldwork)
  tar_target(Species_cover,
             "feltdata_exisiting_nature_plots.rds",
             format = "file"),

#Loading and grouping the observations pr. species (existing nature, fieldwork)
  tarchetypes::tar_group_by(field_presences, get_field_presences(Species_cover), species),

#Path to the presences data of plant specie in new nature plots (from fieldwork)
  tar_target(Species_newnature,
             "feltdata_new_nature_plots.csv",
             format = "file"),

#Loading and grouping the observations pr. species (existing nature, fieldwork)
  tarchetypes::tar_group_by(field_presences_newnature, get_field_presences_csv(Species_newnature), species),

#NOT WORKING: Combining the observations from both new and existing nature (from fieldwork)
  tar_target(Species_observations,
             full_join(field_presences,field_presences_newnature)),

#Loading plant species presences from GBIF
  #tar_target(GBIF_occ,get_plant_occurrences()),
  tar_target(GBIF_obs,
             gbif_observations(area = Vilhelm_txt)),
  tar_target(Clean_GBIF_obs,
             clean_species(Filter_Counts(GBIF_obs))), #This output is cleaned for species that did not work when I tried to run Presences, see debugging file.
  tar_target(GBIF_species,
             read_delim("GBIF_observations2.csv",
                        delim = ";", escape_double = FALSE, trim_ws = TRUE)),
  #tar_target(Presences,
             #get_plant_presences2(GBIF_species),
             #pattern = map(GBIF_species)),
#We import the csv so we don't have to run the whole thing again
  tar_target(Presences, read_delim("GBIF_presences2.csv",
                                   delim = ";", escape_double = FALSE, locale = locale(decimal_mark = ",",
                                   grouping_mark = ""), trim_ws = TRUE)),

#Joining the data from GBIF and the fieldwork
  tar_target(joint_data,
             join_select(Species_observations,Presences)),

#Creating a buffer of 500m around each species observation to account for dispersal
  tar_target(buffer_500_field, make_buffer_rasterized(DT = joint_data, file = LandUseTiff),
             pattern = map(joint_data),
             iteration = "group"),
#Transforming the buffer into a dataframe
  tar_target(Long_Buffer_field, make_long_buffer(DT = buffer_500_field),
             pattern = map(buffer_500_field),
             iteration = "group"),
#Creating a buffer of 500m around each species observation to account for dispersal
tar_target(buffer_500_gbif, make_buffer_rasterized(DT = Presences, file = LandUseTiff),
           pattern = map(Presences),
           iteration = "group"),
#Transforming the buffer into a dataframe
tar_target(Long_Buffer_gbif, make_long_buffer(DT = buffer_500_gbif),
           pattern = map(buffer_500_gbif),
           iteration = "group"),

#Generating a phylogenetic tree of the observed species
  tar_target(Phylo_Tree, generate_tree(Presences)),
  tar_target(Phylo_Tree_field, generate_tree(joint_data)),

#Modelling the the species distribution based on the habitat types in the raster map of present nature
  #tar_target(ModelAndPredict, ModelAndPredictFunc(DF =  Presences, file = LandUseTiff),
             #pattern = map(Presences)),
             #iteration = "group"),
  #tar_target(Thresholds, create_thresholds(Model = ModelAndPredict,reference = Presences, LandUseTiff),
             #pattern = map(ModelAndPredict, Presences),
             #iteration = "group"),

#Creates a lookup table for suitable habitat types for each species
  #tar_target(LookUpTable, Generate_Lookup(Model = ModelAndPredict, Thresholds = Thresholds)),
#We just use the lookup table that Derek has already created for all of DK
  tar_target(LookUpTable,
             Make_Look_Up_Table("species_lookup.xlsx")),
  tar_target(LanduseTable, generate_landuse_table(path = LanduseSuitability)),
  tar_target(Long_LU_table, Make_Long_LU_table(DF = LanduseTable)),

#Final presences GBIF:
  tar_target(Final_Presences, make_final_presences(Long_LU_table, Long_Buffer_gbif, LookUpTable),
             pattern = map(Long_Buffer_gbif),
             iteration = "group"),
  tarchetypes::tar_group_by(joint_final_presences, as.data.frame(Final_Presences), Landuse),

#Final presences GBIF+Field:
  tar_target(Final_Presences_field, make_final_presences(Long_LU_table, Long_Buffer_field, LookUpTable),
             pattern = map(Long_Buffer_field),
             iteration = "group"),
  tarchetypes::tar_group_by(joint_final_presences_field, as.data.frame(Final_Presences_field), Landuse),

#output for GBIF data:
  tar_target(rarity_weight, calc_rarity_weight(joint_final_presences)),
  tar_target(rarity, calc_rarity(joint_final_presences, rarity_weight),
             map(joint_final_presences),
             iteration = "group"),
  tar_target(PhyloDiversity,
             calc_pd(joint_final_presences, Phylo_Tree),
             map(joint_final_presences),
             iteration = "group"),
  tar_target(Richness, GetRichness(joint_final_presences)),
  tar_target(name = output_Richness,
             command = export_richness(Results = PhyloDiversity, path = LandUseTiff),
             map(PhyloDiversity),
             format = "file"),
  tar_target(name = output_PD,
             command = export_pd(Results = PhyloDiversity, path = LandUseTiff),
             map(PhyloDiversity),
             format = "file"),
  tar_target(name = output_Rarity,
             command = export_rarity(Results = rarity, path = LandUseTiff),
             map(rarity),
             format = "file"),

#output for the GBIF+field data:
  tar_target(rarity_weight_field, calc_rarity_weight(joint_final_presences_field)),
  tar_target(rarity_field, calc_rarity(joint_final_presences_field, rarity_weight_field),
             map(joint_final_presences_field),
             iteration = "group"),
  tar_target(PhyloDiversity_field,
             calc_pd(joint_final_presences_field, Phylo_Tree_field),
             map(joint_final_presences_field),
             iteration = "group"),
  tar_target(Richness_field, GetRichness(joint_final_presences_field)),
  tar_target(name = output_Richness_field,
             command = export_richness_field(Results = PhyloDiversity_field, path = LandUseTiff),
             map(PhyloDiversity_field),
             format = "file"),
  tar_target(name = output_PD_field,
             command = export_pd_field(Results = PhyloDiversity_field, path = LandUseTiff),
             map(PhyloDiversity_field),
             format = "file"),
  tar_target(name = output_Rarity_field,
             command = export_rarity_field(Results = rarity_field, path = LandUseTiff),
             map(rarity_field),
             format = "file")
)

