* CH 11 - SURVIVAL AND EVENT-COUNT MODELS
* SURVIVAL TIME DATA

cd "C:\Users\jcf2d\Documents\stata_materials\data"
infile case time aids age using aids.raw, clear
label variable case "Case ID number"
label variable time "months since HIV diagnosis"
label variable aids "developed aids symptomes"
label variable age "age in years"
label data "AIDS (Selvin 1995:453)"
compress

stset time, failure(aids) id(case)
save aids1

