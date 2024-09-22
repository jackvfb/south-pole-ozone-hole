# Ozonesonde vertical profiles from South Pole, Antarctica

Welcome to the raw data directory associated with this project.

## Instructions

These data are published by the NOAA Global Monitoring Laboratory and can be accessed, as of this writing, using the [GML Data Finder](https://gml.noaa.gov/dv/data/).

Query the data finder as follows:

-   Category: Ozone
-   Parameter: Ozone
-   Type: Balloon
-   Frequency: Vertical Profile
-   Site: SPO

The query will connect you to a directory with `.l100` files which provide ozonesonde observations in intervals of 100 m. The complete record of ozonesonde profiles is available from 1968 - present.

**Note: If you want to reduce processing time, or if you are only interested in a particular period, you can select a subset of years of the data.**

The year is indicated in the file name after the first underscore and will match to this regular expression pattern: `"(?<=_)\\d{4}"`

## What is an ozonesonde?

> Ozonesonde:
>
> -   Ozone: Triatomic oxygen molecule (O₃) found in Earth's atmosphere
> -   Sonde: Instrument for atmospheric measurements
>
> Combined: Device for measuring ozone concentrations at various altitudes in the atmosphere.

The components of this instrument consist of:

1)  🎈 **Meteorological balloon** This carries the instrument to high altitudes, before bursting and dropping the it.

2)  🔋 **Electrochemical cell ozonesonde** The instrument itself uses a small air pump to bubble air into an electrochemical cell. The ozone in the air reacts with the cathode to produce electrical current proportional to the concentration of ozone in the air

3)  📡 **Radiosonde** This transmits ozone measurements back to a receiver station in addition to ancillary data such as temperature, humidity, and pressure.[\^2]

📈 This produces a a detailed profile of ozone concentrations it ascends and descends through the atmosphere.
