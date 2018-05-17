function draw_result(Result, day_num)
% Description:
%   This is function for plotting the result.
%   Author: Chan-Wei Hu
%=========================================================================
output_dir = '../Result/';
SAVE_FLAG = 0;

% Plot supplier average benefit of RL vs Random 
figure();
plot(1:1:day_num,  Result.mean_sup_benefit_RL, '-o', ...
     1:1:day_num,  Result.mean_sup_benefit_Random, '-x');
legend('RL', 'Random');
title('Average supplier benefit comparison');
ylabel('Benefit Ratio');
xlabel('Day');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, 'Average_supplier_benefit.jpg'));
end

% Plot supplier average benefit of RL vs Random 
figure();
plot(1:1:day_num,  Result.mean_usr_benefit_RL, '-o', ...
     1:1:day_num,  Result.mean_usr_benefit_Random, '-x');
legend('RL', 'Random');
title('Average user benefit comparison');
ylabel('Benefit Ratio');
xlabel('Day');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, 'Average_user_benefit.jpg'));
end
% Plot demand and supply balance
figure();
hour_intv = 7:1:18;
plot(hour_intv, Result.demand(109:120), '-+', ...
     hour_intv, Result.actual_supply_RL(109:120), '-o', ... 
     hour_intv, Result.actual_supply_Random(109:120), '-x'); 
legend('demand', 'actual supply RL', 'actual supply Random');
title('Demand vs Supply');
ylabel('kW');
xlabel('Time');
if SAVE_FLAG
    saveas(gcf, strcat(output_dir, 'Demand vs Supply.jpg'));
end
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
end