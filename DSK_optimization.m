%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [test_kernel,train_kernel,optimal_alpha] = DSK_optimization(train_data,train_label,test_data,opt)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input parameters:
% train_data: column cells containing the SPD matrices for training
% train_label: one column vector containing the labels for the training data
% test_data: test data with the same format as the training data
% opt:  a structure containing parameter settings
%       elements:
%       theta -- a kernel parameter
%       obj_method -- which criterion to be used 
%       original_alpha  set to 1 to use original Stein kernel or 0 to use DSK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output parameters:
% test_kernel: the adjusted test_kernel
% train_kernel: the adjusted train_kernel
% optimal_alpha: the optimized adjustment parameters alpha
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jianjia Zhang, jz163@uowmail.edu.au Dec, 2014, all rights reserved
% For implementation details, please refer to: 
% "Learning Discriminative Stein Kernel for SPD Matrices and Its Applications." 
% arXiv preprint arXiv:1407.1974 (2014).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [test_kernel,train_kernel,optimal_alpha] = DSK_optimization(train_data,train_label,test_data,opt)
nmode = size(train_data{1,1},1); % dimension of the SPD matrices
train_decomp = Decomposite_eig(train_data); % eigen decomposition of the training/test data
test_decomp = Decomposite_eig(test_data);
%%%%%%%%%%%%%%%%%%%%%%%%%
if(~opt.original_alpha)
    initial_alpha = 1*ones(1,nmode); % the initial alpha corresponding to the original Stein kernel
    LB = 0.01*initial_alpha; 
    
    options = optimset('Algorithm','interior-point'); % run interior-point algorithm
    options.Display = 'iter';
    options.MaxIter = 100;
    options.TolFun = 1e-5;
    tic
    optimal_alpha = fmincon(@(alpha) objfun_ff(alpha,train_label,train_decomp,opt.lambda,initial_alpha,opt.obj_method,opt.theta),initial_alpha,[],[],[],[],LB,[],[],options);
    toc
else
    optimal_alpha = ones(1,nmode);
end
[S_test] = EigComp2SD_power(train_decomp,test_decomp,optimal_alpha); % compute the Stein divergence with the obtained adjustment parameter optimal_alpha
[S_train] = EigComp2SD_power(train_decomp,train_decomp,optimal_alpha);
test_kernel = exp(-1*opt.theta*S_test); % compute the kernel
train_kernel = exp(-1*opt.theta*S_train);
end
