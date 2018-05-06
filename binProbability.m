function a = binProbability(X, p, n)
    a = nchoosek(n,X) * p^X * (1-p)^(n-X);
    
end