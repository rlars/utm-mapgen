# utm_mapgen
This Luanti mod converts (pre-generated) height and landcover arrays into map chunks.
![UTM mapgen](/utm_mapgen_main.jpg?raw=true "The city of Karlsruhe imported into Luanti")

## How to use it?
- Download the example data, showcasing the beautiful northern edge of Germany´s Black Forrest, from https://u.pcloud.link/publink/show?code=XZcDcj5ZwMwRy98fLRf8AKJMmxRjNh6HV6ik and extract the file to your utm_mapgen mod folder.
- In the game settings, set the grid offsets to some values which match your data.
- Create new world with *flat* generator and disable all structures like caves etc.
- You may want to have the following privileges: fly, fast (use k / j to activate)

## What does it do?
- The mod registers a custom mapgen which uses simple binary serialized height maps and landcover data in a special format.
- The data comes from publicly available sources (here: https://opengeodata.lgl-bw.de) containing height maps and a map displaying different colors for map usages (with some edge cases, e. g. blue color is not only water but also highway numbers)
### 20m grid
Each node models a cube of 20m x 20m x 20m of real-world data. The files have the following formats:
  - 8 bit ground height data, with an accuracy of 10 m (0 to 2560 m)
  - 8 bit measured height data (including trees, houses etc.), with an accuracy of 10 m (0 to 2560 m)
  - 16 bit landcover data: 4 bit for road (10m resolution), 4 bit unused, 4 bit for building (10m resolution), isWater, isForrest

## Generate your own data
While not documented as of now, you can generate your own data with the scripts in the additional_scripts folder.

## Similar mods
This mod relies on data converted outside of Luanti. Other mods allow you to use PNGs or GeoTIFF images (directly or indirectly), for example:
[realterrain](https://forum.luanti.org/viewtopic.php?t=12666)
[geo-mapgen](https://github.com/gaelysam/geo-mapgen)
