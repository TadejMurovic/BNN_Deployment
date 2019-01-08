clear all;
close all;

%M = csvread('C:\Users\fg7c6w\Downloads\SUSY\SUSY.csv');
%Mnew = M(1:50000,:);
%save('susy_dataset_tmp_array','Mnew');


M = load('susy_dataset_tmp_array');
M = M.Mnew;

labels = M(:,1);
features = M(:,2:end);


% intval = floor(max(abs(features)));
% intbit = floor(log2(intval))+1;
% intbit(intbit==-inf) = 0;
% s      = abs(sign(floor(min((features)))));
% 
% % MANUALLY SELECT NUMBER OF BITS = 300
% endbits = 500;
% 
% for i = 1:100
%     bitsum = 0;
%     outvec = [];
%     for j = 1:size(features,2)
%         if s(j) == 1
%             fpfeatures(:,j) = num2fixpt(features(:,j), sfix(1+intbit(j)+(i-1)), 2^-(i-1));
%             bitsum = bitsum + 1+intbit(j)+(i-1);
%         else
%             fpfeatures(:,j) = num2fixpt(features(:,j), ufix(intbit(j)+(i-1)), 2^-(i-1));
%             bitsum = bitsum + intbit(j)+(i-1);
%         end
%         signvec = fpfeatures(:,j) < 0;
%         bitvec  = fpfeatures(:,j) * 2^(i-1);
%         bitvec  = de2bi(abs(bitvec),'left-msb',1+intbit(j)+(i-1));
%         bitvec(signvec) = ~bitvec(signvec);
%         outvec = [outvec bitvec];
%     end
%     error(i) = max(max(sqrt(abs(features.^2-fpfeatures.^2))));
%     bits(i) = bitsum;
%     if bitsum >= endbits
%         break;
%     end
% end
% 
% figure();
% plot(bits,error);
% 

endbits = 300;
itid = 0;
for it = 0.1:-0.001:0.001
    itid = itid + 1;
    clear intval
    clear intbit
    clear err
    clear finerr
    bitvec = [];
    for i = 1:size(features,2)
        f = abs(features(:,i));
        s = features(:,i) < 0;   
        for b = 0:50     
            intval = floor(f*2^b);
            intbit(i) = max(floor(log2(intval))+1 + 1);
            err(b+1) = max(sqrt((f).^2 - ((intval/(2^b)).^2)));
            if err(end) < it
                break;
            end
        end
        finerr(i) = err(end);
        s(intval == 0) = 0;
        clear err

        bitval    = de2bi(intval,'left-msb',intbit(i));
        bitval(s,:) = ~bitval(s,:);
        bitval    = bi2de(bitval,'left-msb');
        bitval(s,:) = bitval(s,:) + 1;
        bitval    = de2bi(bitval,'left-msb',intbit(i));
        bitvec = [bitvec bitval];
    end
    sumbits(itid) = sum(intbit);
    if sumbits(itid) > endbits
        break;
    end
end
figure(10)
plot(sumbits);

outvec = [bitvec labels];
binfeat = outvec;


binfeat = binfeat(randperm(length(binfeat)),:);
pause(2.0);
id  = round(2*length(binfeat)/3);
id6 = round(2*length(binfeat)/3/6);
infeat_train = binfeat(1:id-id6,:);
infeat_valid = binfeat((id-id6+1):id,:);
infeat_test  = binfeat(id+1:end,:);

infeat_train = infeat_train(1:round(size(infeat_train,1)),:);
infeat_valid = infeat_valid(1:round(size(infeat_valid,1)),:);
infeat_test  = infeat_test(1:round(size(infeat_test,1)),:);


fileID = fopen('formatted_datasets/hep/fds_susy_train.txt','w');
for i = 1:size(infeat_train,1)
    i/size(infeat_train,1)
    for j = 1:size(infeat_train,2)
        fprintf(fileID,'%d ',infeat_train(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);

fileID = fopen('formatted_datasets/hep/fds_susy_valid.txt','w');
for i = 1:size(infeat_valid,1)
    i/size(infeat_valid,1)
    for j = 1:size(infeat_valid,2)
        fprintf(fileID,'%d ',infeat_valid(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);

fileID = fopen('formatted_datasets/hep/fds_susy_test.txt','w');
for i = 1:size(infeat_test,1)
    i/size(infeat_test,1)
    for j = 1:size(infeat_test,2)
        fprintf(fileID,'%d ',infeat_test(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);

