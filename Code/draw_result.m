function draw_result(Result, day_num)
% Description:
%   This is function for plotting the result.
%   Author: Chan-Wei Hu
%=========================================================================
output_dir = '../Result/';
SAVE_FLAG = 1;

% Plot the supplier quoted price difference 
% Reshape it first : [day_num*hour_intv, plant_num] -> [day_num, hour_intv, plant_num]
hour_intv = 7:1:18;
plant_num = size(Result.sup_price_RL,2);
sup_p_RL = zeros(day_num, length(hour_intv), plant_num);
sup_p_Random = zeros(day_num, length(hour_intv), plant_num);
for i = 1:day_num
    sup_p_RL(i, :, :) = Result.sup_price_RL((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
    sup_p_Random(i, :, :) = Result.sup_price_Random((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
end
sup_avg_p_RL = squeeze(sum(sum(sup_p_RL,1),3)/(day_num*plant_num));
sup_avg_p_Random = squeeze(sum(sum(sup_p_Random,1),3)/(day_num*plant_num));
figure();
plot(hour_intv,  sup_avg_p_RL, '-o', ...
      hour_intv,  sup_avg_p_Random, '-x');
legend('RL', 'Random');
title('Average supplier price comparison');
ylabel('Avg. price');
xlabel('time');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, 'supplier_price_cmp.jpg'));
end

% Plot the user buy price difference 
% Reshape it first : [day_num*hour_intv, plant_num] -> [day_num, hour_intv, plant_num]
buy_num = size(Result.usr_price_RL,2);
usr_p_RL = zeros(day_num, length(hour_intv), buy_num);
usr_p_Random = zeros(day_num, length(hour_intv), buy_num);
for i = 1:day_num
    usr_p_RL(i, :, :) = Result.usr_price_RL((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
    usr_p_Random(i, :, :) = Result.usr_price_Random((i-1)*length(hour_intv)+1:i*length(hour_intv), :);
end
usr_avg_p_RL = squeeze(sum(sum(usr_p_RL,1),3)/(day_num*buy_num));
usr_avg_p_Random = squeeze(sum(sum(usr_p_Random,1),3)/(day_num*buy_num));
figure();
plot(hour_intv,  usr_avg_p_RL, '-o', ...
      hour_intv,  usr_avg_p_Random, '-x');
legend('RL', 'Random');
title('Average user price comparison');
ylabel('Avg. price');
xlabel('time');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, 'User_price_cmp.jpg'));
end

% Actual supply and ideal supply comparison
ideal_supply = sum(sum(Result.sup_ideal_supply,1)/day_num, 3);
sup_ideal = squeeze(ideal_supply./ideal_supply)*100;
sup_RL = squeeze(sum(sum(Result.sup_actual_supply_RL,1)/day_num,3)./ideal_supply)*100;
sup_Random = squeeze(sum(sum(Result.sup_actual_supply_Random,1)/day_num,3)./ideal_supply)*100;
figure();
plot(hour_intv,  sup_ideal, '-o', ...
       hour_intv,  sup_RL, '-x', ...
       hour_intv,  sup_Random, '-+');
legend('Ideal', 'RL', 'Random');
title('Supplier total supply comparison');
ylabel('%');
xlabel('hour');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, 'Supply.jpg'));
end

% Actual get and ideal need comparison
ideal_need = sum(sum(Result.usr_ideal_need,1)/day_num, 3);
usr_ideal = squeeze(ideal_need./ideal_need)*100;
usr_RL = squeeze(sum(sum(Result.usr_actual_get_RL,1)/day_num,3)./ideal_need)*100;
usr_Random = squeeze(sum(sum(Result.usr_actual_get_Random,1)/day_num,3)./ideal_need)*100;
figure();
plot(hour_intv,  usr_ideal, '-o', ...
       hour_intv,  usr_RL, '-x', ...
       hour_intv,  usr_Random, '-+');
legend('Ideal', 'RL', 'Random');
title('Percentage of user need comparison');
ylabel('%');
xlabel('hour');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, 'User Need.jpg'));
end

% Plot supplier average benefit of RL vs Random
figure();
sup_RL = squeeze(sum(sum(Result.sup_actual_supply_RL,1)/day_num,3));
sup_Random = squeeze(sum(sum(Result.sup_actual_supply_Random,1)/day_num,3));
plot(hour_intv,  sup_RL.*sup_avg_p_RL,  '-o', ...
       hour_intv,  sup_Random.*sup_avg_p_Random, '-x');
legend('RL', 'Random');
title('Average supplier benefit comparison');
ylabel('Avg $');
xlabel('Day');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, 'Average_supplier_benefit.jpg'));
end

% Plot supplier average benefit of RL vs Random 
figure();
usr_RL = squeeze(sum(sum(Result.usr_actual_get_RL,1)/day_num,3));
usr_Random = squeeze(sum(sum(Result.usr_actual_get_Random,1)/day_num,3));
plot(hour_intv,  usr_RL.*(1-usr_avg_p_RL/9), '-o', ...
       hour_intv,  usr_Random.*(1-usr_avg_p_Random/9), '-x');
legend('RL', 'Random');
title('Average user benefit comparison');
ylabel('Benefit Ratio');
xlabel('Day');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, 'Average_user_benefit.jpg'));
end

end