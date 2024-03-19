#Plotting the rasters:
#The Vilhelmsborg area:
c2000m <- vect("circle_2000_Vilhelm.shp")
#The matrikel:
matrikel <- vect("Matrikel.shp")
Aarhus_LU <- rast("Dir/LU_Aarhus.tif")
matrikel <- project(matrikel,Aarhus_LU)

#Plot for richness:
file_names_richness <- list.files("Cropped_rasters/GBIF_data/Richness/")


par(mfrow = c(3,3))
for(i in file_names_richness){
  Raster <- rast(paste0("Cropped_rasters/GBIF_data/Richness/",i))

  plot(Raster,
       main = names(Raster))
  plot(c2000m,
       add = T,
       border = "blue")
  plot(matrikel,
       add = T,
       border = "purple")
}


#Plot for Phylogenetic diversity:
file_names_PD <- list.files("Cropped_rasters/GBIF_data/PD/")


par(mfrow = c(3,3))
for(i in file_names_PD){
  Raster <- rast(paste0("Cropped_rasters/GBIF_data/PD/",i))

  plot(Raster,
       main = names(Raster))
  plot(c2000m,
       add = T,
       border = "blue")
  plot(matrikel,
       add = T,
       border = "purple")
}

#Plot for Rarity:
file_names_rarity <- list.files("Cropped_rasters/GBIF_data/Rarity/")


par(mfrow = c(3,3))
for(i in file_names_rarity){
  Raster <- rast(paste0("Cropped_rasters/GBIF_data/Rarity/",i))

  plot(Raster,
       main = names(Raster))
  plot(c2000m,
       add = T,
       border = "blue")
  plot(matrikel,
       add = T,
       border = "purple")
}
