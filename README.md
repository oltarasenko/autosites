# Autosites

A small example which demonstrates how to use Crawly in order to extract
data from JS based website. 

Uses meeseeks, as a parses and Splash.

## Getting started
 1. Start splash Server locally: `docker run -it -p 8050:8050 scrapinghub/splash --max-timeout 300` 
 2. Run the iex: `mix deps.get && iex -S mix`
 3. Start the spider itself `Crawly.Engine.start_spider(AutotraderCoUK)`
