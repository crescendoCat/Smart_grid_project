% This is file that test our supplier and demander agent
% Author: Chan-Wei Hu
%=========================================================================
clear all; 
close all;
warning off;

% Define the test data path
DATA_PATH = '../Data/Supplier/test/';

[plants_data_base, total_power_dem, plant_num, buy_num, day_num] ...
    = dataloader(DATA_PATH);

quoted_price = zeros(1, plant_num);
buy_price = rand(1, buy_num)*5;

% For supplier
% Discretize the action space => quoted_price
quoted_price_ub = 9;
quoted_price_lb = 4;
quoted_edges = quoted_price_lb:1:quoted_price_ub;
supply_action_num = size(quoted_edges,2);

% Discretize the supply state space => demand 
demand_ub = 200;
demand_lb = 0;
demand_state_edges = demand_lb:5:demand_ub;
demand_state_num = size(demand_state_edges,2) - 1;

% For User
% Discretize the action space => buy_price
buy_price_ub = 7;
buy_price_lb = 3;
buy_edges = buy_price_lb:1:buy_price_ub;
user_action_num = size(buy_edges,2);

% Discretize the demand state space => supply
supply_ub = 200;
supply_lb = 0;
supply_state_edges = supply_lb:5:supply_ub;
supply_state_num = size(supply_state_edges,2) - 1;

% Load in the Q-factor table
load('sup_Q_factor_R-SMART.mat', 'sup_Q_factor');
load('usr_Q_factor_R-SMART.mat', 'usr_Q_factor');

% Variables for linear programming
fval_log = [];
eve_x_log = [];
A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;

% Define a data structure for plotting the result
Result = struct('actual_supply_RL', [], 'actual_supply_Random', [], ...
                'sup_price_RL', [], 'usr_price_RL', [], ...
                'sup_price_Random', [], 'usr_price_Random', [], ...
                'sup_ideal_supply', plants_data_base(:, 7:18, :), ...
                'usr_ideal_need', total_power_dem(:, 7:18, :), ...
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
                sup_cur_state = discretize(plants_data(compute_time, :), demand_state_edges);
                for i = 1:plant_num
                    % Get the index of the max Q-value in current state, that is
                    % the price to quote
                    [~, quoted_price(i)] = max(sup_Q_factor(i, sup_cur_state(i), :));
                    quoted_price(i) = quoted_price(i)+quoted_price_lb-1;
                end
                % Get user current state
                usr_cur_state = discretize(power_dem(compute_time, :), supply_state_edges);
                for i = 1:buy_num
                    [~, buy_price(i)] = max(usr_Q_factor(i, usr_cur_state(i), :)); 
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

            [x, fval, exitflag, output] = linprog(f, A, b, Aeq, beq, ...
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

% Draw the result
draw_result(Result, day_num, quoted_price_ub, buy_price_ub, buy_price_lb, 1);
fprintf('Testing time: %.2f sec\n', etime(clock, start_time));
