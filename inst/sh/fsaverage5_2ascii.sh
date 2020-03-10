#!/bin/sh

# Print usage if less than two arguments given
if [ "$#" -ne 1 ]; then
cat <<EOU
Batch convert surface and DPV (curvature) files from a given
subject to ASCII format. FreeSurfer must be correctly
configured in the memory, with both \${FREESURFER_HOME}
and \${SUBJECTS_DIR} variables set.

Usage:
  fsaverage5_2ascii <outdir>

  _____________________________________
Anderson M. Winkler
Yale University / Institute of Living
Jan/2011 (original version)
Jul/2013 (this version)
http://brainder.org

adapted by: Athanasia Monika Mowinckel for ggseg3d R-package
(March/2020)
EOU
exit
fi

# outdir
OUTDIR=$1
mkdir -p $OUTDIR

# Hemispheres
HEMI="lh rh"

# Surfaces (up to v5.3.0; increase the list as needed for future versions)
SURF="inflated orig pial sphere"

# Simplify a bit with a shorter variable
SDIR=${SUBJECTS_DIR}/fsaverage5

# For each hemisphere
for h in ${HEMI} ; do

# For each surface file
for s in ${SURF} ; do

if [ -e ${SDIR}/surf/${h}.${s} ] ; then
echo "${SDIR}/surf/${h}.${s} -> ${OUTDIR}/${h}.${s}.srf"
${FREESURFER_HOME}/bin/mris_convert ${SDIR}/surf/${h}.${s} ${OUTDIR}/${h}.${s}.asc
fi # end if surf exists
done # done s

done # done h



