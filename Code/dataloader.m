function [plants_data_base, total_power_dem, plant_num, buy_num, day_num] ...
            = dataloader(DATA_PATH)
% Description:
%   This is function for loading data from Supplier and User.
%   Author: Chan-Wei Hu
%=========================================================================

plants_day_dir = dir(DATA_PATH);
plants_day_list = {};
day_num = size(plants_day_dir, 1)-2;

for i=3:size(plants_day_dir, 1)
    plants_day_list = [plants_day_list; strcat(DATA_PATH, plants_day_dir(i).name)];
end

plant_num = 19;
plants_data_base = zeros(length(plants_day_list), 24, plant_num);
for i=1:length(plants_day_list)
    plants_name_list = {};
    plant_data_dir = dir(char(plants_day_list(i)));
    for j=3:size(plant_data_dir, 1)
        plants_name_list = [plants_name_list; strcat(strcat(plants_day_list(i), '/'), plant_data_dir(j).name)];
    end
    plants_data_base_tmp = [];

    for j=1:plant_num
        M = sum(csvread(plants_name_list{j}, 1, 2), 2);
        R = zeros(24, 1);
        for t=0:23
            s = t*3+1;
            e = t*3+3;
            R(t+1) = sum(M(s:e, 1)) / 3;
        end
        plants_data_base_tmp = [plants_data_base_tmp R];
    end
    plants_data_base(i,:,:) = plants_data_base_tmp;
end

buy_num = 2;
total_power_dem = zeros(day_num, 24, buy_num);
usr_total_power_day1 = [823.2 760.69 690.2 701.28 660.49 683.57 718.55 1013.8 1073.45 ...
    1227.85 1329.51 1391.72 1340.42 1438.32 1458.11 1441 1496.1 1346.59 1273.67 ...
    1269 1202.78 976.03 910.04 864.97; ...
    998.7 881.36 830.49 816.94 764.28 755.14 792.5 1289.41 1687.14...
    2507.15 2837.24 2975.85 2767.95 2893.08 3099.79 2949.86 2829.78 2467.41 2244.73 ...
    2139.16 2066.37 1662.22 1496.43 1429.96; ...
    1034.67 917.33 866.46 852.91 800.25 791.11 828.47 1325.3 1723.11 2543.12 2873.21 ...
    3011.82 2803.92 2929.05 3135.76 2985.83 2865.75 2503.38 2280.70 2175.13 2102.34 ...
    1698.19 1532.40 1465.93];

for i = 1:buy_num
    total_power_dem(1,:,i) = usr_total_power_day1(i,:)' * 25 / 1000;
end

% Random generate demand of other days based on day1 true data
for other=2:day_num
    % Random generate integer from 20~30
    for i = 1:buy_num
        random_int = 10*rand(1)+20;
        total_power_dem(other,:,i)=usr_total_power_day1(i,:)' * random_int / 1000;
    end
end
end


