library(terra)
library(geodata)

WetRich <- terra::rast("O:/Nat_Sustain-proj/_user/HanneNicolaisen_au704629/Data/Habitat_Ref_Map/RF_predict_binary_WetRich_thresh_1.tif")
WetPoor <- terra::rast("O:/Nat_Sustain-proj/_user/HanneNicolaisen_au704629/Data/Habitat_Ref_Map/RF_predict_binary_WetPoor_thresh_1.tif")
DryRich <- terra::rast("O:/Nat_Sustain-proj/_user/HanneNicolaisen_au704629/Data/Habitat_Ref_Map/RF_predict_binary_DryRich_thresh_1.tif")
DryPoor <- terra::rast("O:/Nat_Sustain-proj/_user/HanneNicolaisen_au704629/Data/Habitat_Ref_Map/RF_predict_binary_DryPoor_thresh_1.tif")

AllHabs <- c(DryPoor, DryRich, WetPoor, WetRich, DryPoor, DryRich, WetPoor, WetRich)
names(AllHabs) <- c("ForestDryPoor", "ForestDryRich", "ForestWetPoor", "ForestWetRich",
                    "OpenDryPoor", "OpenDryRich", "OpenWetPoor", "OpenWetRich")

Aarhus <- geodata::gadm(country = "Denmark", level = 2, path = getwd())

Aarhus <- Aarhus[Aarhus$NAME_2 == "Århus",]

Aarhus <- Aarhus |> terra::project(terra::crs(AllHabs))


AllHabs <- AllHabs |>
  terra::crop(Aarhus) |>
  terra::mask(Aarhus)

BDRUtils::write_cog(AllHabs, "HabSut/Aarhus.tif")
