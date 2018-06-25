function cp = fig_draw_preprocess(supply, price)
    tmp = [];
    [B, I] = sort(price, 2, 'ascend');
    %disp(supply);
    %disp(I);
    for i=1:size(supply, 2)
        n = round(supply(I(i)));
        tmp = [tmp B(i) * ones(1, n)];
    end
    cp = tmp;
end