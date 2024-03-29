% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{dk_3d}
\alias{dk_3d}
\title{Desikan-Killiany Cortical Atlas}
\format{
A tibble with 4 observations and a nested data.frame
\describe{
  \item{surf}{type of surface (`inflated` or `white`)}
  \item{hemi}{hemisphere (`left`` or `right`)}
  \item{data}{data.frame of necessary variables for plotting
  }

  \item{atlas}{String. atlas name}
  \item{roi}{numbered region from surface}
  \item{annot}{concatenated region name}
  \item{label}{label `hemi_annot` of the region}
  \item{mesh}{list of meshes in two lists: vb and it}
  \item{acronym}{abbreviated name of annot}
  \item{lobe}{lobe localization}
  \item{region}{name of region in full}
  \item{colour}{HEX colour of region}
}
}
\usage{
data(dk_3d)
}
\description{
Mesh data for the Desikan-Killiany Cortical atlas,
with 40 regions in on the cortical surface of the brain.
}
\details{
A nested tibble for all available surfaces and hemispheres
}
\examples{
data(dk_3d)
}
\references{
Fischl et al. (2004) Cerebral Cortex 14:11-22
(\href{https://academic.oup.com/cercor/article/14/1/11/433466}{PubMed})
}
\seealso{
Other ggseg3d_atlases: 
\code{\link{aseg_3d}}
}
\concept{ggseg3d_atlases}
\keyword{datasets}
