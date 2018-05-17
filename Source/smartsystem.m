clear all; 
close all;
plants_name_dir = dir('Supplier/');
plants_name_list = {};
for i=3:size(plants_name_dir, 1)
    plants_name_list = [plants_name_list; strcat('Supplier/', plants_name_dir(i).name)];
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

quoted_price = rand(1, plant_num)*7+2;
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

% Maintain a Q-factor for R-SMART learning
Q_factor = rand(plant_num, state_num, action_num);
learning_rate = 10;
eta = 0.99;
iteration = 100;
train_ask = 'Do you want to train the agent? (true: train, false: test)\n';
train = input(train_ask);
if train == false
    use_RL_ask = 'test RL or Random? (true: RL, false: Random)\n';
    use_RL = input(use_RL_ask);
else
    use_RL = false;
end
    
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
%% Training phase
if train
    for compute_time = 7:18
        % Convert current demand to discrete state
        current_state = discretize(total_power_dem(compute_time, :), state_edges);
        for iter_ = 1:iteration
            % Find the best action in this state
            for i = 1:plant_num
                % Get the index of the max Q-value in current state, that is
                % the price to quote
                [~, quoted_price(i)] = max(Q_factor(i, current_state, :));
            end
            % Start evaluating 
            f = [-1 * buy_price quoted_price];
            b = [total_power_dem(compute_time, :) plants_data_base(compute_time, :)];
            [x, fval, exitflag, output] = linprog(f, A, b, Aeq, beq, ...
                zeros(1, plant_num + buy_num), 1000 * ones(1, plant_num + buy_num));
            % Get the reward
            for j = 1:plant_num
                [~, quote_p] = max(Q_factor(i, current_state, :));
                immi_reward(j, current_state, quote_p) = x(j+1)*quote_p;
                % Update Q-factor
                Q_factor(j,current_state,quote_p) = (1-learning_rate)*Q_factor(j, current_state, quote_p)+ ...
                    learning_rate*(immi_reward(j,current_state,quote_p) + eta*(max(Q_factor(j,current_state,:))));
            end  
            % Refresh current state
            current_state = discretize(x(1), state_edges);
        end
    end
    save('Q_factor_table.mat', 'Q_factor');
%% Testing phase
else
    load('Q_factor_table.mat', 'Q_factor');
    A = eye(plant_num+buy_num);
    Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
    beq = 0;
    supplier_benefit = [];
    demand = [];
    actual_supply = [];
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
        supplier_benefit = [supplier_benefit sum(quoted_price*x(2:plant_num+buy_num))];
        demand = [demand total_power_dem(compute_time, :)];
        actual_supply = [actual_supply sum(x(2:plant_num+buy_num))];
        %disp(sum(quoted_price*x(2:plant_num+buy_num)));
        %fig_drawer(plants_data_base(compute_time, :), quoted_price, x(1), compute_time);
    end

    
    output_dir = 'Result/';
    % Plot supplier benefits
    figure();
    plot(7:1:18, supplier_benefit);
    if use_RL
        title('Supplier benefit: Use RL');
    else
        title('Supplier benefit: Random');
    end
    ylabel('Total $');
    xlabel('Time');
    if use_RL
        saveas(gcf, strcat(output_dir, 'Supplier benefit-Use RL.png'));
    else
        saveas(gcf, strcat(output_dir, 'Supplier benefit-Random.png'));
    end
        
    % Plot demand and supply balance
    figure();
    plot(7:1:18, demand);
    hold on; 
    plot(7:1:18, actual_supply); 
    hold off
    legend('demand', 'actual supply');
    if use_RL
        title('Demand vs Supply: Use RL');
    else
        title('Demand vs Supply: Random');
    end
    ylabel('kW');
    xlabel('Time');
    if use_RL
        saveas(gcf, strcat(output_dir, 'Demand vs Supply-Use RL.png'));
    else
        saveas(gcf, strcat(output_dir, 'Demand vs Supply-Random.png'));
    end
    
    %figure();
    %plot(fval_log);
    %figure();
    %plot(eve_x_log);
end
