% This is file that use Q-learning algorithm to train a supplier agent
% Author: Chan-Wei Hu
%=========================================================================
clear all; 
close all;
warning off;

% Data preprocessing
% Read in the data
plants_day_dir = dir('Supplier/train/');
plants_day_list = {};
training_days = size(plants_day_dir, 1)-2;
for i=3:size(plants_day_dir, 1)
    plants_day_list = [plants_day_list; strcat('Supplier/train/', plants_day_dir(i).name)];
end

plants_data_base = zeros(length(plants_day_list), 24, 19);
for i=1:length(plants_day_list)
    plants_name_list = {};
    plant_data_dir = dir(char(plants_day_list(i)));
    for j=3:size(plant_data_dir, 1)
        plants_name_list = [plants_name_list; strcat(strcat(plants_day_list(i), '/'), plant_data_dir(j).name)];
    end
    plants_data_base_tmp = [];
    plant_num = size(plants_name_list, 1);

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

buy_num = 1;
total_power_dem = zeros(training_days, 24, buy_num);
total_power_day1 = [823.2 760.69 690.2 701.28 660.49 683.57 718.55 1013.8 1073.45 ...
    1227.85 1329.51 1391.72 1340.42 1438.32 1458.11 1441 1496.1 1346.59 1273.67 ...
    1269 1202.78 976.03 910.04 864.97];
total_power_dem(1,:,:) = total_power_day1' * 25 / 1000;

% Random generate demand of other days based on day1 true data
for other=2:training_days
    % Random generate integer from 20~30
    random_int = 10*rand(1)+20;
    total_power_dem(other,:,:)=total_power_day1' * random_int / 1000;
end

%{
figure();
h = plot(total_power_dem);
title('Total power demand');
xlabel('Time (hour)');
%}

quoted_price = rand(1, plant_num)*7+2;
buy_price = rand(1, buy_num)*5+2;
%==================== Using RL method ========================== 
% For supplier
% Discretize the action space => quoted_price
quoted_price_ub = 9;
quoted_price_lb = 2;
quoted_edges = quoted_price_lb:1:quoted_price_ub;
supply_action_num = size(quoted_edges,2) - 1;

% Discretize the supply state space => demand 
demand_ub = 50;
demand_lb = 0;
demand_state_edges = demand_lb:5:demand_ub;
demand_state_num = size(demand_state_edges,2) - 1;

% For User
% Discretize the action space => buy_price
buy_price_ub = 9;
buy_price_lb = 2;
buy_edges = buy_price_lb:1:buy_price_ub;
user_action_num = size(buy_edges,2) - 1;

% Discretize the demand state space => supply
supply_ub = 50;
supply_lb = 0;
supply_state_edges = supply_lb:5:supply_ub;
supply_state_num = size(supply_state_edges,2) - 1;

% Maintain a Q-factor for R-SMART learning
sup_Q_factor = zeros(plant_num, demand_state_num, supply_action_num);
usr_Q_factor = zeros(buy_num, supply_state_num, user_action_num);
learning_rate = 0.1;
eta = 0.99;
iteration = 10;

%{
figure();
for i=1:plant_num
    plot(plants_data_base(3, :, i));
    hold on
end
legend(plants_name_list);
hold off;
%}

A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;

% Start training
for day = 1:size(plants_day_dir, 1)-2
    plants_data = squeeze(plants_data_base(day,:,:));
    % NOTE: should change power_dem shape if you have multiple users
    power_dem = squeeze(total_power_dem(day,:,:))';
    for compute_time = 7:18
        % Convert current demand to discrete state
        dem_cur_state = discretize(power_dem(compute_time, :), demand_state_edges)*ones(plant_num);
        %sup_cur_state = discretize(sum(plants_data(compute_time, :)), supply_state_edges);
        sup_cur_state = discretize(power_dem(compute_time, :), supply_state_edges);
        for iter_ = 1:iteration
            % Find the best action for supplier
            for i = 1:plant_num
                % Get the index of the max Q-value in current state, that is
                % the price to quote
                %if sum(sup_Q_factor(i, dem_cur_state(i), :)) == 0
                    quoted_price(i) = randi([quoted_price_lb quoted_price_ub],1);
                %else    
                %  [~, quoted_price(i)] = max(sup_Q_factor(i, dem_cur_state(i), :));
                %end
            end
            % Find the best action for user
            for i = 1:buy_num
                %if sum(usr_Q_factor(i, sup_cur_state(i), :)) == 0
                    buy_price(i) = randi([buy_price_lb buy_price_ub],1);
                %else
                %    [~, buy_price(i)] = max(usr_Q_factor(i, sup_cur_state, :));
                %end
            end
            
            % Start evaluating 
            f = [-1 * buy_price quoted_price];
            b = [power_dem(compute_time, :) plants_data(compute_time, :)];
            [x, fval, exitflag, output] = linprog(f, A, b, Aeq, beq, ...
                zeros(1, plant_num + buy_num), 1000 * ones(1, plant_num + buy_num));
            
            % Update the reward of supplier
            for j = 1:plant_num
                [~, quote_p] = max(sup_Q_factor(j, dem_cur_state(i), :));       
                immi_reward = (x(j+1)/(plants_data(compute_time, j)+0.0001))*(quote_p/quoted_price_ub);
                % Update supply Q-factor
                sup_Q_factor(j,dem_cur_state(i),quote_p) = (1-learning_rate)*sup_Q_factor(j, dem_cur_state(i), quote_p)+ ...
                    learning_rate*(immi_reward + eta*(max(sup_Q_factor(j,dem_cur_state(i),:))));
            end
            % Update the reward of user
            for j = 1:buy_num
                [~, buy_p] = max(usr_Q_factor(j, sup_cur_state, :)); 
                immi_reward = (x(j)/power_dem(compute_time, j))*(1-(buy_p/buy_price_ub));
                % Update user Q-factor
                usr_Q_factor(j,sup_cur_state,buy_p) = (1-learning_rate)*usr_Q_factor(j, sup_cur_state,buy_p)+ ...
                    learning_rate*(immi_reward+ eta*(max(usr_Q_factor(j,sup_cur_state,:))));
            end
            
            % Refresh current state
            sup_cur_state = discretize(x(1), supply_state_edges);
            dem_cur_state = discretize(x(buy_num+1:plant_num + buy_num), demand_state_edges);
        end
    end
end
save('sup_Q_factor.mat', 'sup_Q_factor');
save('usr_Q_factor.mat', 'usr_Q_factor');