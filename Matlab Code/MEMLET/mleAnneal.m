function [ fitted fVal exitflag output ] = mleAnneal(PDF,data,annealTemp,lb,ub,guess)
%MLEANNEAL this function fits a pdf with inputs guess to the data, data
%   It uses simulated annealing hybrid function to find the best fit to the
%   data. 

%sets all the options for the fitting, starting with the final
%patternsearch options which occurs after the annealing
hybridopts = psoptimset('TolFun',1e-10,'TolX',1e-7,'TolMesh',1e-7,'display','none','MaxIter',50000,'MaxFunEvals',60000,'TimeLimit',120);
%set the annealing options 
options = saoptimset('TolFun',1e-6,'TimeLimit',60,'display','none','InitialTemperature',annealTemp,'MaxIter',100000); 
options = saoptimset(options,'HybridFcn',{@patternsearch,hybridopts}); 

 if iscell(PDF) %for global fits , assembles all the PDFs together after taking the negative of the log of the likelihood
     PDFSt= ['logLikFunc = @(vargin) '];
     for i=1:length(PDF) %make a string with all of them subtracted 
        PDFSt=[PDFSt sprintf('-sum(log(PDF{%u}(data,vargin)))',i) ];
     end
     PDFSt=[PDFSt ';'];
     eval(PDFSt); %make it into another function 
 else % sum the negative of the log-likelihoods 
      logLikFunc = @(vargin) -sum(log(PDF(data,vargin))); 
 end
    [fitted fVal exitflag output]=simulannealbnd(logLikFunc,guess,lb,ub,options);
    % uncomment the next line if you wanted to fit without the annealing 
%     [fitted fVal exitflag output]=fminsearch(logLikFunc,vargin,hybridopts); 

fVal=-fVal; %return the actual log likelihood and not the opposite
end

