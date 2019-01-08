%clear all;
%close all;

strvec = ['r','n'];

cx = 0.5;
cy = 0.6;
cr = 0.3;

maxx = -inf;
minx = inf;
maxy = -inf;
miny = inf;
select = 0;
for itc = 1:8
    for it = 1:5
        for side = 1:2
            fid = fopen(strcat('datasets/iot/lines/c',num2str(itc),'/l',num2str(itc),strvec(side),'_0',num2str(it),'.txt'),'rt');
            A = textscan(fid,'%s');
            fclose(fid);
            strA = A{1};
            strpoint = strA(end-5:end-2);
            for i = 1:length(strpoint)
               point(i) = str2num(strpoint{i}); 
            end
            
            id = str2num(strA{end})+1;
            dx  = (point(3) - point(1))/(id-1);
            dy  = (point(4) - point(2))/(id-1);
            for sel = 1:(id*10)
                selid = floor((sel-1)/10) + 1;
                vec(selid,mod(sel-1,10)+1) = str2num(strA{sel});
                label(selid,:) = [point(1) point(2)] + (selid-1)*[dx dy];
            end
            vec = vec(:,2:end);
            vec = [vec label];
            maxx = max(maxx, max(vec(:,end-1)));
            minx = min(minx, min(vec(:,end-1)));
            maxy = max(maxy, max(vec(:,end)));
            miny = min(miny, min(vec(:,end)));
            select = select + 1;
            vecstruct(select).vec = vec;
            clear vec
            clear label
        end
    end
end

outvec = [];
delta_x = maxx-minx;
delta_y = maxy-miny;
select = 0;
labels = [];
for itc = 1:8
    for it = 1:5
        for side = 1:2
            select = select + 1;
            vecstruct(select).vec(:,end-1) = (vecstruct(select).vec(:,end-1)-minx)/delta_x;  
            vecstruct(select).vec(:,end) = (vecstruct(select).vec(:,end)-miny)/delta_y;
            
            lb  = vecstruct(select).vec(:,end-1)*0 + ( itc == 5);
            %lb = sqrt((vecstruct(select).vec(:,end-1)-cx).^2 + (vecstruct(select).vec(:,end)-cy).^2) < cr;
            labels = [labels; lb];
            
            pts  = [vecstruct(select).vec(:,end-1) vecstruct(select).vec(:,end)];
            ptsl = lb;
            
            fid = fopen(strcat('datasets/iot/lines/c',num2str(itc),'/l',num2str(itc),strvec(side),'_0',num2str(it),'.txt'),'rt');
            A = textscan(fid,'%s');
            fclose(fid);
            strA = A{1};
            strpoint = strA(end-5:end-2);
            for i = 1:length(strpoint)
               point(i) = str2num(strpoint{i}); 
            end
            figure(1);
            plot(([point(1),point(3)]-minx)/delta_x,([point(2),point(4)]-miny)/delta_y); hold on;
            if sum(lb) > 0
              scatter(pts(:,1),pts(:,2),'r'); hold on;
            end
            grid on
            outvec = [outvec; vecstruct(select).vec];
        end
    end
end
%circle(cx,cy,cr);

features = outvec;

endbits = 250;
itid = 0;
for it = 0.01:-0.0001:0.0001
    itid = itid + 1;
    clear intval
    clear intbit
    clear err
    clear finerr
    bitvec = [];
    for i = 1:(size(features,2)-2)
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

binfeat = [bitvec labels];

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


fileID = fopen('formatted_datasets/iot/fds_uji_train.txt','w');
for i = 1:size(infeat_train,1)
    i/size(infeat_train,1)
    for j = 1:size(infeat_train,2)
        fprintf(fileID,'%d ',infeat_train(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);

fileID = fopen('formatted_datasets/iot/fds_uji_valid.txt','w');
for i = 1:size(infeat_valid,1)
    i/size(infeat_valid,1)
    for j = 1:size(infeat_valid,2)
        fprintf(fileID,'%d ',infeat_valid(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);

fileID = fopen('formatted_datasets/iot/fds_uji_test.txt','w');
for i = 1:size(infeat_test,1)
    i/size(infeat_test,1)
    for j = 1:size(infeat_test,2)
        fprintf(fileID,'%d ',infeat_test(i,j));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);

inputbits = size(infeat_test,2)-1;
