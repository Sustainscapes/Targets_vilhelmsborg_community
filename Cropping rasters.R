#The Vilhelmsborg area:
c2000m <- vect("circle_2000_Vilhelm.shp")
Vilhelm_bbox <- c2000m %>% st_as_sf() %>% st_bbox()

#The matrikel:
matrikel <- vect("Matrikel.shp")
matrikel <- project(matrikel,SR_OWR_crop)

#Cropping the raster from Aarhus municipality to vilhelmsborg area

SR_OWR_crop <- terra::crop(SR_OWR,c2000m, snap = "out")
plot(SR_OWR_crop)
  plot(c2000m, add = T)
  plot(matrikel, add = T)

terra::writeRaster(SR_OWR_crop, "SR_OpenWetRich_crop.tif", format = "GTiff")

terra::mask(SR_OWR_crop,matrikel,touches = T, filename = "Cropped_rasters/GBIF_data/Richness/SR_OpenWetRich.tif", overwrite = T)

test <- rast("Cropped_rasters/GBIF_data/Richness/SR_OpenWetRich.tif")
plot(test)
plot(matrikel,add=T)


paste0("Cropped_rasters/GBIF_data/Richness/",names(SR_OWR_crop),"_GBIF.tif")



#Function for cropping and masking:
#Richness:
crop_and_mask_richness <- function(file){
  Raster <- terra::rast(file)
  Raster_crop <- terra::crop(Raster,c2000m, snap = "out")
  terra::mask(Raster_crop, matrikel, touches = T, filename = paste0("Cropped_rasters/GBIF_data/Richness/",names(Raster_crop),"_GBIF.tif"), overwrite = T)
}

#PD:
crop_and_mask_PD <- function(file){
  Raster <- terra::rast(file)
  Raster_crop <- terra::crop(Raster,c2000m, snap = "out")
  terra::mask(Raster_crop, matrikel, touches = T, filename = paste0("Cropped_rasters/GBIF_data/PD/",names(Raster_crop),"_GBIF.tif"), overwrite = T)
}

#Rarity:
crop_and_mask_rarity <- function(file){
  Raster <- terra::rast(file)
  Raster_crop <- terra::crop(Raster,c2000m, snap = "out")
  terra::mask(Raster_crop, matrikel, touches = T, filename = paste0("Cropped_rasters/GBIF_data/Rarity/",names(Raster_crop),"_GBIF.tif"), overwrite = T)
}
