# Converting a Shapefile to TopoJSON for D3.js

Before starting you should install the utilities you will need:

```
yarn global add shapefile mapshaper d3-geo-projection
```

## The Problem
As a geospatial web developer you want to convert your shapefile to display on a webpage. You have some knowledge of web mapping and shapefiles. You have gone through a basic tutorial to put your map on a page using [D3.js](https://d3js.org). You now have a GeoJSON file and your web browser is crashing trying to render it. It cannot process all your polygons. Lucky for you, you found this tutorial.

Typically you will find and store your GeoJSON using the WGS84 coordinate system.[^1] This is the format that most web applications will expect to find it in. If you follow [Mike Bostock's original mapping tutorial](https://bost.ocks.org/mike/map/) he explains the use of projection assuming the original file is in WGS84 as follows:

> We need two more things to render geography: a projection and a path generator. As its name implies, the projection projects spherical coordinate to the Cartesian plane. This is needed to display spherical geometry on a 2D screen; you can skip this step if this is the future and you’re using a 3D holographic display. The path generator takes the projected 2D geometry and formats it appropriately for SVG or Canvas.

An example of a projection in D3.js is:

```
var projection = d3.geo.mercator()
    .scale(500)
    .translate([width / 2, height / 2]);
```
You may have noticed the yellow box and started to read Mike Bostock's [command line cartography tutorial](https://medium.com/@mbostock/command-line-cartography-part-1-897aa8f8ca2c). In this tutorial Mike asks you to do something new:
> We could now display this in a browser using D3, but first we should apply a geographic projection. By avoiding expensive trigonometric operations at runtime, the resulting GeoJSON renders much faster, especially on mobile devices. Pre-projecting also improves the efficacy of simplification, which we’ll cover in part 3.

He is telling you to pre-project your GeoJSON. Instead of starting with WGS84 GeoJSON and converting it using Javascript in the browser, you will convert it once and read the projected GeoJSON directly.[^1]

## Shapefile to Pre-Projected GeoJSON
In order to pre-project your shapefile into the correct GeoJSON you need to know what you are starting with. You can typically tell the current projection of a shapefile by looking at the accompanying `.prj` file. An example of .prj file contents for the Massachusetts State Plane would be:

```
cat 20191125_extreme-heat-vulnerability-MAPC.prj

PROJCS["NAD_1983_StatePlane_Massachusetts_Mainland_FIPS_2001",GEOGCS["GCS_North_American_1983",DATUM["D_North_American_1983",SPHEROID["GRS_1980",6378137.0,298.257222101]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Lambert_Conformal_Conic"],PARAMETER["False_Easting",200000.0],PARAMETER["False_Northing",750000.0],PARAMETER["Central_Meridian",-71.5],PARAMETER["Standard_Parallel_1",41.71666666666667],PARAMETER["Standard_Parallel_2",42.68333333333333],PARAMETER["Latitude_Of_Origin",41.0],UNIT["Meter",1.0]]
```

The first step is to use `mapshaper` to convert your source shapefile into GeoJSON:

```
mapshaper 20191125_extreme-heat-vulnerability-MAPC.shp -o format=geojson 20191125_extreme-heat-vulnerability-MAPC.json
```

In the case above we are taking the shapefile `20191125_extreme-heat-vulnerability-MAPC.shp` and specifying geojson as the output with `-o format=geojson`. The last argument is the target file name. We can also replace the file name  with `-` to direct the output to `STDOUT` and see if in our terminal application or use pipe (`|`)  to send it to another terminal application.

To keep it in the MA state projection that the shapefile already was in we simply execute:

```
mapshaper 20191125_extreme-heat-vulnerability-MAPC.shp -o format=geojson 20191125_extreme-heat-vulnerability-MAPC.json
```

If we wanted to change the output to use WGS84 (the standard GeoJSON coordinate system) we would type:

```
mapshaper 20191125_extreme-heat-vulnerability-MAPC.shp -proj from=20191125_extreme-heat-vulnerability-MAPC.prj crs=wgs84 -o format=geojson 20191125_extreme-heat-vulnerability-MAPC-WGS84.json
```

Specifying `from=20191125_extreme-heat-vulnerability-MAPC.prj` ensures the tool knows what projection we are transforming from. `crs=wgs84` tells us to use WGS84 as the target projection. To speed things up you will want to pick a projection that works with the area you are showing on your webpage. There are [websites you can look your options up on](https://epsg.io).

You can explore more output options for `mapshaper` by typing:

```
mapshaper -h o
```

As you try to manipulate geospatial data with `mapshaper` accessing the documentation by typing `mapshaper -h` will give you the information you need to handle different situations that arise with geospatial data. You can also read the online [Mapshaper documentation](https://github.com/mbloch/mapshaper/wiki/Command-Reference) for additional context.

At the end of this step we have a GeoJSON file that is pre-projected in a way that makes sense for the part of the world we are going to show, in this case the Massachusetts State Plane. We also saw we could change it to WGS84 and executed a command to create a GeoJSON file with that projection.

## Making our Projection Fit the Webpage
The second step to making our data fit the webpage properly is to use `geoproject` to translate our planar projection (already in Massachusetts State Plane) to be sized and positioned properly:

```
geoproject 'd3.geoIdentity().reflectY(true).fitSize([900, 700], d)' < 20191125_extreme-heat-vulnerability-MAPC.json > 20191125_extreme-heat-vulnerability-MAPC-projected.json
```

The `geoproject` command line tool comes from the `d3-geo-projection` package we installed earlier. We use [`geoIdentity()`](https://github.com/d3/d3-geo/blob/master/README.md#geoIdentity) because we do not want `geoproject` to change our projection, we already set that with `mapshaper` in the previous step. If we did not use mapshaper and had GeoJSON in WGS84 we could use `geoproject` to change our projection by replacing `geoIdentity()` with something like `geoConicEqualArea().parallels([34, 40.5]).rotate([120, 0])`. A list of projections that can be used here are available at [d3-stateplane](https://github.com/veltman/d3-stateplane).

We then append `reflectY(true)` because our map from `mapshaper` was upside down and we want to display it in the usual way. Finally we use `fitSize([900, 700], d)` because the target SVG element is going to have a width of 900 pixels and length of 700 pixels. We include the `d` as an argument to `fitSize()` so that we are providing `fitSize()` with the geometry we are changing. It is unclear why `reflectY()` does not need this argument but `fitSize()` does, but it is important for `fitSize()` to work. An example of a target SVG element that this map will be appended to is below.

```
<html>
	<body>
		<svg class="climate-map" viewBox="0 0 900 700"></svg>
	</body>
</html>
```

Knowing what size our target SVG element is, we have now resized our GeoJSON to fit the page.

## Converting to TopoJSON to save file size
Finally we output our data into TopoJSON to reduce the file size of our JSON being sent to the client. The [advantage of TopoJSON is that neighboring polygons can share a line](https://bost.ocks.org/mike/map/#converting-data). So if you have lots of neighboring polygons you significantly reduce the number of lines that are stored and need to be drawn. You can convert the output of `geoproject` to TopoJSON with:

```
mapshaper -i 20191125_extreme-heat-vulnerability-MAPC-projected.json -o format=topojson MAPC_heat_ma_projection_topojson.json
```

The `-i 20191125_extreme-heat-vulnerability-MAPC-projected.json` specifies the input is from the GeoJSON file `20191125_extreme-heat-vulnerability-MAPC-projected.json`. `-o format=topojson MAPC_heat_ma_projection_topojson.json` specifies the output format is TopoJSON and the filename of the TopoJSON file.

## Displaying Pre-Projected TopoJSON in the Browser
In previous D3.js tutorials you were likely used to setting a projection in the browser such as:

```
const projection = d3.geoAlbers()
  .scale(120000)
  .rotate([71.057, 0])
  .center([-0.021, 42.38])
  .translate([960 / 2, 500 / 2]);

const path = d3.geoPath().projection(projection);
```

You can [see this in context at MAPC's Perfect Fit Parking map](https://github.com/MAPC/perfect-fit/blob/master/assets/javascripts/parking_site_map.js#L1-L5). Since we have pre-projected this step is no longer necessary. You now have a pre-projected TopoJSON file. Where you used to set a projection in the path in the browser javascript, you can now set the path projection to null:

```
const path = d3.geoPath().projection(null);
```

In the first code block in this section the browser has the responsibility for taking GeoJSON that is stored in the standard WGS84 coordinate system and transforming it into a projection that usefully displays the map on the page. As you might recall from earlier, the advantage of using the browser to project your GeoJSON is you can keep your source GeoJSON in the more standard WGS84 coordinate system.[^2] The disadvantage is that your browser has to do some complicated calculations, so if you have lots of polygons your browser might fail or take a long time to do it. Since we pre-projected our TopoJSON, we can use a null projection.

## The Final Command
Combining our knowledge of these steps we can now take a single shapefile and convert it to a TopoJSON file that is pre-projected for display in the browser using the following combined command:

```
mapshaper 20191125_extreme-heat-vulnerability-MAPC.shp -o format=geojson - | geoproject 'd3.geoIdentity().reflectY(true).fitSize([900, 700], d)' | mapshaper -i - -o format=topojson MAPC_heat_ma_projection_topojson.json
```

In `mapshaper` using a dash `-` instead of a filename with the `-i` and `-o` arguments directs input and output to the terminal (otherwise known as `STDIN` and `STDOUT`). This allows you to skip creating files between the execution of each command. Instead the pipe `|` takes the input of one command and sends it to the next command.

[^1]: Mike Bostock shares in [this Medium response](https://medium.com/@mbostock/your-data-is-already-projected-so-the-simplest-thing-to-do-is-to-use-the-existing-projection-86cb49a9a923) that if your data arrives already projected properly then you do not need to change its projection in the browser.
[^2]: Most web maps [store their GeoJSON data in EPSG 4326 (a.k.a. WGS84) coordinate system and then project it in EPSG 3857 (a.k.a. web mercator) projection](https://lyzidiamond.com/posts/4326-vs-3857). The GeoJSON specification says [you should store your data in EPSG 4326 (a.k.a. WGS 84)](https://macwright.org/2015/03/23/geojson-second-bite.html#projections).



