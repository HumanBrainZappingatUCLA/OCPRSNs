#!/bin/bash


#$ -pe shared 2
#$ -l h_rt=24:00:00,h_data=32G

export NO_FSL_JOBS=true
. /u/local/Modules/default/init/modules.sh
module use /u/project/CCN/apps/modulefiles
module use /u/project/CCN/apps/fsl # /6.0.4/

module load fsl/6.0.4


while IFS= read sub ; do
  timestamp=$(date +"%D %T")
  echo "Begin ${sub} ${timestamp}"

  while IFS2= read roimask ; do
    roiname=$(basename $roimask)
    roiname="${roiname%%.*}"

    if [ ! -d  "/u/project/petersen/data/ocs/bids/derivatives/FC/SCA/OneSamp/${roiname}" ]; then
      mkdir -p -m 770 /u/project/petersen/data/ocs/bids/derivatives/FC/SCA/OneSamp/${roiname}
    fi
    if [ -f "/u/project/petersen/data/ocs/bids/derivatives/FC/SCA/$sub/A/${sub}_SCAr_A_${roiname}.nii.gz" ]; then
      if [ -f "/u/project/petersen/data/ocs/bids/derivatives/FC/SCA/$sub/B/${sub}_SCAr_B_${roiname}.nii.gz" ]; then
        file1=/u/project/petersen/data/ocs/bids/derivatives/FC/SCA/$sub/B/${sub}_SCAr_B_${roiname}.nii.gz
        file2=/u/project/petersen/data/ocs/bids/derivatives/FC/SCA/$sub/A/${sub}_SCAr_A_${roiname}.nii.gz
        # B-A
	output_file1=/u/project/petersen/data/ocs/bids/derivatives/FC/SCA/OneSamp/${roiname}/${sub}_SCA_B-A_${roiname}.nii.gz
        # A-B
	output_file2=/u/project/petersen/data/ocs/bids/derivatives/FC/SCA/OneSamp/${roiname}/${sub}_SCA_A-B_${roiname}.nii.gz
	echo "Merging B-A"
	fslmaths $file1 -sub $file2 $output_file1
	echo "Merging A-B"
	fslmaths $file2 -sub $file1 $output_file2
      fi
    fi
  done < $2
done < $1
echo "fslmath done"

inmask_abs_path=$PWD/$2
cd /u/project/petersen/data/ocs/bids/derivatives/FC/SCA/OneSamp/

while IFS= read roimask ; do
  roiname=$(basename $roimask)
  roiname="${roiname%%.*}"
  if [ ! -d "G2" ]; then
    mkdir -m 770 G2
  fi
  echo "$roiname"
  fslmerge -t G2/GroupSCA_${roiname}_B-A.nii.gz ${roiname}/*B-A*
  fslmerge -t G2/GroupSCA_${roiname}_A-B.nii.gz ${roiname}/*A-B*
  randomise -i G2/GroupSCA_${roiname}_B-A.nii.gz -o G2/GroupSCA_${roiname}_B-A_OneSampT -1 -v 5 -T
  randomise -i G2/GroupSCA_${roiname}_A-B.nii.gz -o G2/GroupSCA_${roiname}_A-B_OneSampT -1 -v 5 -T
done < $inmask_abs_path

echo Job Done
