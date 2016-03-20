function [instructions] = calband_transition(initial_formation, target_formation, max_beats)
% This function is a template to help you get started with your project
% Note that you should change the function and file name to
%   calband_transition for your submissions, as specified in the project guidelines pdf.
% Also note that this function satisfies all the basic requirements for the
%   problem as well as demonstrating appropriate commenting techniques.
% On that note, as you progress in the assignment, remember to check back 
%   that you are still meeting these basic requirements, as it is easy to lose
%   the fundementals as you get more entrenched in a complex problem.

% Finds the number of bandmembers by adding up all the 1s in the target
n_bandmembers = sum(sum(target_formation));

% Makes a structure with the appropriate fields (without any actual data)
% and copies it nb times to get a 1 x nb array of structs
instructions = struct('i_target',[],'j_target',[],'wait',[],'direction',[]);
instructions = repmat(instructions,1,n_bandmembers);

% This code finds the i and j indices of each target location and stores
% them in i and j, respectively (note that i and j are not used as of yet!)
[i,j] = find(target_formation);

% Now it is up to you to figure out how to use the information provided
% to fill out the instructions struct array with appropriate values!

end