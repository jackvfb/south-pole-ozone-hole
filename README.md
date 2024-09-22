# Reproducing a cross section of the Antarctic ozone hole

Welcome to the repository for my reproducible data analysis project.

**The objective of this project is to create a cross section of the Antarctic ozone hole using ozone sonde vertical profiles**, emulating [figures](https://gml.noaa.gov/dv/spo_oz/contours/index.php) published by the NOAA Global Monitoring Laboratory – Ozone and Water Vapor division.

## Notebook 📖

**Visit the project notebook for a final summary of the project, styled after a typical research paper.**

## Contents

This is a summary of the key contents of the repository and what they do.

- 📄`functions.R`
The core methodology and logic of the project, encapsulated in these functions.

- 📄`_targets.R`
The pipeline that performs the analysis by calling the functions above.

- 📂`data/`
This contains the raw data, with instructions on how to access it in `data/README.md`

- 📂`renv/`
Along with `renv.lock` this captures the requirements that are needed to set up the environment.

## Instructions

These instructions apply if you want to execute the analysis pipeline on your own machine, for example if you wanted to examine the model or processed data.

1) You must have R and R Studio installed.

2) Download the raw data into the `data/` directory following the instructions provided in `data/README.md`

3) Open `south-pole-ozone-hole.Rproj` to open the project in R Studio.

4) Follow prompts to install the required packages.

5) In the R Console, type the following command: `targets::tar_make()`

❗Expect several hours of processing time (\~3 hrs on my machine)

6) When the pipeline finishes, you can access any of the targets using the command `targets::tar_load(target_name)`