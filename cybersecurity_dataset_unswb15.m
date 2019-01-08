%% Create UNSWB SET 
clear all;
close all hidden;

s = ["datasets/cybersecurity/UNSW_NB15_testing-set.csv", "datasets/cybersecurity/UNSW_NB15_training-set.csv"]; %The names are the other way around

opts = detectImportOptions(char(s(1)));
T0 = readtable(char(s(1)),opts);
opts = detectImportOptions(char(s(2)));
T1 = readtable(char(s(2)),opts);
T = [T0; T1];

binfeat = [];
for i = 1:size(T,2)
    if i == 1 || i == (size(T,2)-1) %% ADD IP???
        continue;
    end

    M = table2array(T(:,i));

    if iscell(M)
        ue = string(unique(M));
        for j = 1:length(ue)
          new_M(strcmp(string(M),(ue(j)))) = j-1;    
        end
        M = new_M;
    end

    m = min(M(M~=0));
    m = 1/m;
    if m > 1
        M = M*m;
    end

    b = ceil(log2(double(max(M))+1));
    feat = de2bi(uint32(M),b,'left-msb');
    binfeat = [binfeat feat];
end

binfeat = binfeat(randperm(length(binfeat)),:);
pause(2.0);
id  = round(2*length(binfeat)/3);
id6 = round(2*length(binfeat)/3/6);
infeat_train = binfeat(1:id-id6,:);
infeat_valid = binfeat((id-id6+1):id,:);
infeat_test  = binfeat(id+1:end,:);

infeat_train = infeat_train(1:round(size(infeat_train,1)/10),:);
infeat_valid = infeat_valid(1:round(size(infeat_valid,1)/10),:);
infeat_test  = infeat_test(1:round(size(infeat_test,1)/10),:);

dataset_size = [length(infeat_train)+length(infeat_valid)+length(infeat_test) length(infeat_train) length(infeat_valid) length(infeat_test)]

fileID = fopen('formatted_datasets/cybersecurity/fds_unswb15_train.txt','w');
for i = 1:size(infeat_train,1)
    i/size(infeat_train,1)
    for j = 1:size(infeat_train,2)
        fprintf(fileID,'%d ',infeat_train(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);

fileID = fopen('formatted_datasets/cybersecurity/fds_unswb15_valid.txt','w');
for i = 1:size(infeat_valid,1)
    i/size(infeat_valid,1)
    for j = 1:size(infeat_valid,2)
        fprintf(fileID,'%d ',infeat_valid(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);

fileID = fopen('formatted_datasets/cybersecurity/fds_unswb15_test.txt','w');
for i = 1:size(infeat_test,1)
    i/size(infeat_test,1)
    for j = 1:size(infeat_test,2)
        fprintf(fileID,'%d ',infeat_test(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);
