library(terra)
library(geodata)

WetRich <- terra::rast("O:/Nat_Sustain-proj/_user/HanneNicolaisen_au704629/Data/Habitat_Ref_Map/RF_predict_binary_WetRich_thresh_1.tif")
WetPoor <- terra::rast("O:/Nat_Sustain-proj/_user/HanneNicolaisen_au704629/Data/Habitat_Ref_Map/RF_predict_binary_WetPoor_thresh_1.tif")
DryRich <- terra::rast("O:/Nat_Sustain-proj/_user/HanneNicolaisen_au704629/Data/Habitat_Ref_Map/RF_predict_binary_DryRich_thresh_1.tif")
DryPoor <- terra::rast("O:/Nat_Sustain-proj/_user/HanneNicolaisen_au704629/Data/Habitat_Ref_Map/RF_predict_binary_DryPoor_thresh_1.tif")

AllHabs <- c(WetRich, WetRich, WetPoor, WetPoor, DryRich, DryRich, DryPoor, DryPoor)
