== Performance

* Search: 445 objects, all in memory
* When groups are used both for non-filtered list and for fitlered one
  first letter 2 / 20 (sometimes 10 / 100)
  next letters .2 / 2 (only if consequent search is used)
* Without grouping - almost the same, so indexation takes almost no time.

* Modification Loading
   (after RM update)
   42 /  335 ms - plist hash loading
   19 /  160 ms - plist array loading
    x /    x ms - json loading
   47 /    x ms - json array loading
   53 /  460 ms - Modification instantiation
   12 /  115 ms - Modification instantiation without key parsing
    7 /   70 ms - indexing
   55 /  450 ms - load all
    2 /    x ms - load metadata

== Colors
  214 27 38 - segment control border (one of)
  214 18 76 : 213 24 71 - segment control default top
  213 28 69 - segment control default bottom
  213 28 75 : 214 45 65 - segment control selected top
  215 53 60 - segment control selected bottom
  215 41 61 - segment control border top half (act. light gradient)
  215 68 49 - segment control border bottom half

  220 49 90 - Done button top top
  220 75 88 - Done button top bottom
  220 85 87 - Done button bottom
  220 74 56 - Done button border
  
  201 05 87 - gray top
  206 08 80 - gray bottom
  210 17 58 - gray border
  240 00 78 - gray border 2 top
  000 00 59 - gray border 2 bottom

  000 00 45 : 000 00 15 - black segment button top
  000 00 00 - black segment button botom
  000 00 18 - black segment button border
  000 00 56 : 000 00 24 - black segment button divider  

  218.42.91-219.80.85 - ios 6 Done button t-b / mid = 218.60.85
  218.78.54-218.75.55 - ios 6 Done button border t-b
  214.22.76-215.54.56 - ios 6 Back button t-b  
  214.27.45-213.50.36 - ios 6 Back button border t-b  

  212.16.80-212.37.64 - ios 6 segment button t-b  / mid 214.29.69
  216.26.66-215.44.56 - ios 6 segment divider t-b  
  211.18.46-213.35.42 - ios 6 segment button border t-b  

