# Sputnik
## Style Prototyping Utility for Mapnik

Sputnik is a quick-and-dirty way of seeing your changes to a Mapnik stylesheet reflected in real time. It provides a simple tileserver, a full-window map view, and a 'refresh' button which reloads the map using your latest stylesheet.

If you're looking for something less basic, you might want to use [Kosmtik](https://github.com/kosmtik/kosmtik) instead.

## How

Copy sputnik.html to a web-browsable directory.

Start the server on port 8000 with

    ruby sputnik.rb path_to_your.mml /path/to/directory/with/fonts_and_styles

Open sputnik.html in your web browser.

## Why

[Tilemill](https://www.mapbox.com/tilemill/) is a beautifully crafted work of wonder and does pretty much everything the Mapnik-toting cartographer could want. Sputnik is not a work of wonder, it's a messy 100-line hack. It does, however, provide a rudimentary alternative to building your own Tilemill if you want latest/hackable Carto features, use your own editor, and are not too enamoured of NodeJS.

## Installation requirements

* Ruby-Mapnik bindings
* Carto (command-line compiler, `npm install -g carto`)
* Mapnik
* obvious stuff like Ruby, a webserver, etc. etc.

### Installation

First, install `ruby`, `autoconf`, `automake`, `rubygem-cairo-devel`, `boost-devel`, `mapnik-devel`, `npm`. Then:

    npm install -g carto
    gem install rake-compiler rake
    gem install hoe rice chunky_png cairo
    gem install ruby_mapnik

## Notes

Your map location is bookmarkable, so you can return to the place you were testing yesterday.

There is a little bit of postprocessing to support [famous gravitystorm list placement hack](https://github.com/mapbox/carto/issues/238).

## To do

There should be more postprocessing to support comments and macros in the .mml. Hell yes.

Images are generated via the Mapnik::Tile class. This means no metatiling, so (a) slow, (b) label placement is not very representative of your final map.

Error-trapping would be nice.

## Development

WTFPL. Pull requests are encouraged, ideally retaining the principle of "one .rb, one .html".
