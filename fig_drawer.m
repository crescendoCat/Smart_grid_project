function cp = fig_drawer(supply, price, max_price, compute_time)
    tmp = [];
    [B, I] = sort(price, 2, 'ascend');
    disp(size(supply, 2));
    for i=1:size(supply, 2)
        n = ceil(supply(I(i)));
        tmp = [tmp B(i) * ones(1, n)];
    end
    
    y = (0:0.5:max(price));
    x = max_price * ones(1, size(y, 2));
    
    figure();
    hold on;
    stairs(tmp, 'b');
    plot(x, y, 'r');
    title(int2str(compute_time));
    xlabel('Energy (kW)')
    ylabel('quoted price');
    hold off;
    cp = tmp;
end

