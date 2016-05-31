function metaData=Simple_Custom_PDF_Example(arg1)
%the function should have atleast one argument and should return the
%metaData structure with the following fields: 

% The metaData variable contains all the information about the PDF
  metaData=struct('name','Simple Example',...   %replace **Simple Example** with a name for the PDF to appear in the drop down list 
           'PDF',   'k1*exp(-k1*x)',...         % replace **k1*exp(-k1*t)** with the functional form of the PDF as a string,
           'dataVar','x',...                    % replace **x** with a comma separated string of all the data Variables          
           'fitVar', 'k1',...                   % replace **k1** with a comma separated string of all the  fitting Variables
           'ub',   '100',...                   % replace **100** with a comma separated string of the default upper bounds in the same order as fitVar above
           'lb',   '0' ,...                    % replace **0** with a comma separated string of the default lower bounds in the same order as fitVar above
           'guess','1');                       % replace **1** with a comma separated string of the default guesses in the same order as fitVar above
    
      
  