% This is file that test our supplier agent
% Author: Chan-Wei Hu
%=========================================================================

clear all; 
close all;
warning off;
plants_name_dir = dir('Supplier/test/');
plants_name_list = {};
for i=3:size(plants_name_dir, 1)
    plants_name_list = [plants_name_list; strcat('Supplier/test/', plants_name_dir(i).name)];
end

plants_data_base = [];
plant_num = size(plants_name_list, 1);

for i=1:plant_num
    M = sum(csvread(plants_name_list{i}, 1, 2), 2);
    R = zeros(24, 1);
    for t=0:23
        s = t*3+1;
        e = t*3+3;
        R(t+1) = sum(M(s:e, 1)) / 3;
    end
    plants_data_base = [plants_data_base R];
end

buy_num = 1;
total_power = [823.2 760.69 690.2 701.28 660.49 683.57 718.55 1013.8 1073.45 ...
    1227.85 1329.51 1391.72 1340.42 1438.32 1458.11 1441 1496.1 1346.59 1273.67 ...
    1269 1202.78 976.03 910.04 864.97];
total_power_dem = total_power' * 25 / 1000;
%{
figure();
h = plot(total_power_dem);
title('Total power demand');
xlabel('Time (hour)');
%}

quoted_price = zeros(1, plant_num);
buy_price = 5;
% Using RL method 
% Discretize the action space => quoted_price
quoted_price_upperbound = 9;
quoted_price_lowerbound = 2;
edges = quoted_price_lowerbound:1:quoted_price_upperbound;
action_num = size(edges,2) - 1;
quoted_price_discrete = discretize(quoted_price, edges);

% Discretize the state space => demand 
demand_upperbound = 40;
demand_lowerbound = 0;
state_edges = demand_lowerbound:1:demand_upperbound;
state_num = size(state_edges,2) - 1;
demand_state = discretize(total_power_dem, state_edges);
    
%{
figure();
for i=1:plant_num
    plot(plants_data_base(:, i));
    hold on
end
legend(plants_name_list);
hold off;
%}

fval_log = [];
eve_x_log = [];

A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;
iter_ = 0
immi_reward = zeros(plant_num, state_num, action_num);

% Start testing
load('Q_factor_table.mat', 'Q_factor');
A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;
supplier_benefit_RL = [];
supplier_benefit_Random = [];
demand = [];
actual_supply_RL = [];
actual_supply_Random = [];
for use_RL = 0:1
    for compute_time = 7:18
        if use_RL 
            % Get current state
            current_state = discretize(total_power_dem(compute_time, :), state_edges);
            for i = 1:plant_num
                % Get the index of the max Q-value in current state, that is
                % the price to quote
                [~, quoted_price(i)] = max(Q_factor(i, current_state, :));
            end
        else
            quoted_price = discretize(rand(1, plant_num)*7+2, edges);
        end
        f = [-1 * buy_price quoted_price];
        b = [total_power_dem(compute_time, :) plants_data_base(compute_time, :)];

        [x, fval, exitflag, output] = linprog(f, A, b, Aeq, beq, zeros(1, plant_num + buy_num), 1000 * ones(1, plant_num + buy_num));
        fval_log = [fval_log -fval];
        meanPrice = mean(x(2:plant_num + buy_num ));
        eve_x_log = [eve_x_log meanPrice];
        if use_RL
            supplier_benefit_RL = [supplier_benefit_RL sum(quoted_price*x(2:plant_num+buy_num))];
            actual_supply_RL = [actual_supply_RL sum(x(2:plant_num+buy_num))];
        else
            supplier_benefit_Random = [supplier_benefit_Random sum(quoted_price*x(2:plant_num+buy_num))];
            actual_supply_Random = [actual_supply_Random sum(x(2:plant_num+buy_num))];
            demand = [demand total_power_dem(compute_time, :)];
        end
        
        
        %disp(sum(quoted_price*x(2:plant_num+buy_num)));
        %fig_drawer(plants_data_base(compute_time, :), quoted_price, x(1), compute_time);
    end

end

output_dir = 'Result/';
% Plot supplier benefits
figure();
plot(7:1:18, supplier_benefit_RL);
hold on;
plot(7:1:18, supplier_benefit_Random);
hold off
legend('RL', 'Random');
title('Supplier benefit comparison');
ylabel('Total $');
xlabel('Time');
saveas(gcf, strcat(output_dir, 'Supplier benefit.jpg'));


% Plot demand and supply balance
figure();
plot(7:1:18, demand);
hold on; 
plot(7:1:18, actual_supply_RL); 
hold on;
plot(7:1:18, actual_supply_Random); 
hold off
legend('demand', 'actual supply RL', 'actual supply Random');
title('Demand vs Supply');
ylabel('kW');
xlabel('Time');
saveas(gcf, strcat(output_dir, 'Demand vs Supply.jpg'));


%figure();
%plot(fval_log);
%figure();
%plot(eve_x_log);

