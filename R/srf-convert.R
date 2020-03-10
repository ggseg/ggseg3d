

srf2asc <- function(infile, outfile, verbose = TRUE){

  k <- strsplit(outfile, "\\.")[[1]]
  if(k[length(k)] != "asc"){
    cat("outfile must end with '.asc'")
    stop(call.=FALSE)
  }

  fscmd <- paste0(freesurfer::get_fs(), "mris_convert")

  cmd <-  paste(fscmd,
                infile,
                outfile
  )
  j <- system(cmd, intern=!verbose)

  readLines(outfile)
}

asc2ply <- function(path, outfile = gsub("\\.asc", ".ply", path)){
  srf_file <- readLines(path)

  nfo <- as.numeric(strsplit(srf_file[2], " ")[[1]])
  names(nfo) <- c("vertex", "face")

  srf_file <- srf_file[c(-1, -2)]
  srf_data <- utils::read.table(text = srf_file)

  vert <- srf_data[1:nfo["vertex"],1:3]
  vert <- unname(apply(vert, 1, paste, collapse = " "))

  face <- cbind(3, srf_data[(nfo["vertex"]+1):nrow(srf_data),1:3])
  face <- unname(apply(face, 1, paste, collapse = " "))

  ply_head <- c(
    "ply",
    "format ascii 1.0",
    paste("element vertex", nfo["vertex"]),
    "property float x",
    "property float y",
    "property float z",
    paste("element face", nfo["face"]),
    "property list uchar int vertex_index",
    "end_header"
  )


  ply <- c(ply_head, vert, face)
  writeLines(ply, outfile)

  return(ply)
}


srf2ply <- function(infile,
                    outfile = paste(infile, ".ply"),
                    verbose = TRUE){

  basefile <- gsub("\\.ply", "", outfile)

  srf <- srf2asc(infile, paste0(basefile, ".asc"), FALSE)
  ply <- asc2ply(paste0(basefile, ".asc"), outfile)

  return(ply)
}

ply2atlas <- function(path){
  brain <- geomorph::read.ply(
    path,
    ShowSpecimen = FALSE)

  brain <- tibble(surface = "inflated",
                        hemisphere = "left",
                        vertex = list(
                          as_tibble(matrix(c(brain$vb["xpts",],
                                             brain$vb["ypts",],
                                             brain$vb["zpts",]),
                                           ncol=3,
                                           dimnames=list(NULL,
                                                         c("x","y","z")))
                          )),
                        face = list(
                          as_tibble(matrix(c(brain$it[1,]-1,
                                             brain$it[2,]-1,
                                             brain$it[3,]-1),
                                           ncol=3,
                                           dimnames=list(NULL,
                                                         c("i","j","k")))
                          )
                        )
  )

  return(brain)
}

srf2atlas <- function(path){
  tmpfile <- tempfile()
  ply <- srf2ply(path, outfile = tmpfile)
  ply2atlas(tmpfile)
}

batch_srf2ply <- function(outdir,
                            hemisphere = c("rh", "lh"),
                            surface = c("orig", "pial", "inflated", "sphere"),
                            subject = "fsaverage5",
                            subject_dir = NULL,
                            verbose = TRUE){

  if(!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)
  if(is.null(subject_dir)) subject_dir <- paste0(freesurfer::fs_dir(), "/subjects/")
  subject_dir <- paste0(subject_dir, subject, "/")

  k <- list()
  i <- 0
  for(h in hemisphere){
    for(s in surface){
      i <- i + 1
      infile <- paste0(subject_dir, "surf/", h, ".", s)
      outfile <- paste0(outdir, "/", h, ".", s, ".ply")

      k[[i]] <- srf2ply(infile, outfile, verbose)
      names(k)[i] <- outfile
    } # end s
  } # end h
  return(k)
}
