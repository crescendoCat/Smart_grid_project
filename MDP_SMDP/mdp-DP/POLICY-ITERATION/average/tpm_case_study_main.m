xi=0.99;
psi=0.96;
CR=4;
CM=2;
NS=30;


tpm=zeros(NS,NS,2);
trm=zeros(NS,NS,2);

for i=1:NS
    
    for j=1:(NS-1)
        
        if i==j
            
            d=i-1;
            
            tpm(i,j+1,1)=xi*(psi^(d+2));
          
        end
        
        if j==1
            
            d= i-1;
            
            tpm(i,j,1)=1-xi*(psi^(d+2));
            tpm(i,j,2)=1;
            trm(i,j,1)=-CR;
            trm(i,j,2)=-CM;
        end
        
    end
    
end

tpm(NS,1,1)=1;
trm(NS,1,1)=-CR;
trm(NS,1,2)=-CM;


        
        tpm
        
        trm




[policy,V]=politamdp(tpm,trm);  

