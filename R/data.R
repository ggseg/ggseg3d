## Mesh data ----
#' Desikan-Killiany Cortical Atlas
#'
#' Mesh data for the Desikan-Killiany Cortical atlas,
#' with 40 regions in on the cortical surface of the brain.
#'
#' A nested tibble for all available surfaces and hemispheres
#'
#' @docType data
#' @name dk_3d
#' @usage data(dk_3d)
#' @keywords datasets
#' @family ggseg3d_atlases
#'
#' @references Fischl et al. (2004) Cerebral Cortex 14:11-22
#' (\href{https://academic.oup.com/cercor/article/14/1/11/433466}{PubMed})
#'
#' @format A tibble with 4 observations and a nested data.frame
#' \describe{
#'   \item{surf}{type of surface (`inflated` or `white`)}
#'   \item{hemi}{hemisphere (`left`` or `right`)}
#'   \item{data}{data.frame of necessary variables for plotting
#'   }
#'
#'   \item{atlas}{String. atlas name}
#'   \item{roi}{numbered region from surface}
#'   \item{annot}{concatenated region name}
#'   \item{label}{label `hemi_annot` of the region}
#'   \item{mesh}{list of meshes in two lists: vb and it}
#'   \item{acronym}{abbreviated name of annot}
#'   \item{lobe}{lobe localization}
#'   \item{region}{name of region in full}
#'   \item{colour}{HEX colour of region}
#' }
#' @examples
#' data(dk_3d)
"dk_3d"


#' FreeSurfer automatic subcortical segmentation of a brain volume
#'
#' Coordinate data for the subcortical parcellations implemented
#' in FreeSurfer.
#'
#' @docType data
#' @name aseg_3d
#' @usage data(aseg_3d)
#' @family ggseg3d_atlases
#'
#' @keywords datasets
#'
#' @references Fischl et al., (2002). Neuron, 33:341-355
#' (\href{https://pubmed.ncbi.nlm.nih.gov/11832223/}{PubMed})
#'
#' @format A tibble with 4 observations and a nested data.frame
#' \describe{
#'   \item{surf}{type of surface (`inflated` or `white`)}
#'   \item{hemi}{hemisphere (`left`` or `right`)}
#'   \item{data}{data.frame of necessary variables for plotting
#'   }
#'
#'   \item{atlas}{String. atlas name}
#'   \item{roi}{numbered region from surface}
#'   \item{annot}{concatenated region name}
#'   \item{label}{label `hemi_annot` of the region}
#'   \item{mesh}{list of meshes in two lists: vb and it}
#'   \item{region}{name of region in full}
#'   \item{colour}{HEX colour of region}
#' }
#'
#' @examples
#' data(aseg_3d)
"aseg_3d"
