global  NA NSD TPM TRM TTM EPSILON

 

NA=2; % Number of actions in each state 
NSD=2; % Number of states 

TPM=zeros(NSD,NSD,NA);
TRM=zeros(NSD,NSD,NA);
TTM=zeros(NSD,NSD,NA);
TPM(:,:,1)=[0.7,0.3;0.4,0.6];

TPM(:,:,2)=[0.9,0.1;0.2,0.8];

TRM(:,:,1)=[6,-5;7,12];
    
TRM(:,:,2)=[10,17;-14,13];

TTM(:,:,1)=[1,5;120,60];

TTM(:,:,2)=[50,75;7,2];


EPSILON=0.01;