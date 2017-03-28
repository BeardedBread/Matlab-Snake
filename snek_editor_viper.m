%% Information
%   Original author: En Yi
%   A map editor for the snake game created by the same author
%   Have fun!
%   Anyone can modify it, just need to give credits to the original author

function snek_editor_viper()
%% Define variables
file_name = '';map = {};map_name = {};speed = 0;
num_of_map = 0;current_map = 1;selected_map = [];
player_body = {};selected_body=[];colours = {};selected_colour = [];
prev_X = 0;prev_Y = 0;edit_enable=0;
default_colours = [0.7 0.2 0.5];
%% Prepare the window
%Create the window
scrsz = get(0,'ScreenSize');
min_dim = min(scrsz(3:4)/1.2);
win = figure('ToolBar',...
    'none','Name','SNEK Map Editor','NumberTitle','off','MenuBar','none',...
    'Resize','off','Visible','off','Color',[170 255 211]/255,...
    'Position',[scrsz(3)/8,scrsz(4)/8,min_dim,min_dim],...
    'WindowButtonMotionFcn',@display_mouse_pos);
%Prepare the block units
blk = 33;
blocks = min_dim/blk;
%% Prepare the UI components
%Create the map list
map_listbox = uicontrol('Style','listbox','Position',[1,19,6,11]*blocks,...
    'String',map_name,'Max',1,'Min',1,'Callback',@show_map);
%Create the map grid
map_panel = uipanel('Position',[8,7,23,23]/blk);
map_axes = axes('Parent',map_panel);
%UI to handle map packs
mappack_name_text = uicontrol('Style','text','Position',[1,31.5,7,1]*blocks,...
    'String','Pack Name');
mappack_name_edit = uicontrol('Style','edit','Position',[1,30.5,7,1]*blocks);
change_mappack_button = uicontrol('Style','pushbutton','Position',[9,31,6,1.5]*blocks,...
    'String','Change Map Pack','Callback',@change_mappack);
create_mappack_button = uicontrol('Style','pushbutton','Position',[16,31,6,1.5]*blocks,...
    'String','New Map Pack','Callback',@new_mappack);
%Buttons to sort the map order
sort_up_button = uicontrol('Style','pushbutton','Position',[1,17,2.5,2]*blocks,...
    'String','UP','Callback',{@sort_map,-1});
sort_down_button = uicontrol('Style','pushbutton','Position',[4,17,2.5,2]*blocks,...
    'String','DOWN','Callback',{@sort_map,1});
%Buttons to create and delete maps, and save the current changes to the pack
new_button = uicontrol('Style','pushbutton','Position',[1,15,4,2]*blocks,...
    'String','New','Callback',@new_map);
delete_button = uicontrol('Style','pushbutton','Position',[1,13,4,2]*blocks,...
    'String','Delete','Callback',@delete_map);
save_button = uicontrol('Style','pushbutton','Position',[1,11,4,2]*blocks,...
    'String','Save','Callback',@save_map,'Interruptible','off','BusyAction','cancel');
%UI to change the map name
map_name_text = uicontrol('Style','text','Position',[1,9,5,1]*blocks,...
    'String','Map Name');
map_name_edit = uicontrol('Style','edit','Position',[1,8,5,1]*blocks,...
    'Callback',@edit_map_name);
%UI to change the map size
map_width_text = uicontrol('Style','text','Position',[1,6,2.5,1]*blocks,...
    'String','Width');
map_width_edit = uicontrol('Style','edit','Position',[4,6,2,1]*blocks,...
    'Callback',@resize_map);
map_width_text = uicontrol('Style','text','Position',[1,5,2.5,1]*blocks,...
    'String','Height');
map_height_edit = uicontrol('Style','edit','Position',[4,5,2,1]*blocks,...
    'Callback',@resize_map);
%UI to reset the map changes
reset_button = uicontrol('Style','pushbutton','Position',[1,1,5,2]*blocks,...
    'String','Reset changes','Callback',@reset_changes);
%UI to change the speed of the game
speed_text = uicontrol('Style','text','Position',[7,5.5,2.5,1]*blocks,...
    'String','Speed');
speed_slider = uicontrol('Style','slider','Position',[10,5.5,9,1]*blocks,'value',12.5,...
    'String','Speed','Callback',@change_speed,'Min',1,'Max',25,'SliderStep',[0.1 1]/24);
speed_value_text = uicontrol('Style','text','Position',[19,5.5,2.5,1]*blocks,...
    'HorizontalAlignment','center');
%UI for the editor manual
help_button = uicontrol('Style','pushbutton','Position',[28,1,5,2]*blocks,...
    'String','Need Help?','Callback',@open_manual);
%UI for displaying the version
version_text = uicontrol('Style','text','Position',[26.5,-1,7,2]*blocks,...
    'String','V1.1 Made by En Yi','BackgroundColor',[170 255 211]/255);
%UI for displaying the mouse position
mouse_xpos_text = uicontrol('Style','text','Position',[1,3.5,2.5,1]*blocks,...
    'HorizontalAlignment','center');
mouse_ypos_text = uicontrol('Style','text','Position',[4,3.5,2.5,1]*blocks,...
    'HorizontalAlignment','center');
redefine_player_toggle = uicontrol('Style','togglebutton','Position',[22,5.5,8,1.5]*blocks,...
    'String','Redefine player position');
%UI for snake colour
colour_red_text = uicontrol('Style','text','Position',[7,4,2.5,1]*blocks,...
    'String','Red');
colour_red_slider = uicontrol('Style','slider','Position',[10,4,9,1]*blocks,...
    'String','Speed','Callback',@change_colour,'Min',0,'Max',1,'SliderStep',[0.01 0.1]);
red_value_text = uicontrol('Style','text','Position',[19,4,2.5,1]*blocks,...
    'HorizontalAlignment','center');
colour_green_text = uicontrol('Style','text','Position',[7,2.5,2.5,1]*blocks,...
    'String','Green');
colour_green_slider = uicontrol('Style','slider','Position',[10,2.5,9,1]*blocks,...
    'String','Speed','Callback',@change_colour,'Min',0,'Max',1,'SliderStep',[0.01 0.1]);
green_value_text = uicontrol('Style','text','Position',[19,2.5,2.5,1]*blocks,...
    'HorizontalAlignment','center');
colour_blue_text = uicontrol('Style','text','Position',[7,1,2.5,1]*blocks,...
    'String','Blue');
colour_blue_slider = uicontrol('Style','slider','Position',[10,1,9,1]*blocks,...
    'String','Speed','Callback',@change_colour,'Min',0,'Max',1,'SliderStep',[0.01 0.1]);
blue_value_text = uicontrol('Style','text','Position',[19,1,2.5,1]*blocks,...
    'HorizontalAlignment','center');
%UI to reset values to default
colour_reset_button = uicontrol('Style','pushbutton','Position',[22,3,5,2]*blocks,...
    'String','Reset Colours','Callback',@reset_colours);
reset_speed_button = uicontrol('Style','pushbutton','Position',[22,1,5,2]*blocks,...
    'String','Reset Speed','Callback',@reset_speed);
%Disable UI until user loads a map pack
disenable(0);
set(change_mappack_button,'Enable','On');
set(create_mappack_button,'Enable','On');
set(help_button,'Enable','On');
set(win,'Visible','on');
%% Callback functions
    %Function to display a map and its info
    function show_map(src,~)
        %Store the current map chagnes
        map{current_map} = selected_map;
        player_body{current_map} = selected_body;
        colours{current_map} = selected_colour;
        %Get the selected map info
        map_n = get(src,'Value');
        selected_map = map{map_n};
        selected_body = player_body{map_n};
        selected_colour = colours{map_n};
        current_map = map_n;
        %Display everything
        refresh_map();
        update_maplist();
        update_map_info();
    end
    %Function to start the dragging function in editting
    function drag_edit_enable(~,~)
        if (edit_enable==0)
            %Store the current callback of the figure
            props.WindowButtonMotionFcn = get(win,'WindowButtonMotionFcn');
            props.WindowButtonUpFcn = get(win,'WindowButtonUpFcn');
            setappdata(win,'TestGuiCallbacks',props);
            %Set the dragging edit callback and disable drag callback
            set(win,'WindowButtonMotionFcn',@edit_map);
            set(win,'WindowButtonUpFcn',@drag_edit_disable);
            %Set the editting variables
            prev_X = 0;prev_Y = 0;edit_enable=1;
            %Edit the current tile
            edit_map();
        end
    end
    %Function to stop the dragging function in editting
    function drag_edit_disable(~,~)
        if (edit_enable==1)
            %Reset the original callbacks of the figure
            props = getappdata(win,'TestGuiCallbacks');
            set(win,props);
            %Set the editting variables
            prev_X = 0;prev_Y = 0;edit_enable=0;
        end
    end
    %Function to edit the tile of a map
    function edit_map(~,~)
        %Check if the user is defining player position
        player_redf = get(redefine_player_toggle,'value');
        %Check which mouse button is pressed
        if(~player_redf)
            edit_type = 1;
            switch(get(win,'selectiontype'))
                case 'normal'
                    edit_type = 1;%Add tile
                case 'alt'
                    edit_type = 0;%Remove tile
                case 'extend'
                    edit_type = 0.1;%Add nospawn tile
            end
        end
        %Get the mouse position
        [X,Y] = display_mouse_pos();
        %Only edit a tile if the user move away from the current tile 
        %and stay within the map
        map_sz = size(selected_map);
        if (X>0 && X<=map_sz(2) && Y>0 && Y<=map_sz(1) && (X ~= prev_X || Y ~= prev_Y))
            %Map tile editing
            if(~player_redf)
                if ~(any((Y == selected_body(2,:)) & (X==selected_body(1,:))))
                    selected_map(Y,X,:) = edit_type;
                end
            else
                %Player position editing
                %Only add to player if it is continuous,
                %otherwise reset the player position
                if (selected_map(Y,X)~=1)
                    if (( abs(X- selected_body(1,1))+abs(Y- selected_body(2,1)) == 1)&&...
                        ~any(X==selected_body(1,:) & Y==selected_body(2,:)) )
                        selected_body = [[X;Y] selected_body];
                    else
                        selected_body = [X;Y];
                    end
                end
            end
        end
        %Store the previous mouse position
        prev_X = X;prev_Y = Y;
        refresh_map();
    end
    %Function to add a new map
    function new_map(~,~)
        %Create the new map+infos
        new_mat = zeros(30,30,3);
        new_body = [15 14 13; 15 15 15];
        new_colour = default_colours;
        %Append the new map+infos
        map = [map new_mat];
        num_of_map = length(map);
        map_name = [map_name sprintf('map_%d',num_of_map)];
        speed = [speed 12.5];
        player_body = [player_body new_body];
        colours = [colours new_colour];
        %Set to display the new map
        selected_map = new_mat;
        selected_body  = new_body;
        selected_colour = new_colour;
        current_map = num_of_map;
        set(map_listbox,'value',num_of_map);
        refresh_map();
        update_maplist();
        update_map_info();
    end
    %Function to delete a map
    function delete_map(~,~)
        %Only delete if there is more than one map
        if(num_of_map ~=1)
            map_num = get(map_listbox,'Value');
            map = [map(1:map_num-1) map(map_num+1:end)];
            map_name =  [map_name(1:map_num-1) map_name(map_num+1:end)];
            speed = [speed(1:map_num-1) speed(map_num+1:end)];
            player_body = [player_body(1:map_num-1) player_body(map_num+1:end)];
            colours = [colours(1:map_num-1) colours(map_num+1:end)];
            num_of_map = length(map);
            %Shift the map if the deleted map is not the first one
            if (map_num>num_of_map)
                map_num = map_num - 1;
            end
            set(map_listbox,'Value',map_num);
            selected_map = map{map_num};
            selected_body = player_body{map_num};
            selected_colour = colours{map_num};
            current_map = map_num;
            refresh_map();
            update_maplist();
            update_map_info();
        end
    end
    %Function to save all the changes
    function save_map(~,~)
        try
            file_name = get(mappack_name_edit,'String');
            map{current_map} = selected_map;
            player_body{current_map} = selected_body;
            colours{current_map} = selected_colour;
            save(file_name,'map','map_name','speed','player_body','colours');
            save(['backup_' file_name],'map','map_name','speed','player_body','colours');
        catch
            savebox = errordlg('Error occured while saving','modal');
            uiwait(savebox);
            return
        end
        savebox = msgbox('Save Complete','modal');
        uiwait(savebox);
    end
    %Function to move a map up or down
    function sort_map(~,~,dir)
        map_num = get(map_listbox,'Value');
        %Move down the map, if the map is not the last map
        if (dir==1)
            if (map_num ~= num_of_map)
                map = move_list(map,map_num,1);
                map_name = move_list(map_name,map_num,1);
                speed = move_list(speed,map_num,1);
                player_body = move_list(player_body,map_num,1);
                colours = move_list(colours,map_num,1);
                current_map = map_num+1;
                set(map_listbox,'Value',current_map);
            end
        %Move up the map, if it is not the first
        elseif (dir == -1)
            if (map_num ~= 1)
                map = move_list(map,map_num,-1);
                map_name = move_list(map_name,map_num,-1);
                speed = move_list(speed,map_num,-1);
                player_body = move_list(player_body,map_num,-1);
                colours = move_list(colours,map_num,-1);
                current_map = map_num-1;
                set(map_listbox,'Value',current_map);
            end
        end
        %Update everything
        refresh_map();
        update_maplist();
    end
    %Function to change the map name
    function edit_map_name(src,~)
        map_name{current_map} = get(src,'String');
        update_maplist();
    end
    %Function change the speed of the snake
    function change_speed(src,~)
        spd_val = get(src,'Value');
        spd_val = round(spd_val*10)/10;
        speed(current_map) = spd_val;
        update_map_info();
    end
    %Function change the size of the map
    function resize_map(~,~)
        %Get the new dimension
        new_width = str2double(get(map_width_edit,'String'));
        new_height = str2double(get(map_height_edit,'String'));
        map_sz = size(selected_map);
        %Do the width first
        %If it is enlarging, append the extra columns
        if (new_width>map_sz(2))
            selected_map = [selected_map zeros(map_sz(1),new_width-map_sz(2),3)];
        else
        %If it is shrinking, delete the extra columns
            selected_map = selected_map(:,1:new_width,:);
        end
        %Redo for height
        map_sz = size(selected_map);
        if (new_height>map_sz(1))
            selected_map = [selected_map; zeros(new_height-map_sz(1),map_sz(2),3)];
        else
            selected_map = selected_map(1:new_height,:,:);
        end
        map_sz = size(selected_map);
        selected_body = floor([map_sz(2);map_sz(1)]/2+1);
        refresh_map();
    end
    %Function to reset the changes
    function reset_changes(~,~)
        load_map_pack(['backup_' file_name])
        refresh_map();
        update_maplist();
        update_map_info();
    end
    %Function to open the manual
    function open_manual(~,~)
        snek_editor_help();
    end
    %Function to obtain and display the mouse position
    function [X,Y] = display_mouse_pos(~,~)
        map_sz = size(selected_map);
        mpos = get(map_axes,'CurrentPoint');
        X = round(mpos(1,1));
        Y = round(mpos(1,2));
        if (X>0 && X<=map_sz(2) && Y>0 && Y<=map_sz(1))
            set(mouse_xpos_text,'String',num2str(X));
            set(mouse_ypos_text,'String',num2str(Y));
        end
    end
    %Function to change the colour of the snake body
    function change_colour(~,~)
        new_colour(1) = get(colour_red_slider,'value');
        new_colour(2) = get(colour_green_slider,'value');
        new_colour(3) = get(colour_blue_slider,'value');
        selected_colour = round(new_colour*100)/100;
        refresh_map();
        update_map_info();
    end
    %Function to reset the colours
    function reset_colours(~,~)
        selected_colour = default_colours;
        refresh_map();
        update_map_info();
    end
    %Function to reset the speed
    function reset_speed(~,~)
        speed(current_map) = 12.5;
        refresh_map();
        update_map_info();
    end
%% Non Callback functions
    %Function to refresh the display
    function refresh_map()
        map_sz = size(selected_map);
        snake_pos = zeros(map_sz);
        if ~isempty(selected_body)
            snake_pos(selected_body(2,1),selected_body(1,1),1) = 1;
            for i = 2:length(selected_body(1,:))
                snake_pos(selected_body(2,i),selected_body(1,i),:) = selected_colour;
            end
        end
        image(selected_map+snake_pos,'Parent',map_axes,'PickableParts','none');
        set(map_axes,'PickableParts','all','ButtonDownFcn',@drag_edit_enable);
        set(map_axes,'Xcolor',[1 1 1],'xtick',(1:1:map_sz(2))+0.5,'XTickLabel',[]);
        set(map_axes,'Ycolor',[1 1 1],'ytick',(1:1:map_sz(1))+0.5,'YTickLabel',[]);
        newsize = [0 0 map_sz(2) map_sz(1)]/max(map_sz(1:2));
        newsize = newsize+[0.5-newsize(3:4)/2 0 0];
        set(map_axes,'Position',newsize);
        grid on;
    end
    %Function to update the map list
    function update_maplist()
        set(map_listbox,'String',map_name,'Value',current_map);
    end
    %Function to update the UI to display the map info
    function update_map_info()
        set(map_name_edit,'String',map_name{current_map});
        map_sz = size(map{current_map});
        set(map_width_edit,'String',map_sz(2));
        set(map_height_edit,'String',map_sz(1));
        set(speed_slider,'Value',speed(current_map));
        set(speed_value_text,'String',num2str(speed(current_map)));
        set(colour_red_slider,'value',selected_colour(1));
        set(red_value_text,'String',num2str(selected_colour(1)));
        set(colour_green_slider,'value',selected_colour(2));
        set(green_value_text,'String',num2str(selected_colour(2)));
        set(colour_blue_slider,'value',selected_colour(3));
        set(blue_value_text,'String',num2str(selected_colour(3)));
    end
    %Function to load a map pack
    function load_map_pack(fname)
        try
            mzmp = load(fname);
        catch
            loadbox = errordlg('File might not exist within the directory','modal');
            uiwait(loadbox);
            return
        end
        try
            map = mzmp.map;
            map_name = mzmp.map_name;
            speed = mzmp.speed;
            player_body = mzmp.player_body;
            colours = mzmp.colours;
            num_of_map = length(map);
            current_map = 1;
            selected_map = map{current_map};
            selected_body = player_body{current_map};
            selected_colour = colours{current_map};
            file_name = strrep(fname,'old_','');
            file_name = strrep(file_name,'backup_','');
            save(['backup_' file_name],'map','map_name','speed','player_body','colours');
            save(['old_' file_name],'map','map_name','speed','player_body','colours');
            set(mappack_name_edit,'String',file_name);
        catch
            loadbox = errordlg('File is corrupted','modal');
            uiwait(loadbox);
            return
        end
        disenable(1);
    end
    %Function to move a item in a list
    function[list] = move_list(list,val,increment)
        temp_list = list(val+increment);
        list(val+increment) = list(val);
        list(val) = temp_list;
    end
    %Function to enable/disable UIs
    function disenable(type)
        if (type == 0)
            disabling = findobj(win,'Parent',win,'-not','Type','uipanel');
            set(disabling,'Enable','Off');
        else
            enabling = findobj(win,'Parent',win,'-not','Type','uipanel');
            set(enabling,'Enable','On');
        end
    end
%% Functions involving dialog boxes
    function new_mappack(~,~)
        winpos = get(win,'Position');
        new_filename = 0;file_confirm = 0;
        newfile = dialog('Name','Create a Map Pack','Position',[winpos(1:2)+winpos(3:4)/4 winpos(3:4)/1.5]);
        matfiles = what;
        matfiles = matfiles.mat;
        uicontrol('Style','text','Units','normalized',...
            'Position',[0.05 0.9 0.4 0.05],'String','Available files')
        uicontrol('Style','listbox','Units','normalized',...
            'Position',[0.1 0.3 0.7 0.6],...
            'String',matfiles);
        uicontrol('Style','text','Units','normalized',...
            'Position',[0.05 0.15 0.3 0.1],...
            'String','File Name');
        new_filename_edit = uicontrol('Style','edit','Units','normalized',...
            'Position',[0.3 0.175 0.6 0.075]...
            );
        uicontrol('Style','pushbutton','Units','normalized',...
            'Position',[0.1 0.05 0.3 0.1],...
            'String','Okay','Callback',@confirm_file);
        uicontrol('Style','pushbutton','Units','normalized',...
            'Position',[0.6 0.05 0.3 0.1],...
            'String','Cancel','Callback',@cancel_file);
        function confirm_file(~,~)
            fname = get(new_filename_edit,'String');
            if(isempty(fname));
                return
            end
            new_filename = fname;
            file_confirm = 1;
            close(newfile);
        end
        function cancel_file(~,~)
            close(newfile);
        end
        uiwait(newfile);
        
        if(file_confirm)
            map = {};map_name = {};speed = [];player_body = {};colours = {};
            new_map();new_map();new_map();
            current_map =1;
            selected_map = map{current_map};
            selected_body = player_body{current_map};
            save(new_filename,'map','map_name','speed','player_body','colours');
            load_map_pack(new_filename);
            refresh_map();
            update_maplist();
            update_map_info();
        end
    end
    function change_mappack(~,~)
        winpos = get(win,'Position');
        change_filename = 0;change_confirm = 0;
        changefile = dialog('Name','Select a Map Pack','Position',[winpos(1:2)+winpos(3:4)/4 winpos(3:4)/1.5]);
        matfiles = what;
        matfiles = matfiles.mat;
        file_listbox = uicontrol('Style','listbox','Units','normalized',...
            'Position',[0.1 0.1 0.5 0.85],...
            'String',matfiles);
        uicontrol('Style','pushbutton','Units','normalized',...
            'Position',[0.7 0.7 0.2 0.2],...
            'String','Okay','Callback',@confirm_change);
        uicontrol('Style','pushbutton','Units','normalized',...
            'Position',[0.7 0.5 0.2 0.2],...
            'String','Cancel','Callback',@cancel_change);
        function confirm_change(~,~)
            fnum = get(file_listbox,'value');
            change_filename = matfiles{fnum};
            change_filename = strrep(change_filename,'.mat','');
            change_confirm = 1;
            close(changefile);
        end
        function cancel_change(~,~)
            close(changefile);
        end
        uiwait(changefile);
        
        if(change_confirm)
            load_map_pack(change_filename);
            refresh_map();
            update_maplist();
            update_map_info();
        end
    end
end