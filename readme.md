# CarCharts

## Object Model
Mods are stored in the CoreData database. Everything else is in plist files which are loaded into memory at runtime.

  this is a piece of code  // test

## Performance

* Search: 445 objects, all in memory
* When groups are used both for non-filtered list and for fitlered one
  first letter 2 / 20 (sometimes 10 / 100)
  next letters .2 / 2 (only if consequent search is used)
* Without grouping - almost the same, so indexation takes almost no time.

* Modification Loading (after RM update)
   * 42 /  335 ms - plist hash loading
   * 19 /  160 ms - plist array loading
   * 00 /    x ms - json loading
   * 00 /    x ms - json loading
   * 47 /    x ms - json array loading
   * 53 /  460 ms - Modification instantiation
   * 12 /  115 ms - Modification instantiation without key parsing
   * 07 /   70 ms - indexing
   * 55 /  450 ms - load all
   * 02 /    x ms - load metadata
    
* App Initialization — 10ms : 50ms (Core Data : plist)


## Colors
  * 214 27 38 - segment control border (one of)
  * 214 18 76 : 213 24 71 - segment control default top
  * 213 28 69 - segment control default bottom
  * 213 28 75 : 214 45 65 - segment control selected top
  * 215 53 60 - segment control selected bottom
  * 215 41 61 - segment control border top half (act. light gradient)
  * 215 68 49 - segment control border bottom half

  * 220 49 90 - Done button top top
  * 220 75 88 - Done button top bottom
  * 220 85 87 - Done button bottom
  * 220 74 56 - Done button border

  * 201 05 87 - gray top
  * 206 08 80 - gray bottom
  * 210 17 58 - gray border
  * 240 00 78 - gray border 2 top
  * 000 00 59 - gray border 2 bottom

  * 000 00 45 : 000 00 15 - black segment button top
  * 000 00 00 - black segment button botom
  * 000 00 18 - black segment button border
  * 000 00 56 : 000 00 24 - black segment button divider  

  * 218.42.91-219.80.85 - ios 6 Done button t-b / mid = 218.60.85
  * 218.78.54-218.75.55 - ios 6 Done button border t-b
  * 214.22.76-215.54.56 - ios 6 Back button t-b  
  * 214.27.45-213.50.36 - ios 6 Back button border t-b  

  * 212.16.80-212.37.64 - ios 6 segment button t-b  / mid 214.29.69
  * 216.26.66-215.44.56 - ios 6 segment divider t-b  
  * 211.18.46-213.35.42 - ios 6 segment button border t-b  


### Tints
* brown hsb(30, 100, 15)
* gray  hsb(0, 0, 20)
* blue  hsb(210, 100, 25)


## Model

* Mod         - RO, 2500 objects, many fields
* Model       - RO,  250 objects, few fields
* Brand       - RO,   50 objects, few fields
* Parameter   - RO,   20 objects, few fields
* ModSet      - RW, 0-20 objects, 2 fields, one 0-3kb clob
* Comparison - VT,    1 object at time, lots of subobjects

Conclusion

* Mods should be stored in the r/o database, because it's too time consuming to load them all at once
  and storing them all in memory is a bit too much.
* ModSets should be stored in the r/w database.
* Everything else can be loaded from code / data files.


## Graphics

### Convert SVG icon
```
  rake icon_from_svg file=ico-chart size=60
  convert -background transparent ico-bar.svg -resize 60x60 ico-bar.png
  convert ico-bar.png -background white -flatten ico-bar-2.png
```

### Fonts
```
  convert -list font | grep Font:
```

## Long Model Names

Dodge RAM                  - 51
Mitsubishi Lancer Ralliart – 50
Audi A6 allroad quattro    - 48
MB GLK                     - 47  


## Icon Sources

icon8 — require to mention them on the AppStore page.
pixeden — no atribution
cupertinoline — no atribution

my tab-chart 
open tab-star
open cell-google
pixeden tab-checkbox 
pixeden tab-car
pixeden tab-filter 
icon8 tab-funnel 
icon8 bar-filter
misc bar-expand
cupertinoline bar-gear


## Logo Font
  
  ITC Blair Medium 14pt (small-caps, commersial)
  Orbitron Medium 17pt (geometric, open-source)

## Other

  * alfa_romeo-giulietta-2010-hatch_5d--1.4g-120ps-MT-FWD is loaded from a newer site

  ~/Library/Developer/CoreSimulator/Devices/7A8F9071-A067-4F1E-8306-DFBE2C80A532/data/Containers/Data/Application/


## Missing Models

  * Hummer


## Internationalization
US
 MPG gal lbs ft3 in
 Displacement: L & cu. in.
 Trunk volume
 Track Width / Tread / Front Track / Rear Track
 jaguar.uk Front Track Rear Track
 4WD 2WD
 Fuel System: some kind of injection

  torque Ft. Lbs
  Lb-Ft lb.ft
  cargo colume cargo cu.ft
  fuel gal

  3.6-Liter V6 24-Valve VVT Engine

UK mpg mph | kg litre mm kW HP Nm | lb-ft bhp 
  Everybody uses MPG and MPH
  PS is used a lot
  toyota and other don't use in, lb, gal at all

 CO2 — g/km
 38.7 mpg (combined)
 litre, kg
 0-62 mph/s
 max speed mph
 fuel type: pertol diesel
 KW PS Nm @ rpm
 size: mm
 torque lb-ft @ rpm 
 
 fuel: litre / UK gallons
 suzuki repeats all in inches and pounds
 landrover.co.uk: litre HP Nm cc mph 117  0-60mph, CO2 162 g/km,  40.4 mpg (urban combined), 4,555mm, 2,200kg


cc to cu. in. 16.387
mm to inch 25.4
Nm to lb-ft 0.74


Number of Cylinders / No. of Cylinders
Number of Valves
Max Power
Max Torques
Overall length
Max Speed

10 get the initial files manually
  generations.html: <audi-a4-2011> <ford-focus-2014> <bmw-3-2014>, ...
11 parse to URLs
  generation-bodies-first.yaml: audi-a4-2011: /audi/a3/123456/specs, ...
12 load initial bodytype
  generations/mark-model-year.html ...
13 parse initial bodytype for other bodytypes
  generation-bodies-other.yaml: audi-a4-2011-hatch3d: /audi/a3/123456/456789/specs, ...
14 load other bodytypes
  generations/mark-model-year-bodytype.html ...
20 parse bodytypes (both) for mod URLs
  mods.yaml: bmw-3-2014-sedan--1.8T-200ps-AT-FWD => /bmw/1/123456/456789/654987 (or name file like bmw-3-6123456-6789654)
30 load mods
  mods/*.html
40 parse mods



### Screenshots

  
  
  
### Competition

  CarBase — 1$
    https://www.appannie.com/apps/ios/app/898424389/
  CarCompare — free
  Automobile Specs - Murat Tanriover - 1$
  Ojuu — html shit




### Copy

CarCharts is a simple & powerful app to compare car models visually.
  
— Compare any number of cars simultaneously.
— Specification database contains more than a 1 000 models with more than 10 000 bodystyle/engine variations. The database includes the majority of car models sold in Europe in recent years.
— More than 25 comparison parameters.
— Support metric, UK or US unit systems.
— App works offline, no internet connection required.
— Use iPhone for adhoc comparisons and iPad for large comparisons with tons of models.
— View specs and photos.


### Links

https://auto.yandex.ru/search?year_from=2005&year_to=2011&marks-tab=all&mark=audi&mark=alfa_romeo&mark=alpina&mark=aston_martin&mark=acura&mark=austin&mark=ac&mark=alpine&mark=asia&mark=am_general&mark=autobianchi&mark=ariel&mark=bmw&mark=buick&mark=byd&mark=bentley&mark=brilliance&mark=brabus&mark=bristol&mark=bugatti&mark=chevrolet&mark=citroen&mark=chrysler&mark=cadillac&mark=chery&mark=cizeta&mark=daihatsu&mark=dodge&mark=daewoo&mark=datsun&mark=dacia&mark=daimler&mark=daf&mark=delorean&mark=ecomotors&mark=e_car&mark=ford&mark=fiat&mark=ferrari&mark=faw&mark=foton&mark=great_wall&mark=geely&mark=gmc&mark=honda&mark=hyundai&mark=holden&mark=hafei&mark=hummer&mark=isuzu&mark=infiniti&mark=invicta&mark=iveco&mark=jaguar&mark=jeep&mark=jac&mark=jensen&mark=jmc&mark=kia&mark=koenigsegg&mark=ktm&mark=lancia&mark=lexus&mark=lamborghini&mark=lincoln&mark=land_rover&mark=lotus&mark=lifan



mogrify -path . -resize 80x80 -format png *.png

### Site

  http://www.roundpic.com/


### Keywords
cars,comparison,compare,chart,best,specs,models,fastest,tool,size,side,small
