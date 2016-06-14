function [ fitted fVal exitflag output ] = mleAnneal(PDF,data,lb,ub,vargin)
%MLEANNEAL (v1.0) this function fits a pdf with inputs vargin to the data, data
%   It uses simulated annealing hybrid function to find the best fit to the
%   data. 
global tdead
hybridopts = psoptimset('TolFun',1e-8,'TolX',1e-8,'display','none','MaxIter',500000,'MaxFunEvals',20000);
options = saoptimset('TolFun',1e-8,'TimeLimit',10,'display','none','InitialTemperature',0.5,'MaxIter',20000);%,'HybridFcn',fminsearch); 
  options = saoptimset(options,'HybridFcn',{@patternsearch,hybridopts}); 
    if iscell(PDF) %for global fits 
     PDFSt= ['logLikFunc = @(vargin) '];
     for i=1:length(PDF)
        PDFSt=[PDFSt sprintf('-sum(log(PDF{%u}(data,vargin)))',i) ];
     end
     PDFSt=[PDFSt ';'];
     eval(PDFSt);
 else
      logLikFunc = @(vargin) -sum(log(PDF(data,vargin))); 
 end
    [fitted fVal exitflag output]=simulannealbnd(logLikFunc,vargin,lb,ub,options);
    fVal=-fVal; %return the actual log likelihood and not the opposite
end

