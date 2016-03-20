function [] = calband_visualize_transition_v01(initial_formation, ...
    target_formation, instructions, max_beats)

% Create an interactive figure to visualize a transition.
%
% CALBAND_VISUALIZE_TRANSITION_V01(initial_formation, target_formation,
% instructions, max_beats): visualize transition from initial formation
% to target formation, following a given set of instructions.
%
% Input argument(s):
%
% - initial_formation: initial formation array.
%
% - target_formation: target formation array.
%
% - instructions: array of instructions.
%
% - max_beats: maximum number of beats available for the transition.
%
% See also: CALBAND_VISUALIZE_TRANSITION_V01/cbl_visualize_transition

% Note(s) about the implementation:
%
% - the cbn_ (Cal Band, nested) prefix is used for nested functions.
%
% - the cbl_ (Cal Band, local) prefix is used for local functions (also
% known as sub-functions).
%
% - variable f1 is often used for the initial formation array (much
% shorter).
%
% - variable f2 is often used for the target formation array (much
% shorter).
%
% - variable inst is often used for the array of instructions (much
% shorter).

try
    fig = figure();
    cbl_visualize_transition(initial_formation, target_formation, ...
        instructions, max_beats, fig)
catch e
    close(fig)
    mid = 'calband_visualize_transition_v01:generalissue';
    msg = ['Something went wrong when setting up the transition ', ...
        'visualization. Please check the following error message(s) ', ...
        'to see what might have gone wrong.'];
    throw(addCause(MException(mid, msg), e));
end

end

function [] = cbl_visualize_transition(f1, f2, inst, max_beats, fig)

% Create an interactive figure to visualize a transition.
%
% CBL_VISUALIZE_TRANSITION(f1, f2, inst, max_beats): visualize transition
% from initial formation f1 to target formation f2, following instructions
% in inst.
%
% Input argument(s):
%
% - f1: initial formation array.
%
% - f2: target formation array.
%
% - inst: array of instructions.
%
% - max_beats: maximum number of beats available for the transition.
%
% - fig (optional): handle to the figure where the visualization is to be
% set up.
%
% Notes about the implementation:
%
% - This function does a significant amount of quality checking on f1, f2,
% and max_beats.
%
% - This function does some quality checking on inst.
%
% See also: CALBAND_VISUALIZE_TRANSITION_V01

% Note(s) about the implementation:
%
% - On the figure, a grid cell with row and column indices i and j
% (respectively) is the square with bottom corner located at (i-0.5, j-0.5)
% and of unit width/length (i.e. the side of the square is of length 1).

% Check the quality of the initial and target formation arrays
[valid, msg, nr, nc, nb] = cbl_check_formations(f1, f2);
if ~valid
    mid = 'cbl_visualize_transition:badformations';
    throw(MException(mid, msg));
end

% Check the quality of max_beats
[valid, msg] = cbl_check_max_beats(max_beats);
if ~valid
    mid = 'cbl_visualize_transition:badmaxbeats';
    throw(MException(mid, msg));
end

% Check the quality of the array of instructions
[valid, valid_inst, msg] = cbl_check_inst(f1, f2, inst, max_beats);
if ~valid
    mid = 'cbl_visualize_transition:baddinst';
    throw(MException(mid, msg));
end

% Set graphical (and related) parameters
max_frames = round(max_beats/2);
speed = 5;
xmin_grid = 0.5;
xmax_grid = nc + 0.5;
ymin_grid = 0.5;
ymax_grid = nr + 0.5;
if nr == nc
    xmin_frame = xmin_grid - 1;
    xmax_frame = xmax_grid + 1;
    ymin_frame = ymin_grid - 1;
    ymax_frame = ymax_grid + 1;
elseif nr > nc
    xmin_frame = -0.5 + (nc-ymax_grid+ymin_grid)/2;
    xmax_frame = 0.5 + (nc+ymax_grid-ymin_grid)/2;
    ymin_frame = ymin_grid - 1;
    ymax_frame = ymax_grid + 1;
else
    xmin_frame = xmin_grid - 1;
    xmax_frame = xmax_grid + 1;
    ymin_frame = -0.5 + (nr-xmax_grid+xmin_grid)/2;
    ymax_frame = 0.5 + (nr+xmax_grid-xmin_grid)/2;
end

% Get the linear indices of the initial and target locations
idx_initial = find(f1);
idx_target = find(f2);

% Get the linear indices of the locations of the marchers
bm_locations = zeros(nb, 1);
for ib = 1:nb
    bm_locations(f1(idx_initial(ib)), 1) = idx_initial(ib);
end

% Prepare the figure
if nargin < 5
    fig = figure();
end
set(fig, 'KeyPressFcn', @cbn_figure_key_press);
current_frame = 0;
last_frame = 0;
cbn_show_current_frame();

% -------------------------------------------------------------------------

    function [i, j] = cbn_idx2ij(idx)

        % Calculate row and column indices corresponding to linear index idx.
        %
        % CBN_IDX2IJ(i, j): calculate the row and column indices corresponding
        % to the linear index idx.
        %
        % Input argument(s):
        %
        % - idx: linear index in the grid.
        %
        % Output argument(s):
        %
        % - i and j: row and column indices, respectively, in the grid.
        %
        % See also: CBN_IJ2IDX CBN_IJ2XY CBN_IDX2XY

        [i, j] = ind2sub([nr, nc], idx);

    end

% -------------------------------------------------------------------------

    function [idx] = cbn_ij2idx(i, j)

        % Calculate linear index corresponding to row and column indices.
        %
        % CBN_IJ2IDX(i, j): calculate the linear index corresponding to the row
        % and column indices i and j, respectively.
        %
        % Input argument(s):
        %
        % - i and j: row and column indices, respectively, in the grid.
        %
        % Output argument(s):
        %
        % - idx: linear index in the grid.
        %
        % See also: CBN_IDX2IJ CBN_IJ2XY CBN_IDX2XY

        idx = sub2ind([nr, nc], i, j);

    end


% -------------------------------------------------------------------------

    function [x, y] = cbn_ij2xy(i, j)

        % Calculate the x- and y-location corresponding to indices i and j.
        %
        % CBN_IJ2XY(i, j): calculate the x- and y-location corresponding to the
        % row and column indices i and j, respectively.
        %
        % Input argument(s):
        %
        % - i and j: row and column indices, respectively, in the grid.
        %
        % Output argument(s):
        %
        % - x and y: x- and y-location for the plot.
        %
        % See also: CBN_IDX2IJ CBN_IJ2IDX CBN_IDX2XY

        x = j;
        y = nr - i + 1;

    end


% -------------------------------------------------------------------------

    function [x, y] = cbn_idx2xy(idx)

        % Calculate the x- and y-location corresponding to linear index idx.
        %
        % CBN_IDX2XY(i, j): calculate the x- and y-location corresponding to
        % linear index idx.
        %
        % Input argument(s):
        %
        % - idx: linear index in the grid.
        %
        % Output argument(s):
        %
        % - x and y: x- and y-location for the plot.
        %
        % See also: CBN_IDX2IJ CBN_IJ2IDX CBN_IJ2XY

        [i, j] = cbn_idx2ij(idx);
        [x, y] = cbn_ij2xy(i, j);

    end

% -------------------------------------------------------------------------

    function [] = cbn_calculate_missing_frames()

        % Calculate location of marchers for frames that have no data yet.
        %
        % CBN_CALCULATE_MISSING_FRAMES(): calculate the location of each
        % marcher (and save it in bm_locations) for all the frames that are
        % past the last_frame and before and up to the current frame.

        if current_frame <= last_frame
            return
        end

        for i_frame = last_frame+1:current_frame

            for ib = 1:nb

                [i_marcher, j_marcher] = cbn_idx2ij(bm_locations(ib, i_frame));

                % The marcher's new location does not change if at least
                % one of the following is true:                
                % - The instructions are not valid enough to let us calculate a
                %   new position
                % - The marcher is still waiting
                if ~all(structfun(@(x) x, valid_inst(ib)))

                    fprintf(['WARNING: Marcher %d is not moving because ', ...
                        'their instructions are not valid enough to ', ...
                        'calculate their new position (frame %d, beat ', ...
                        '%d).\n'], ib, i_frame, 2*i_frame)

                elseif round(inst(ib).wait/2) < i_frame

                    i_target = inst(ib).i_target;
                    j_target = inst(ib).j_target;

                    switch inst(ib).direction
                        case '.'
                        case 'N'
                            if j_target > j_marcher
                                j_marcher = j_marcher + 1;
                            end
                        case 'S'
                            if j_target < j_marcher
                                j_marcher = j_marcher - 1;
                            end
                        case 'E'
                            if i_target > i_marcher
                                i_marcher = i_marcher + 1;
                            end
                        case 'W'
                            if i_target < i_marcher
                                i_marcher = i_marcher - 1;
                            end
                        case 'NE'
                            if j_target > j_marcher
                                j_marcher = j_marcher + 1;
                            elseif i_target > i_marcher
                                i_marcher = i_marcher + 1;
                            end
                        case 'EN'
                            if i_target > i_marcher
                                i_marcher = i_marcher + 1;
                            elseif j_target > j_marcher
                                j_marcher = j_marcher + 1;
                            end
                        case 'NW'
                            if j_target > j_marcher
                                j_marcher = j_marcher + 1;
                            elseif i_target < i_marcher
                                i_marcher = i_marcher - 1;
                            end
                        case 'WN'
                            if i_target < i_marcher
                                i_marcher = i_marcher - 1;
                            elseif j_target > j_marcher
                                j_marcher = j_marcher + 1;
                            end
                        case 'SE'
                            if j_target < j_marcher
                                j_marcher = j_marcher - 1;
                            elseif i_target > i_marcher
                                i_marcher = i_marcher + 1;
                            end
                        case 'ES'
                            if i_target > i_marcher
                                i_marcher = i_marcher + 1;
                            elseif j_target < j_marcher
                                j_marcher = j_marcher - 1;
                            end
                        case 'SW'
                            if j_target < j_marcher
                                j_marcher = j_marcher - 1;
                            elseif i_target < i_marcher
                                i_marcher = i_marcher - 1;
                            end
                        case 'WS'
                            if i_target < i_marcher
                                i_marcher = i_marcher - 1;
                            elseif j_target < j_marcher
                                j_marcher = j_marcher - 1;
                            end
                        otherwise
                            fprintf(['WARNING: Something went wrong ', ...
                                'because this part of the code should ', ...
                                'be unreachable. Please report this bug.\n'])
                    end

                end

                % Prevent the indices i_marcher and j_marcher to be out of
                % range
                i_marcher = min(max(i_marcher, 1), nr);
                j_marcher = min(max(j_marcher, 1), nc);

                % Save the new location of the marcher
                bm_locations(ib, i_frame+1) = cbn_ij2idx(i_marcher, j_marcher);

            end

        end

        last_frame = current_frame;

    end

% -------------------------------------------------------------------------

    function cbn_show_current_frame()

        % Show current frame.
        %
        % CBN_SHOW_CURRENT_FRAME(): show (as in plot on the figure) the current
        % frame.

        cbn_calculate_missing_frames()

        % Prepare figure
        figure(fig)
        clf
        hold on
        axis equal tight
        axis off

        % Draw the grid
        for i = 1:nr+1
            y = i-0.5;
            plot([xmin_grid, xmax_grid], [y, y], 'k:')
        end
        for i = 1:nc+1
            x = i-0.5;
            plot([x, x], [ymin_grid, ymax_grid], 'k:')
        end

        % Draw the target locations
        for ib = 1:nb
            [x, y] = cbn_idx2xy(idx_target(ib));
           rectangle('Position', [x-0.5, y-0.5, 1, 1], 'Curvature', 0.65, ...
                'EdgeColor', [0.00, 0.84, 0.08], ...
                'FaceColor', [0.67, 1.00, 0.71])
        end

        % Draw the initial Locations
        for ib = 1:nb
            [x, y] = cbn_idx2xy(idx_initial(ib));
            rectangle('Position', [x-0.5, y-0.5, 1, 1], ...
                'EdgeColor', [0.30, 0.29, 0.97])
        end
        
        % Draw the collisions that result from marchers having switched
        % locations between the previous frame and the current frame
        if current_frame > 0
            
            for ib1 = 1:nb-1
                
                % There is no risk of such a collision if the marcher did
                % not move
                loc_1_old = bm_locations(ib1, current_frame);
                loc_1_new = bm_locations(ib1, current_frame+1);
                if loc_1_new == loc_1_old
                    continue
                end
                
                % Find the marchers who, in the previous frame, were
                % located where the marcher ib1 is currently located
                idx = find(bm_locations(:, current_frame) == loc_1_new);
                
                % Check if one or more of these marchers are now located
                % were the marcher ib1 was located in the previous frame
                for i = 1:numel(idx)
             
                   ib2 = idx(i);
                   loc_2_now = bm_locations(ib2, current_frame+1);
                    
                   % The ib < ib2 ensures that we show the warning only
                   % once per pair of marchers who switched locations
                   if ib1 < ib2 && loc_2_now == loc_1_old
                        
                       % Draw the graphic element that indicates the switch
                       [x1, y1] = cbn_idx2xy(loc_1_new);
                       [x2, y2] = cbn_idx2xy(loc_2_now);
                       position = [min(x1, x2)-0.5, min(y1, y2)-0.5, ...
                           1+(x1~=x2), 1+(y1~=y2)];
                       rectangle('Position', position, 'Curvature', 0.65, ...
                           'EdgeColor', [1.00, 0.06, 0.37], ...
                           'FaceColor', [1.00, 0.79, 0.15])
                       
                       % Show the corresponding warning
                       loc_2_new = bm_locations(ib2, current_frame+1);
                       [i_1, j_1] = cbn_idx2ij(loc_1_new);
                       [i_2, j_2] = cbn_idx2ij(loc_2_new);
                       fprintf(['WARNING: Marcher %d, now located at ', ...
                           '(%d, %d), and marcher %d, now located at ', ...
                           '(%d, %d), switched locations between beats ', ...
                           '%d and %d, and therefore they collided.\n'], ...
                           ib1, i_1, j_1, ib2, i_2, j_2, ...
                           2*(current_frame-1), 2*current_frame)
                        
                    end
                    
                end
                    
            end
            
        end

        % Draw the collisions that result from marchers being at the same
        % location in the current frame
        bm_locations_unique = unique(bm_locations(:,current_frame+1));
        for i = 1:numel(bm_locations_unique)

            idx = bm_locations_unique(i);
            same_locations = bm_locations(:,current_frame+1) == idx;

            if nnz(same_locations) > 1

                % Draw the graphic element that indicates the collision
                [x, y] = cbn_idx2xy(idx);
                plot(x, y, 'p', 'MarkerEdgeColor', [1.00, 0.06, 0.37], ...
                    'MarkerFaceColor', [1.00, 0.79, 0.15], ...
                    'MarkerSize', 25, 'LineWidth', 1.5)

                % Show the corresponding warning
                [i_marcher, j_marcher] = cbn_idx2ij(idx);
                msg = sprintf('%d, ', find(same_locations));
                fprintf(['WARNING: The following marchers are colliding ', ...
                    'at location (%d, %d) and beat %d: %s.\n'], ...
                    i_marcher, j_marcher, 2*current_frame, msg(1:end-2))

            end
        end
        
        % Draw the North, South, East, and West indications
        text(xmax_grid, 0.5*(ymin_grid+ymax_grid), ' N', 'Fontsize', 12, ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')
        text(xmin_grid, 0.5*(ymin_grid+ymax_grid), 'S ', 'Fontsize', 12, ...
            'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle')
        text(0.5*(xmin_grid+xmax_grid), ymin_grid, 'E', 'Fontsize', 12, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
        text(0.5*(xmin_grid+xmax_grid), ymax_grid, 'W', 'Fontsize', 12, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
        
        % Draw the marchers
        for ib = 1:nb
            [x, y] = cbn_idx2xy(bm_locations(ib,current_frame+1));
            text(x, y, sprintf('%d', ib), 'Fontsize', 12, ...
                'HorizontalAlignment', 'Center', ...
                'VerticalAlignment', 'middle');
        end
        
        % Draw the frame and other decor
        plot([xmin_grid, xmin_grid, xmax_grid, xmax_grid, xmin_grid], ...
            [ymin_grid, ymax_grid, ymax_grid, ymin_grid, ymin_grid], 'k-')
        axis([xmin_frame, xmax_frame, ymin_frame, ymax_frame])
        cbn_set_title()

        % Show a congratulation message if the target formation is reached at
        % the last time step
        if current_frame == max_frames && ...
                all(ismember(idx_target, bm_locations(:,current_frame+1)))
            text(0.5*(xmin_grid+xmax_grid), 0.5*(ymin_grid+ymax_grid), ...
                'CONGRATULATIONS!', 'FontSize', 25, 'Color', 'r', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
            fprintf(['\n\nCONGRATULATIONS! You reached the target ', ...
                'formation!\n\n'])
        end

    end

% -------------------------------------------------------------------------

    function [] = cbn_set_title()

        % Set the figure's title.
        %
        % CBN_SET_TITLE(): set the figure's title

        title(sprintf(['Frame %d out of %d (beat %d out of %d)'], ...
            current_frame, max_frames, current_frame*2, max_beats))

    end

% -------------------------------------------------------------------------

    function [] = cbn_figure_key_press(fig, event)

        % Callback function for figure key press events when input not allowed.
        %
        % Input argument(s):
        %
        % - fig: handle to the figure from where this callback function is
        % called.
        %
        % - event: the event that triggered the callback.

        switch event.Key

            case {'escape', 'q'}
                % Close the figure
                close(fig)

            case {'leftarrow', 'uparrow'}
                % Go back one frame
                if current_frame > 0
                    current_frame = current_frame - 1;
                    cbn_show_current_frame();
                end

            case {'rightarrow', 'downarrow'}
                % Go forward one frame
                if current_frame < max_frames
                    current_frame = current_frame + 1;
                    cbn_show_current_frame();
                end

            case {'return'}
                % Run the transition forward starting from the current frame
                set(fig, 'KeyPressFcn', @cbn_figure_key_press_null);
                for current_frame = current_frame+1:max_frames
                    cbn_show_current_frame();
                    pause(1/speed)
                end
                set(fig, 'KeyPressFcn', @cbn_figure_key_press);

            case {'backspace'}
                % Run the transition backwards starting from the current frame
                set(fig, 'KeyPressFcn', @cbn_figure_key_press_null);
                for current_frame = current_frame-1:-1:0
                    cbn_show_current_frame();
                    pause(1/speed)
                end
                set(fig, 'KeyPressFcn', @cbn_figure_key_press);

            case {'pageup', 'home'}
                % Jump to the initial frame
                current_frame = 0;
                cbn_show_current_frame();

            case {'pagedown', 'end'}
                % Jump to the final frame
                current_frame = max_frames;
                cbn_show_current_frame();

            case {'f'}
                % Increase the visualizer frame rate
                speed = speed + 1;
                cbn_set_title()

            case {'s'}
                % Decrease the visualizer frame rate
                speed = max(speed - 1, 1);
                cbn_set_title()

            case {'h'}
                % Show the help menu
                fprintf('\nAvailable keyboard commands:\n\n')
                fprintf('right or down arrow ... Next frame\n')
                fprintf('left or up arrow ...... Previous frame\n')
                fprintf('home key or page up ... Initial frame\n')
                fprintf('end key or page down .. Last frame\n')
                fprintf('escape key or q ....... Close figure\n')
                fprintf('enter ................. Run transition forward\n')
                fprintf('backspace ............. Run transition backward\n')
                fprintf(['f ..................... Increase visualizer ', ...
                    'frame rate\n'])
                fprintf(['s ..................... Decrease visualizer ', ...
                    'frame rate\n'])
                fprintf('h ..................... Show this help\n')
                fprintf('\n')

            otherwise
                fprintf(['\nPressing key "%s" has no effect. ', ...
                    'Press h for help.\n\n'], event.Key)
        end
    end

% -------------------------------------------------------------------------

    function [] = cbn_figure_key_press_null(fig, event)

        % Callback function for figure key press events when input not allowed.
        %
        % Input argument(s):
        %
        % - fig: handle to the figure from where this callback function is
        % called
        %
        % - event: the event that triggered the callback.

        fprintf('\nUser input deactivated while running!\n\n');
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg, nr, nc, nb] = cbl_check_formations(f1, f2)

% Check the validity of an initial and a target formation array.
%
% CBL_CHECK_FORMATIONS(f1, f2): check whether f1 is a valid initial
% formation array and f2 is a valid target formation array for initial
% formation array f1. Also check that the number of rows, columns, and
% marchers are the same in f1 and f2.
%
% Input argument(s):
%
% - f1: initial formation array to check.
%
% - f2: target formation array to check.
%
% Output argument(s) if both arrays are valid:
%
% - valid: true.
%
% - msg: empty character string.
%
% - nr: number of rows in the grid.
%
% - nc: number of columns in the grid.
%
% - nb: number of marchers in the formation.
%
% Output argument(s) if at least one of the array is not valid (or if the
% number of rows, columns, and marchers is not consistent across the
% two arrays):
%
% - valid: false.
%
% - msg: character string that describes the issue.
%
% - nb: NaN.
%
% - nr: NaN.
%
% - nc: NaN.
%
% See also: CBL_CHECK_FORMATION

nr = NaN;
nc = NaN;
nb = NaN;

% Check the validity of the initial formation array
[valid, msg, nr_i, nc_i, nb_i] = cbl_check_formation(f1, true);
if ~valid
    msg = sprintf('The initial formation array is not valid: %s', msg);
    return
end

% Check the validity of the target formation array
[valid, msg, nr_t, nc_t, nb_t] = cbl_check_formation(f2, false);
if ~valid
    msg = sprintf('The target formation array is not valid: %s', msg);
    return
end

% Check the consistency of the number of rows
if nr_i ~= nr_t
    msg = sprintf(['The number of rows is inconsistent between the ', ...
        'initial formation array and the target formation array: %d and ', ...
        '%d, respectively.'], nr_i, nr_t);
    valid = false;
    return
end

% Check the consistency of the number of columns
if nc_i ~= nc_t
    msg = sprintf(['The number of columns is inconsistent between the ', ...
        'initial formation array and the target formation array: %d and ', ...
        '%d, respectively.'], nc_i, nc_t);
    valid = false;
    return
end

% Check the consistency of the number of marchers
if nb_i ~= nb_t
    msg = sprintf(['The number of marchers is inconsistent between the ', ...
        'initial formation array and the target formation array: %d and ', ...
        '%d, respectively.'], nb_i, nb_t);
    valid = false;
    return
end

% If we reach this point, then the formation arrays are valid and
% consistent
msg = '';
nr = nr_i;
nc = nc_i;
nb = nb_i;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg, nr, nc, nb] = cbl_check_formation(f, is_initial)

% Check the validity of an initial or target formation array.
%
% CBL_CHECK_FORMATION(f, is_initial): check whether f is a valid initial
% (if is_initial is true) or target (if is_initial is false) formation
% array.
%
% Input argument(s):
%
% - f: formation array to check.
%
% - is_initial: true if the array to check is an initial formation array,
% false otherwise.
%
% Output argument(s) if the formation array is valid:
%
% - valid: true.
%
% - msg: empty character string.
%
% - nr: number of rows in the grid.
%
% - nc: number of columns in the grid.
%
% - nb: number of marchers in the formation.
%
% Output argument(s) if the formation array is not valid:
%
% - valid: false.
%
% - msg: character string that describes the issue.
%
% - nb: NaN.
%
% - nr: NaN.
%
% - nc: NaN.
%
% See also: CBL_CHECK_FORMATIONS

valid = false;
nr = NaN;
nc = NaN;
nb = NaN;

% The formation array must be of class double
if ~strcmp(class(f), 'double')
    msg = sprintf(['The formation array must be of class double, but ', ...
        'your input is of class %s.'], class(f));
    return
end

% The formation array must be a 2-D array
s = size(f);
n = numel(s);
if n ~= 2;
    msg = sprintf(['The formation array must be a 2-D array, but your ', ...
        'input has %d dimensions.'], n);
    return
end

% The formation array must have at least one row and one column
if s(1) == 0 || s(2) == 0
    msg = sprintf(['The formation array must have at least one row and ', ...
        'one column, your input has %d row(s) and %d column(s).'], s(1), s(2));
    return
end

% All values in the formation array must be zero or positive integers, and
% there must be at least one non-zero value
nb_local = max(max(f));
if nb_local <= 0 || any(any(f < 0 | rem(f, 1)~=0))
    msg = ['All values in the formation array must be zero or positive ', ...
        'integers, and there must be at least one marcher. At least one ', ...
        'of these conditions is not satisfied with your input.'];
    return
end

if is_initial

    % There must be exactly one non-zero value in the initial formation
    % array for each marcher, and these values must be the integers
    % from 1 to nb
    if ~all(ismember(1:nb_local, f)) || nnz(f)~=nb_local
        msg = 'There are missing or repeated marchers in your input.';
        return
    end

else

    % The only accepted values in the target formation array are 0 and 1,
    % and there must be exactly as many ones are there are marchers
    nb_local = nnz(f);
    if any(any(f ~= 0 & f ~= 1))
        msg = ['The target formation array must be full of zeros and ', ...
            'ones (and nothing else). Your input has at least one value ', ...
            'that is not zero and not one.'];
        return
    end

end

% If we reach this point, then the formation array is valid
valid = true;
msg = '';
nr = s(1);
nc = s(2);
nb = nb_local;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg] = cbl_check_max_beats(max_beats)

% Check the validity of max_beats.
%
% CBL_CHECK_MAX_BEATS(max_beats): check the validity of max_beats.
%
% Input argument(s):
%
% - max_beats: maximum number of beats available for the transition.
%
% Output argument(s) if max_beats is valid:
%
% - valid: true.
%
% - msg: empty character string.
%
% Output argument(s) if max_beats is not valid:
%
% - valid: false.
%
% - msg: character string that describes the issue.

valid = false;

% The input must be of class double
if ~strcmp(class(max_beats), 'double')
    msg = sprintf(['The input max_beats must be of class double, but ', ...
        'your input is of class %s.'], class(max_beats));
    return
end

% The input must be a scalar
s = size(max_beats);
if ~isequal(s, [1, 1])
    msg = sprintf('%dx', s);
    msg = sprintf(['The input max_beats must be a scalar, but your input ', ...
        'is a %s array.'], msg(1:end-1));
    return
end

% The input must be a strictly positive even integer
if max_beats <= 0 || rem(max_beats, 2) ~= 0
    msg = sprintf(['The input max_beats must be a strictly positive ', ...
        'even integer, but your input is %f.'], max_beats);
    return
end

% If we reach this point, then the input is valid
valid = true;
msg = '';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, valid_inst, msg] = cbl_check_inst(f1, f2, inst, max_beats)
%
% Check whether the array of instructions inst is valid enough.
%
% CBL_CHECK_INST(f1, f2, inst, max_beats): check whether the array of
% instructions inst is valid enough to be able to show the visualizer.
%
% Input argument(s):
%
% - f1: initial formation array.
%
% - f2: target formation array.
%
% - inst: array of instructions.
%
% - max_beats: maximum number of beats available for the transition.
%
% Output argument(s) if the array of instructions is valid enough:
%
% - valid: true.
%
% - valid_inst: 1 by nb struct array (where nb is the number of marchers
% involved in the transition) with fields i_target, j_target, direction,
% and wait. Each value in valid_inst is a logical that it true if and only
% the corresponding value in inst is valid.
%
% - msg: empty character string.
%
% Output argument(s) if the array of instructions is not valid:
%
% - valid: false.
%
% - valid_inst: empty struct array.
%
% - msg: character string that describes the issue.

valid = false;
valid_inst = [];

% The formation array must be of class struct
if ~strcmp(class(inst), 'struct')
    msg = sprintf(['The array of instructions must be of class struct, ', ...
        'but your input is of class %s.'], class(inst));
    return
end

% The array of instructions must be of size 1 by nb
[valid_local, msg_local, nr, nc, nb] = cbl_check_formations(f1, f2);
s = size(inst);
if ~isequal(s, [1, nb])
    msg = sprintf('%dx', s);
    msg = sprintf(['There are %d marchers in the formation arrays, so ', ...
        'the array of instructions must be a 1x%d struct array, but ', ...
        'your input is a %s struct array.'], nb, nb, msg(1:end-1));
    return
end

% The array of instructions must have the fields defined in fields_req
fields_req = {'i_target'; 'j_target'; 'direction'; 'wait'};
fields = fieldnames(inst);
if ~all(ismember(fields_req, fields))
    msg1 = sprintf('%s, ', fields_req{:});
    msg2 = sprintf('%s, ', fields{:});
    msg = sprintf(['The array of instructions must have the following ', ...
        'fields: (%s), but your input has the following fields: (%s)'], ...
        msg1(1:end-2), msg2(1:end-2));
    return
end

% What follow are additional checks that result into warnings, not errors

% Check whether there are extra fields in the array of instructions
extra_fields = fields(~ismember(fields, fields_req));
if numel(extra_fields) ~= 0
    msg = sprintf('%s, ', extra_fields{:});
    fprintf(['WARNING: The following fields in your array of ', ...
        'instructions are superfluous: (%s). You should remove them.\n'], ...
        msg(1:end-2))
end

% Check the validity of each field for each marcher
check_int_min = @(x, m) (strcmp(class(x), 'double') && ...
    isequal(size(x), [1, 1]) && rem(x, 1) == 0 && x >= m);

for ib = 1:nb

    % Check i_target
    i_target = inst(ib).i_target;
    valid_inst(ib).i_target = check_int_min(i_target, 1);
    if ~valid_inst(ib).i_target
        fprintf(['WARNING: Instruction (field i_target) for marcher %d ', ...
            'is not valid.\n'], ib);
    end

    % Check j_target
    j_target = inst(ib).j_target;
    valid_inst(ib).j_target = check_int_min(j_target, 1);
    if ~valid_inst(ib).j_target
        fprintf(['WARNING: Instruction (field j_target) for marcher %d ', ...
            'is not valid.\n'], ib);
    end

    % Check direction
    direction = inst(ib).direction;
    valid_inst(ib).direction = strcmp(class(direction), 'char') && ...
        (strcmp(direction, '.') || ...
        strcmp(direction, 'N') || strcmp(direction, 'S') || ...
        strcmp(direction, 'E') || strcmp(direction, 'W') || ...
        strcmp(direction, 'NE') || strcmp(direction, 'EN') || ...
        strcmp(direction, 'NW') || strcmp(direction, 'WN') || ...
        strcmp(direction, 'SE') || strcmp(direction, 'ES') || ...
        strcmp(direction, 'SW') || strcmp(direction, 'WS'));
    if ~valid_inst(ib).direction
        fprintf(['WARNING: Instruction (field direction) for marcher %d ', ...
            'is not valid.\n'], ib);
    end

    % Check wait
    wait = inst(ib).wait;
    valid_inst(ib).wait = check_int_min(wait, 0) && rem(wait, 2) == 0 && ...
        wait <= max_beats;
    if ~valid_inst(ib).wait
        fprintf(['WARNING: Instruction (field wait) for marcher %d is ', ...
            'not valid.\n'], ib);
    end

    if valid_inst(ib).i_target && valid_inst(ib).j_target

        % Is the target in the grid?
        if i_target > nr || j_target > nc

            fprintf(['WARNING: The target (%d, %d) assigned to marcher ', ...
                '%d is outside of the grid.\n'], i_target, j_target, ib)

        % Is the target an actual target location in the target formation?
        elseif f2(i_target, j_target) ~= 1

        fprintf(['WARNING: The target (%d, %d) assigned to marcher %d is ', ...
            'not a target location in the target formation.\n'], i_target, ...
            j_target, ib)
        end

        % Does the direction point towards the target location?
        [i_marcher, j_marcher] = ind2sub([nr, nc], find(f1 == ib));
        same_row = i_marcher == i_target;
        same_col = j_marcher == j_target;
        if same_row && same_col
            answer = strcmp(direction, '.');
        elseif same_row
            answer = strcmp(direction, 'N') && j_target > j_marcher || ...
                strcmp(direction, 'S') && j_target < j_marcher;
        elseif same_col
            answer = strcmp(direction, 'E') && i_target > i_marcher || ...
                strcmp(direction, 'W') && i_target < i_marcher;
        elseif strcmp(direction, 'NE') || strcmp(direction, 'EN')
            answer = i_target > i_marcher && j_target > j_marcher;
        elseif strcmp(direction, 'NW') || strcmp(direction, 'WN')
            answer = i_target < i_marcher && j_target > j_marcher;
        elseif strcmp(direction, 'SE') || strcmp(direction, 'ES')
            answer = i_target > i_marcher && j_target < j_marcher;
        elseif strcmp(direction, 'SW') || strcmp(direction, 'WS')
            answer = i_target < i_marcher && j_target < j_marcher;
        else
            answer = false;
        end
        if ~answer
            fprintf(['WARNING: Marcher %d cannot reach their target (%d, ', ...
                '%d) from their initial position (%d, %d) by following ', ...
                'their assigned direction: %s.\n'], ib, i_target, j_target, ...
                i_marcher, j_marcher, direction)
        end

        % Can the marcher cover the distance to their target location in
        % the allowed number of beats?
        if valid_inst(ib).wait
            d = abs(j_marcher - j_target) + abs(i_marcher - i_target);
            if d > (max_beats - wait)/2
                fprintf(['WARNING: Marcher %d cannot reach their ', ...
                    'target (%d, %d) from their initial position (%d, ', ...
                    '%d) in %d beats or less after waiting for %d beats ', ...
                    '(they need to travel a distance of %d).\n'], ib, ...
                    i_target, j_target, i_marcher, j_marcher, max_beats, ...
                    wait, d)
            end
        end

    end

end

% If we reach this point, then the array of instructions is valid
valid = true;
msg = '';

end
