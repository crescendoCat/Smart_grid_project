get_RL = mean(sum(sum(Result.usr_actual_get_RL(1:10, :, :), 3),2))
get_Rand = mean(sum(sum(Result.usr_actual_get_Random(1:10, :, :), 3),2))
need = mean(sum(sum(Result.usr_ideal_need(1:10, :, :), 3),2))
sup = mean(sum(sum(Result.sup_ideal_supply(1:10, :, :), 3),2))
out = [get_Rand / sup get_RL / sup; ...
get_Rand / need get_RL / need]

usr_price_day_Random = ones(39, 12, 3);
for d=1:39
usr_price_day_Random(d, :, :) = Result.usr_price_Random((d-1)*12+1:(d-1)*12+12, :);
end
usr_price = sum(sum(Result.usr_actual_get_Random(:, :, :).*usr_price_day_Random(:,:,:)));

usr_price_day_RL = ones(39, 12, 3);
for d=1:39
usr_price_day_RL(d, :, :) = Result.usr_price_RL((d-1)*12+1:(d-1)*12+12, :);
end
usr_price_RL = sum(sum(Result.usr_actual_get_RL(:, :, :).*usr_price_day_RL(:,:,:)));
sum((usr_price_RL - usr_price) ./ usr_price)/3

sup_price_day_Random = ones(39, 12, 19);
for d=1:39
sup_price_day_Random(d, :, :) = Result.sup_price_Random((d-1)*12+1:(d-1)*12+12, :);
end
sup_price = sum(sum(Result.sup_actual_supply_Random(:, :, :).*sup_price_day_Random(:,:,:)));

sup_price_day_RL = ones(39, 12, 19);
for d=1:39
sup_price_day_RL(d, :, :) = Result.sup_price_RL((d-1)*12+1:(d-1)*12+12, :);
end
sup_price_RL = sum(sum(Result.sup_actual_supply_RL(:, :, :).*sup_price_day_RL(:,:,:)));
sum((sup_price_RL - sup_price) ./ sup_price) / 19