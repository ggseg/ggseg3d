# ggseg3d 1.6.3
- Prepare for CRAN
- 

# ggseg3d 1.6.02
- Fix bug where installing with vignettes fail

# ggseg3d 1.6.01
- added ellipsis `...` to plotly::add_trace for people to add more arguments.  

# ggseg 1.5

## ggseg 1.5.2
* Adapted to work with dpylr 0.8.1

## ggseg 1.5.1

* Changed ggseg_atlas-class to have nested columns for easier viewing and wrangling

## ggseg 1.5

* Changed atlas.info to function `atlas_info()`
* Changed brain.pal to function `brain_pal()`
* Changed atlas.info to function `atlas_info()`
* Reduced code necessary for `brain_pals_info`
* Simplified `display_brain_pal()`
* Moved paletted of ggsegExtra atlases to ggsegExtra package

* Added a `NEWS.md` file to track changes to the package.
* Changes all `data` options to `.data` to decrease possibility of column nameing overlap
* Added compatibility with `grouped` data.frames
* Reduced internal atlases, to improve CRAN compatibility
* Added function to install extra atlases from github easily
* Changes vignettes to comply with new functionality
