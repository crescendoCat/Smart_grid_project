% This is file that test our supplier and demander agent
% Author: Chan-Wei Hu
%=========================================================================

clear all; 
close all;
warning off;
DATA_PATH = 'Supplier/test/';

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

% Start testing
load('sup_Q_factor.mat', 'sup_Q_factor');
load('usr_Q_factor.mat', 'usr_Q_factor');
A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;

supplier_benefit_RL = [];
supplier_benefit_Random = [];
mean_sup_benefit_RL = [];
mean_sup_benefit_Random = [];

usr_benefit_RL = [];
usr_benefit_Random = [];
mean_usr_benefit_RL = [];
mean_usr_benefit_Random = [];

demand = [];
actual_supply_RL = [];
actual_supply_Random = [];
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
                supplier_benefit_RL = [supplier_benefit_RL sum(quoted_price*x(2:plant_num+buy_num))];              
                %usr_benefit_RL = [usr_benefit_RL sum(buy_price*x(1:buy_num))];
                usr_demand_rate = x(1:buy_num)/power_dem(compute_time, :);
                usr_benefit_RL = [usr_benefit_RL sum(usr_demand_rate*(1-buy_price/buy_price_ub))];
                actual_supply_RL = [actual_supply_RL sum(x(2:plant_num+buy_num))];
            else
                supplier_benefit_Random = [supplier_benefit_Random sum(quoted_price*x(2:plant_num+buy_num))];
                %usr_benefit_Random = [usr_benefit_Random sum(buy_price*x(1:buy_num))];
                usr_demand_rate = x(1:buy_num)/power_dem(compute_time, :);
                usr_benefit_Random = [usr_benefit_Random sum(usr_demand_rate*(1-buy_price/buy_price_ub))];
                actual_supply_Random = [actual_supply_Random sum(x(2:plant_num+buy_num))];
                demand = [demand power_dem(compute_time, :)];
            end

            %disp(sum(quoted_price*x(2:plant_num+buy_num)));
            %fig_drawer(plants_data(compute_time, :), quoted_price, x(1), ...
                %total_power_dem(compute_time, :), compute_time);
        end
        if use_RL
            mean_sup_benefit_RL = [mean_sup_benefit_RL mean(supplier_benefit_RL((day-1)*12+1:day*12))];
            mean_usr_benefit_RL = [mean_usr_benefit_RL mean(usr_benefit_RL((day-1)*12+1:day*12))];
        else
            mean_sup_benefit_Random = [mean_sup_benefit_Random mean(supplier_benefit_Random((day-1)*12+1:day*12))];
            mean_usr_benefit_Random = [mean_usr_benefit_Random mean(usr_benefit_Random((day-1)*12+1:day*12))];
        end
        %{
        if use_RL
            disp('Supplier RL average');
            disp(mean(supplier_benefit_RL));
            disp('User RL average');
            disp(mean(usr_benefit_RL));
        else
            disp('Supplier Random average');
            disp(mean(supplier_benefit_Random));
            disp('User Random average');
            disp(mean(usr_benefit_Random));
        end
        %}
    end
end

output_dir = 'Result/';

% Plot supplier average benefit of RL vs Random 
figure();
plot(1:1:day_num,  mean_sup_benefit_RL, '-o');
hold on;
plot(1:1:day_num,  mean_sup_benefit_Random, '-o');
hold off
legend('RL', 'Random');
title('Average supplier benefit comparison');
ylabel('Total $');
xlabel('Day');
%saveas(gcf, strcat(output_dir, 'Average_supplier_benefit.jpg'));

% Plot supplier average benefit of RL vs Random 
figure();
plot(1:1:day_num,  mean_usr_benefit_RL, '-o');
hold on;
plot(1:1:day_num,  mean_usr_benefit_Random, '-o');
hold off
legend('RL', 'Random');
title('Average user benefit comparison');
ylabel('Total $');
xlabel('Day');
%saveas(gcf, strcat(output_dir, 'Average_user_benefit.jpg'));

%{
% Plot supplier benefits
figure();
plot(7:1:18, supplier_benefit_RL, '-o');
hold on;
plot(7:1:18, supplier_benefit_Random, '-o');
hold off
legend('RL', 'Random');
title('Supplier benefit comparison');
ylabel('Total $');
xlabel('Time');
saveas(gcf, strcat(output_dir, 'Supplier benefit.jpg'));

% Plot user benefits
figure();
plot(7:1:18, usr_benefit_RL, '-o');
hold on;
plot(7:1:18, usr_benefit_Random, '-o');
hold off
legend('RL', 'Random');
title('User benefit comparison');
ylabel('Total $');
xlabel('Time');
saveas(gcf, strcat(output_dir, 'User benefit.jpg'));
%}
% Plot demand and supply balance
figure();
plot(7:1:18, demand(109:120), '-o');
hold on; 
plot(7:1:18, actual_supply_RL(109:120), '-o'); 
hold on;
plot(7:1:18, actual_supply_Random(109:120), '-o'); 
hold off
legend('demand', 'actual supply RL', 'actual supply Random');
title('Demand vs Supply');
ylabel('kW');
xlabel('Time');
%saveas(gcf, strcat(output_dir, 'Demand vs Supply.jpg'));
