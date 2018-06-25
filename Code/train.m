function train(DATA_PATH, quoted_range, buy_range, sup_range, usr_range, ...
    update_method, lr, beta, eta, ITERMAX, sup_model, usr_model)
% Description:
%   This is function for training the model.
%   Author: Chan-Wei Hu
%=========================================================================

% Load the data
[plants_data_base, total_power_dem, plant_num, buy_num, day_num] ...
    = dataloader(DATA_PATH);

%==================== Using RL method ========================== 
% For supplier
% Discretize the action space => quoted_price
quoted_price_ub = quoted_range(2);
quoted_price_lb = quoted_range(1);
quoted_edges = quoted_price_lb:1:quoted_price_ub;
supply_action_num = size(quoted_edges,2);

% Discretize the supply state space => demand 
demand_ub = sup_range(2);
demand_lb = sup_range(1);
demand_state_edges = demand_lb:5:demand_ub;
demand_state_num = size(demand_state_edges,2) - 1;

% For User
% Discretize the action space => buy_price
buy_price_ub = buy_range(2);
buy_price_lb = buy_range(1);
buy_edges = buy_price_lb:1:buy_price_ub;
user_action_num = size(buy_edges,2);

% Discretize the demand state space => supply
supply_ub = usr_range(2);
supply_lb = usr_range(1);
supply_state_edges = supply_lb:5:supply_ub;
supply_state_num = size(supply_state_edges,2) - 1;

% Maintain a Q-factor and setup the parameters for learning
sup_Q_factor = zeros(plant_num, demand_state_num, supply_action_num);
usr_Q_factor = zeros(buy_num, supply_state_num, user_action_num);

% Total reward and average reward table
sup_tr = zeros(plant_num, demand_state_num, supply_action_num);
usr_tr = zeros(buy_num, supply_state_num, user_action_num);
sup_ar = zeros(plant_num, demand_state_num, supply_action_num);
usr_ar = zeros(buy_num, supply_state_num, user_action_num);

A = eye(plant_num+buy_num);
Aeq = [ones(1 ,buy_num) -1*ones(1, plant_num)];
beq = 0;

% Maintain a table for weighting
sup_weight = ones(plant_num, demand_state_num, supply_action_num);
usr_weight = ones(buy_num, supply_state_num, user_action_num);

start_time = clock;
% Start training
for day = 1:day_num
    plants_data = squeeze(plants_data_base(day,:,:));
    % NOTE: should change power_dem shape if you have multiple users
    power_dem = squeeze(total_power_dem(day,:,:));
    fprintf('==> Training day: %d\n', day);
    for compute_time = 7:18
        % Convert current demand to discrete state
        %dem_cur_state = discretize(sum(power_dem(compute_time, :)), demand_state_edges)*ones(plant_num, 1);
        dem_cur_state = discretize(plants_data(compute_time, :), demand_state_edges);
        sup_cur_state = discretize(power_dem(compute_time, :), supply_state_edges);
        for iter_ = 1:ITERMAX 
            % Exploration
            %quoted_price = randi([quoted_price_lb quoted_price_ub], 1, plant_num);
            quoted_price = quoted_price_lb*ones(1, plant_num);
            buy_price = randi([buy_price_lb buy_price_ub], 1, buy_num);
            
            % Start evaluating 
            f = [-1 * buy_price quoted_price];
            b = [power_dem(compute_time, :) plants_data(compute_time, :)];
            [x, ~, ~, ~] = linprog(f, A, b, Aeq, beq, ...
                zeros(1, plant_num + buy_num), 1000 * ones(1, plant_num + buy_num), [], ...
                optimset('Display','none'));
            
            % Update the reward of supplier
            for j = 1:plant_num    
                %immi_reward = (x(j+buy_num)/(plants_data(compute_time, j)+0.00001))*(quoted_price(j)/quoted_price_ub);
                immi_reward = x(j+buy_num)*quoted_price(j);
                % Get quoted price -> action num
                quoted_p = quoted_price(j) - quoted_price_lb + 1;
                % update total reward
                sup_tr(j,dem_cur_state(j),quoted_p) = sup_tr(j,dem_cur_state(j),quoted_p) + immi_reward;  
                % update weight matrix
                sup_weight(j, dem_cur_state(j), quoted_p) = sup_weight(j, dem_cur_state(j), quoted_p) + 1;                
                % Get average reward
                sup_ar(j,dem_cur_state(j),quoted_p) = (1-beta)*sup_ar(j,dem_cur_state(j),quoted_p) ...
                    + beta*(sup_tr(j,dem_cur_state(j),quoted_p)/sup_weight(j, dem_cur_state(j), quoted_p));
                avg_reward = sup_ar(j,dem_cur_state(j),quoted_p);
                % Get next state
                next_state = discretize(x(j+buy_num), demand_state_edges);
                if strcmp(update_method, 'R-SMART')
                % Update supply Q-factor (R-SMART)
                sup_Q_factor(j,dem_cur_state(j),quoted_p) = ...
                    (1-lr)*sup_Q_factor(j, dem_cur_state(j), quoted_p)+ ...
                    lr*(immi_reward - avg_reward + eta*(max(sup_Q_factor(j,next_state,:))));
                elseif strcmp(update_method, 'Q-learning')
                % Update supply Q-factor (Q-learning)
                sup_Q_factor(j,dem_cur_state(j),quoted_p) = ...
                    (1-lr)*sup_Q_factor(j, dem_cur_state(j), quoted_p)+ ...
                    lr*(immi_reward + eta*(max(sup_Q_factor(j,next_state,:))));
                else
                    error('Unknown update method. Please check the method list');
                end
            end
            % Update the reward of user
            for j = 1:buy_num
                immi_reward = (x(j)/power_dem(compute_time, j))*(1-(buy_price(j)/buy_price_ub));
                % Get quoted price -> action num
                buy_p = buy_price(j) - buy_price_lb + 1;
                % update total reward
                usr_tr(j,sup_cur_state(j),buy_p) = usr_tr(j,sup_cur_state(j),buy_p) + immi_reward;  
                % update weight matrix
                usr_weight(j, sup_cur_state(j), buy_p) = usr_weight(j, sup_cur_state(j), buy_p) + 1; 
                % Get average reward
                usr_ar(j,sup_cur_state(j),buy_p) = (1-beta)*usr_ar(j,sup_cur_state(j),buy_p) ...
                    + beta*(usr_tr(j,sup_cur_state(j),buy_p)/usr_weight(j, sup_cur_state(j), buy_p));
                avg_reward = usr_ar(j,sup_cur_state(j),buy_p);
                % Get next state
                next_state = discretize(x(j), supply_state_edges);
                if strcmp(update_method, 'R-SMART')
                % Update user Q-factor (R-SMART)
                usr_Q_factor(j,sup_cur_state(j),buy_p) = ...
                    (1-lr)*usr_Q_factor(j, sup_cur_state(j),buy_p)+ ...
                    lr*(immi_reward - avg_reward + eta*(max(usr_Q_factor(j,next_state,:))));
                elseif strcmp(update_method, 'Q-learning')
                % Update user Q-factor (Q-learning)
                usr_Q_factor(j,sup_cur_state(j),buy_p) = ...
                    (1-lr)*usr_Q_factor(j, sup_cur_state(j),buy_p)+ ...
                    lr*(immi_reward - eta*(max(usr_Q_factor(j,next_state,:))));
                else
                    error('Unknown update method. Please check the method list');
                end    
            end
        end
    end
end

fprintf('Training time: %.2f mins\n', etime(clock, start_time)/60);

% Save the model
sup_Q_factor = sup_Q_factor ./ sup_weight;
usr_Q_factor = usr_Q_factor ./ usr_weight;
save(sup_model, 'sup_Q_factor');
save(usr_model, 'usr_Q_factor');
end
