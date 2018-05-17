% This is file that test our supplier and demander agent
% Author: Chan-Wei Hu
%=========================================================================

clear all; 
close all;
warning off;
DATA_PATH = '../Data/Supplier/test/';

[plants_data_base, total_power_dem, plant_num, buy_num, day_num] ...
    = dataloader(DATA_PATH);

quoted_price = zeros(1, plant_num);
buy_price = rand(1, buy_num)*5;

% For supplier
% Discretize the action space => quoted_price
quoted_price_ub = 9;
quoted_price_lb = 2;
quoted_edges = quoted_price_lb:1:quoted_price_ub;
supply_action_num = size(quoted_edges,2) - 1;

% Discretize the supply state space => demand 
demand_ub = 50;
demand_lb = 0;
demand_state_edges = demand_lb:1:demand_ub;
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
supply_state_edges = supply_lb:1:supply_ub;
supply_state_num = size(supply_state_edges,2) - 1;

fval_log = [];
eve_x_log = [];

A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;

% Start testing
load('sup_Q_factor.mat', 'sup_Q_factor');
load('usr_Q_factor.mat', 'usr_Q_factor');
A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;

% Define a data structure for plotting the result
Result = struct('sup_benefit_RL', [], 'sup_benefit_Random', [], ...
                'mean_sup_benefit_RL', [], 'mean_sup_benefit_Random', [], ...
                'usr_benefit_RL', [], 'usr_benefit_Random', [], ...
                'mean_usr_benefit_RL', [], 'mean_usr_benefit_Random', [], ...
                'actual_supply_RL', [], 'actual_supply_Random', [], ...
                'demand', []);

for day = 1:day_num
    plants_data = squeeze(plants_data_base(day, :, :));
    % NOTE: should change power_dem shape if you have multiple users
    power_dem = squeeze(total_power_dem(day,:,:))';
    for use_RL = 0:1
        for compute_time = 7:18
            if use_RL 
                % Get supplier current state
                sup_cur_state = discretize(power_dem(compute_time, :), demand_state_edges)*ones(plant_num);
                for i = 1:plant_num
                    % Get the index of the max Q-value in current state, that is
                    % the price to quote
                    [~, quoted_price(i)] = max(sup_Q_factor(i, sup_cur_state(i), :));
                    quoted_price(i) = quoted_price(i)+1;
                end
                % Get user current state
                %usr_cur_state = discretize(sum(plants_data(compute_time, :)), supply_state_edges);
                usr_cur_state = discretize(power_dem(compute_time, :), supply_state_edges);
                for i = 1:buy_num
                    [~, buy_price(i)] = max(usr_Q_factor(i, usr_cur_state, :)); 
                    buy_price(i) = buy_price(i)+1;
                end
            else
                quoted_price = discretize(rand(1, plant_num)*7+2, quoted_edges);
                buy_price = discretize(rand(1, buy_num)*5+2, buy_edges);
            end
            f = [-1 * buy_price quoted_price];
            b = [power_dem(compute_time, :) plants_data(compute_time, :)];

            [x, fval, exitflag, output] = linprog(f, A, b, Aeq, beq, zeros(1, plant_num + buy_num), 1000 * ones(1, plant_num + buy_num));
            fval_log = [fval_log -fval];
            meanPrice = mean(x(2:plant_num + buy_num ));
            eve_x_log = [eve_x_log meanPrice];
            if use_RL
                Result.sup_benefit_RL = [Result.sup_benefit_RL sum(quoted_price*x(2:plant_num+buy_num))];              
                usr_demand_rate = x(1:buy_num)/power_dem(compute_time, :);
                Result.usr_benefit_RL = [Result.usr_benefit_RL sum(usr_demand_rate*(1-buy_price/buy_price_ub))];
                Result.actual_supply_RL = [Result.actual_supply_RL sum(x(2:plant_num+buy_num))];
            else
                Result.sup_benefit_Random = [Result.sup_benefit_Random sum(quoted_price*x(2:plant_num+buy_num))];
                usr_demand_rate = x(1:buy_num)/power_dem(compute_time, :);
                Result.usr_benefit_Random = [Result.usr_benefit_Random sum(usr_demand_rate*(1-buy_price/buy_price_ub))];
                Result.actual_supply_Random = [Result.actual_supply_Random sum(x(2:plant_num+buy_num))];
                Result.demand = [Result.demand power_dem(compute_time, :)];
            end
        end
        if use_RL
            Result.mean_sup_benefit_RL = [Result.mean_sup_benefit_RL mean(Result.sup_benefit_RL((day-1)*12+1:day*12))];
            Result.mean_usr_benefit_RL = [Result.mean_usr_benefit_RL mean(Result.usr_benefit_RL((day-1)*12+1:day*12))];
        else
            Result.mean_sup_benefit_Random = [Result.mean_sup_benefit_Random mean(Result.sup_benefit_Random((day-1)*12+1:day*12))];
            Result.mean_usr_benefit_Random = [Result.mean_usr_benefit_Random mean(Result.usr_benefit_Random((day-1)*12+1:day*12))];
        end
    end
end

% Draw the result
draw_result(Result, day_num);

