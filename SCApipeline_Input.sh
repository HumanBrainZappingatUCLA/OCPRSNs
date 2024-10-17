#!/bin/bash


#$ -pe shared 2
#$ -l h_rt=24:00:00,h_data=32G


export NO_FSL_JOBS=true
. /u/local/Modules/default/init/modules.sh
module use /u/project/CCN/apps/modulefiles
module use /u/project/CCN/apps/fsl # /6.0.7.1/

module load fsl # /6.0.47.1
module load matlab/R2020b # /R2022b


while IFS= read subid_and_group ; do
  subid="$(cut -d':' -f1 <<< "$subid_and_group")"
  group="$(cut -d':' -f2 <<< "$subid_and_group")"
  sub="${subid:0:-1}"

  timestamp=$(date +"%D %T")
  echo "Begin ${subid} ${timestamp}"

  while IFS2= read roimask ; do
    roiname=$(basename $roimask)
    roiname="${roiname%%.*}"
    echo "Processing ROI ${roiname}"

    if [ ! -d /u/project/petersen/data/ocs/bids/derivatives/FC/SCA/$sub ]; then
      mkdir -m 775 /u/project/petersen/data/ocs/bids/derivatives/FC/SCA/$sub
    fi
    if [ ! -d /u/project/petersen/data/ocs/bids/derivatives/FC/SCA/$sub/A ]; then
      mkdir -m 775 /u/project/petersen/data/ocs/bids/derivatives/FC/SCA/$sub/A
      mkdir -m 775 /u/project/petersen/data/ocs/bids/derivatives/FC/SCA/$sub/B
    fi

    input_file=/u/project/petersen/data/ocs/bids/derivatives/FSLpipeline/sub-$subid/Preproc.feat/sub-${subid}_denoised_realign_func_data_nonaggr.nii.gz
    mask_file=$roimask
    if [ "$group" = "A" ]; then
      fslmeants -i $input_file -o /u/project/petersen/data/ocs/bids/derivatives/FC/SCA/$sub/A/${sub}_${roiname}.txt -m $mask_file
    else
      fslmeants -i $input_file -o /u/project/petersen/data/ocs/bids/derivatives/FC/SCA/$sub/B/${sub}_${roiname}.txt -m $mask_file
    fi
  done < $2

  timestamp=$(date +"%D %T")
  echo "End ${subid} ${timestamp}"
done < $1

echo "Starting Matlab scripts"
matlab -nojvm -nodisplay -nosplash -nodesktop -r "RunSCA_OCS;quit"