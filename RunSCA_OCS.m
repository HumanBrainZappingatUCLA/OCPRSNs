subs =readlines('/u/project/petersen/data/ocs/bids/scripts/PostProc/SCA_ocs/SCA_participants.txt');
basedir='/u/project/petersen/data/ocs/bids/derivatives/FC/SCA';
imagedir='/u/project/petersen/data/ocs/bids/derivatives/FSLpipeline';
for i = 1:size(subs,1)
    if isempty(subs(i)) || all(isspace(subs(i)))
        continue;
    end
    splitted_subs=split(subs(i), ':');
    subid=splitted_subs(1);
    group=splitted_subs(2);
    sub=convertStringsToChars(subid);
    sub=sub(1:end-1);
    disp('Processing ' + subid)

    savedir=fullfile(basedir,sub,group);
    imagefile=fullfile(imagedir,strcat('sub-',subid),'Preproc.feat',strcat('sub-',subid,'_denoised_realign_func_data_nonaggr.nii.gz'));
    tsfiles1=dir(fullfile(savedir,'*.txt'));
        
    for k = 1:size(tsfiles1,1)
        tsfiles=tsfiles1(k).name;
        roi1=split(tsfiles,'_');
        roi2=split(roi1{2},'.');
        roiname=roi2{1};
        roifile=fullfile(savedir, tsfiles);
        disp('Processing ROI file ' + roifile)

        SCA_OCS(roifile,imagefile,subid,savedir,roiname,group)
    end
end
