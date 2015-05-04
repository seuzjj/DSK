%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function obj = objfun_ff(alpha,y,train_decomp,lambda,initial_alpha,method,theta)
% this function compute the objective function with given parameters
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input parameters:
% alpha: the optimized adjustment parameters
% y: the training label
% train_decomp: the eigen decomposition of the training data
% lambda:  the regularizer
% initial_alpha: the initial value of alpha to regularize alpha
% method: which criterion to be used
% theta: the kernel parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output parameters:
% obj: the objective value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jianjia Zhang, jz163@uowmail.edu.au Dec, 2014, all rights reserved
% For implementation details, please refer to: 
% "Learning Discriminative Stein Kernel for SPD Matrices and Its Applications." 
% arXiv preprint arXiv:1407.1974 (2014).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = objfun_ff(alpha,y,train_decomp,lambda,initial_alpha,method,theta)
[S] = EigComp2SD_power(train_decomp,[],alpha);
%[S] = EigComp2SD_coef(train_decomp,[],alpha);
K = exp(-1*theta*S);

d = length(y);
if(size(y,1)==1)
    
    mask1 = repmat(y,d,1);
    mask2 = repmat(y',1,d);
else
    mask1 = repmat(y',d,1);
    mask2 = repmat(y,1,d);
end
K0 = double(mask1==mask2);
K0(K0 ==0) = -1;

if(strcmp(method,'ka')) % compute the objective with kernel alignment criterion
    ka = sum(sum(K0 .* K));
    k00 = sum(sum(K0 .* K0));
    kkk = sum(sum(K .* K));
    obj = -ka/sqrt((k00*kkk)) + lambda*norm(alpha - initial_alpha);
    return;
end
end