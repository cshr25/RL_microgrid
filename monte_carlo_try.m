number=10;
limitt=20;
record=zeros(number,limitt);
tic
for i=1:number
    record=bytest_local_SoC_player_number_compare_multiple(limitt);
    filename=sprintf('record_file_#%d.mat',number);
    save(filename,'record')
end
toc