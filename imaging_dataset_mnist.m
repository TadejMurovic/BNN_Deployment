clear all;
close all hidden;

ib = 60000;
[imgst labelst] = readMNIST('datasets/imaging/train-images.idx3-ubyte', 'datasets/imaging/train-labels.idx1-ubyte', ib, 0);

for i = 1:ib
    reading = i/ib
	img = imresize(imgst(:,:,i), [20 20]);
    img = img > (mean(mean(img)));
    imgs(:,:,i) = img;
    binvec(i,:) = [img(:)' (labelst(i)>4)];
    %binvec(i,:) = [img(:)' de2bi(labelst(i),'left-msb',4)];
end

binfeat = binvec;

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


fileID = fopen('formatted_datasets/imaging/fds_mnist_train.txt','w');
for i = 1:size(infeat_train,1)
    i/size(infeat_train,1)
    for j = 1:size(infeat_train,2)
        fprintf(fileID,'%d ',infeat_train(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);

fileID = fopen('formatted_datasets/imaging/fds_mnist_valid.txt','w');
for i = 1:size(infeat_valid,1)
    i/size(infeat_valid,1)
    for j = 1:size(infeat_valid,2)
        fprintf(fileID,'%d ',infeat_valid(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);

fileID = fopen('formatted_datasets/imaging/fds_mnist_test.txt','w');
for i = 1:size(infeat_test,1)
    i/size(infeat_test,1)
    for j = 1:size(infeat_test,2)
        fprintf(fileID,'%d ',infeat_test(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);
