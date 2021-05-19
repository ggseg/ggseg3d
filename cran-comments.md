## Test environments
* local R installation, R 4.0.2
* ubuntu 16.04 (on travis-ci), R 4.0.2
* win-builder (devel)
* GitHub R CMD CHECK
  - {os: windows-latest, r: 'release'}
  - {os: macOS-latest,   r: 'release'}
  - {os: ubuntu-20.04,   r: 'release', rspm: "https://packagemanager.rstudio.com/cran/__linux__/focal/latest"}
  - {os: ubuntu-20.04,   r: 'devel',   rspm: "https://packagemanager.rstudio.com/cran/__linux__/focal/latest"}

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
* Data for this package is quite large (4Mb), since it contains mesh information for two default datasets. We've compressed as much as we can, and want to keep both datasets as these are standard brain atlases in the field and the two that most users will ever use. 
* A couple of the examples take a little longer than usual to run, but I'd rather not wrap them in dontrun, as they're still not long all in all.
