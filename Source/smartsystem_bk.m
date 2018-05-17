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
total_power = [823.2 760.69 690.2 701.28 660.49 683.57 718.55 1013.8 1073.45 1227.85 1329.51 1391.72 1340.42 1438.32 1458.11 1441 1496.1 1346.59 1273.67 1269 1202.78 976.03 910.04 864.97];
total_power_dem = total_power' * 25 / 1000;
figure();
h = plot(total_power_dem);
title('Total power demand');
xlabel('Time (hour)');


% Random price here
quoted_price = rand(1, plant_num)*8.8+ 1.2;
%buy_price = rand(1, buy_num) * 8.8 + 2.4;
%quoted_price = ones(1, plant_num);
buy_price = 3;
% CHANWEI ADD
% Using RL method 
% Discretize the action space => quoted_price
quoted_price_upperbound = 9;
quoted_price_lowerbound = 2;
edges = quoted_price_lowerbound:0.1:quoted_price_upperbound;
action_num = size(edges,1) - 1;
quoted_price_discrete = discretize(quoted_price, edges);

% Discretize the state space => demand 
demand_upperbound = 40;
demand_lowerbound = 15;
edges = demand_lowerbound:0.1:demand_upperbound;
state_num = size(edges,1) - 1;
demand_state = discretize(total_power_dem, edges);

% Maintain a Q-factor for R-SMART learning
Q_factor = zeros(state_num, action_num);
learning_rate = 0.01;
eta = 0.99;


% CHANWEI END

%figure();
%bar([buy_price quoted_price]);
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

f = [-1 * buy_price quoted_price];
%f = [buy_price -1*quoted_price]';
A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;
for compute_time = 6:18
    b = [total_power_dem(compute_time, :) plants_data_base(compute_time, :)];
    
%     disp(f);
%     disp(A);
%     disp(b);
%     disp(Aeq);
%     disp(beq);
    

    [x, fval, exitflag, output] = linprog(f, A, b, Aeq, beq, zeros(1, plant_num + buy_num), 1000 * ones(1, plant_num + buy_num));
    fval_log = [fval_log -fval];
    meanPrice = mean(x(2:plant_num + buy_num ));
    eve_x_log = [eve_x_log meanPrice];
    fig_drawer(plants_data_base(compute_time, :), quoted_price, x(1), compute_time);
end
figure();
plot(fval_log);
figure();
plot(eve_x_log);

%{
TR = rand(1, 72)*0.2 + 0.9;
tai_power = (sum_M + 500) .* TR;
figure();
plot(tai_power);
%}