[plants_data_base, total_power_dem, plant_num, buy_num, day_num] ...
       = dataloader('../Data/Supplier/test/');
   fid=fopen('plant_data.txt','w');
%列印資料x,y於檔案中，格式x為%6.4f；y為%10.8f
fprintf(fid, '{');
daynum = 5;
for day=1:daynum
    fprintf(fid, '{');
    for hour=7:18
        sup = squeeze(plants_data_base(day, hour, :))';
        fprintf(fid, '{');
        for plant=1:18
            fprintf(fid, '%f, ', sup(1, plant));
        end
        if hour == 18
            fprintf(fid, '%f}\n', sup(1, 19));
        else
        fprintf(fid, '%f},\n', sup(1, 19));
        end    
    end
    if(day == daynum)
        fprintf(fid, '}');
    else
        fprintf(fid, '},');
    end
end
fprintf(fid, '}');
fclose(fid);
   fid=fopen('user_data.txt','w');
%列印資料x,y於檔案中，格式x為%6.4f；y為%10.8f
fprintf(fid, '{');
daynum = 5;
for day=1:daynum
    fprintf(fid, '{');
    for hour=7:18
           usr = squeeze(total_power_dem(day, hour, :))';
        fprintf(fid, '{');
        for plant=1:2
            fprintf(fid, '%f, ', usr(1, plant));
        end
        if hour == 18
            fprintf(fid, '%f}\n', usr(1, 3));
        else
        fprintf(fid, '%f},\n', usr(1, 3));
        end    
    end
    if(day == daynum)
        fprintf(fid, '}');
    else
        fprintf(fid, '},');
    end
end
fprintf(fid, '}');
fclose(fid);
