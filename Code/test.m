function [Result] = test(DATA_PATH, quoted_range, buy_range, supply_range, ...
    demand_range, sup_model, usr_model)
% Description:
%   This is function for testing the model.
%   Author: Chan-Wei Hu
%=========================================================================

[plants_data_base, total_power_dem, plant_num, buy_num, day_num] ...
    = dataloader(DATA_PATH);

% For supplier
% Discretize the action space => quoted_price
quoted_price_ub = quoted_range(2);
quoted_price_lb = quoted_range(1);
quoted_edges = quoted_price_lb:1:quoted_price_ub;

% Discretize the supply state space => demand 
demand_ub = supply_range(2);
demand_lb = supply_range(1);
demand_state_edges = demand_lb:5:demand_ub;
demand_state_num = size(demand_state_edges,2) - 1;

% For User
% Discretize the action space => buy_price
buy_price_ub = buy_range(2);
buy_price_lb = buy_range(1);
buy_edges = buy_price_lb:1:buy_price_ub;

% Discretize the demand state space => supply
supply_ub = demand_range(2);
supply_lb = demand_range(1);
supply_state_edges = supply_lb:5:supply_ub;
supply_state_num = size(supply_state_edges,2) - 1;

% Load in the Q-factor table
load(sup_model, 'sup_Q_factor');
load(usr_model, 'usr_Q_factor');

% Variables for linear programming
A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;

% Define a data structure for plotting the result
Result = struct('sup_price_RL', [], 'usr_price_RL', [], ...
                'sup_price_Random', [], 'usr_price_Random', [], ...
                'sup_ideal_supply', plants_data_base(:, :, :), ...
                'usr_ideal_need', total_power_dem(:, :, :), ...
                'sup_actual_supply_RL', zeros(day_num, 12, plant_num), ...
                'usr_actual_get_RL', zeros(day_num, 12, buy_num), ...
                'sup_actual_supply_Random', zeros(day_num, 12, plant_num), ...
                'usr_actual_get_Random', zeros(day_num, 12, buy_num));
start_time = clock;
for day = 1:day_num
    plants_data = squeeze(plants_data_base(day, :, :));
    power_dem = squeeze(total_power_dem(day, :, :));
    fprintf('==> Testing day: %d\n', day);
    for use_RL = 0:1
        for compute_time = 7:18
            if use_RL 
                % Get supplier current state
                sup_cur_state = discretize(plants_data(compute_time, :), supply_state_edges);
                total_sup_cur_state = discretize(sum(plants_data(compute_time, :)), supply_state_edges);
                total_dem_cur_state = discretize(sum(power_dem(compute_time, :)), demand_state_edges);
                sup_cur = total_dem_cur_state * supply_state_num + sup_cur_state;
                
                quoted_price = zeros(1, plant_num);
                buy_price = zeros(1, buy_num);
                for i = 1:plant_num
                    % Get the index of the max Q-value in current state, that is
                    % the price to quote
                    [~, quoted_price(i)] = max(sup_Q_factor(i, sup_cur(i), :));
                    quoted_price(i) = quoted_price(i)+quoted_price_lb-1;
                end
                % Get user current state
                usr_cur_state = discretize(power_dem(compute_time, :), demand_state_edges);
                usr_cur = total_sup_cur_state * demand_state_num + usr_cur_state;
                for i = 1:buy_num
                    [~, buy_price(i)] = max(usr_Q_factor(i, usr_cur(i), :)); 
                    buy_price(i) = buy_price(i)+buy_price_lb-1;
                end
                
                % Store the price into result
                Result.sup_price_RL = [Result.sup_price_RL; quoted_price];
                Result.usr_price_RL = [Result.usr_price_RL; buy_price];                
            else
                quoted_price = randi([quoted_price_lb quoted_price_ub], 1, plant_num);
                buy_price = randi([buy_price_lb buy_price_ub], 1, buy_num);
                
                % Store the price into result
                Result.sup_price_Random = [Result.sup_price_Random; quoted_price];
                Result.usr_price_Random = [Result.usr_price_Random; buy_price]; 
            end
            
            f = [-1 * buy_price quoted_price];
            b = [power_dem(compute_time, :) plants_data(compute_time, :)];

            [x, ~, ~, ~] = linprog(f, A, b, Aeq, beq, ...
                zeros(1, plant_num + buy_num), 1000 * ones(1, plant_num + buy_num), [], ...
                optimset('Display','none'));
            
            if use_RL
                Result.sup_actual_supply_RL(day, compute_time-6, :) = x(buy_num+1:plant_num+buy_num);
                Result.usr_actual_get_RL(day, compute_time-6, :) = x(1:buy_num);
            else
                Result.sup_actual_supply_Random(day, compute_time-6, :) = x(buy_num+1:plant_num+buy_num);
                Result.usr_actual_get_Random(day, compute_time-6, :) = x(1:buy_num);
            end
        end
    end
end
fprintf('Testing time: %.2f sec\n', etime(clock, start_time));
end