%% Information
%   Original author: En Yi
%   A snake game on MATLAB, very self-explanatory
%   Have fun!
%   Anyone can modify it, just need to give credits to the original author
function snek_final()
%% Creating the game window
clc;clear;
%Default Constants
default_updatetime = 0.08;
default_ftsize = 10;
%Create the update timer, used for continuously updating the game screen
update_t = timer('ExecutionMode','fixedSpacing','Period',default_updatetime,'TimerFcn',@update_screen);
%Create the window
scrsz = get(0,'ScreenSize');
start_dim = min(scrsz(3)/1.5,scrsz(4)/1.5);%Used for rescaling
win = figure('KeyPressFcn',@key_check,'DeleteFcn',@delete_t,'ToolBar',...
    'none','Name','SNEK','NumberTitle','off','MenuBar','none',...
    'Resize','off','Visible','off','Color',[170 255 211]/255,...
    'Position',[[scrsz(3),scrsz(4)]/4.5 start_dim start_dim]);
%For displaying instructions and score
load_map_button = uicontrol('Style','pushbutton','Units','Normalized',...
                'Position',[0.01 0.01 0.2 0.08],'FontSize',default_ftsize,...
                'Callback',@select_mappack,'String','Change Pack');
console_text = uicontrol('Style','text','Units','Normalized',...
                'Position',[0.25 0.01 0.7 0.08],'FontSize',default_ftsize);
%Just to display the version and author
uicontrol('Style','text','Units','Normalized','Position',[24,28,6,2]/30,...
            'String','V1.0 Made by En Yi','BackgroundColor',[170 255 211]/255);
%Create the axes for drawing the game        
disp_axes = axes('Parent',win);
%graze = 0;

%% Load the map levels and define game variables
%Prepare the map
width = 30;height = 30;
map_number = 0;n_of_maps = 0;
maze_map = {};map_name = {};speed = [];map = zeros(width,height,3);
start_body={};player_body = [];player_len = 1;move_dir = 2;
body_colour = {};selected_colour = [];fruit_colour = [0.5 0.5 0];
load_map_pack('mazemap')
%Define the fruit fruit_values+bonus and player score
fruit_value = 0;
score = 0;
max_value = 60;
fruit_x = -1;fruit_y = -1;
%Create the sounds for collecting a fruit and losing the game
Fs = 10000;
t = 0:1/Fs:.02;
y = sin(2*pi*4000*t);
beep = audioplayer(y, Fs);
t = 0:1/Fs:0.1;
x = sawtooth(2*pi*60*t);
x = [x zeros(1,5) x];
gover = audioplayer(x, Fs);
%Define the variable to check whether the player is playing the game
game_on = 0;
%Update the screen and display controls
update_screen();
set(win,'Visible','on')
set(console_text,'String',{'WASD or Arrows key to select map','Space to start'});
%% Callback functions
    %Function to update the game screen
    function update_screen(~,~)
        scr_mat = map;  %Put in the current map
        if(game_on ==1)             %If the player is playing
            isdead = move(scr_mat); %Move the player and check whether the player is dead
            if(isdead)              %If so
                stop(update_t);     %Stop continuously updating the screen
                set(console_text,'String',{'Game Over. Press R to restart.',...
                    sprintf('Final Score : %d\n',floor(score/10))} );
                play(gover);
                return              %Stop the game
            end
        end
        %Put in the player body after updating
        body_sz = size(player_body);
        scr_mat(player_body(2,1),player_body(1,1),1) = 1;
        for n=2:body_sz(2)
            scr_mat(player_body(2,n),player_body(1,n),:) = selected_colour;
        end
        %Spawn the fruit if it is collected
        if(fruit_x == -1)
            scr_mat = spawn_fruit(scr_mat);
            fruit_value = max_value;      %Set the fruit fruit_values
        end
        %Put in the fruit
        scr_mat(fruit_y,fruit_x,:) = fruit_colour;
        %Set focus on the game window
        figure(win);
        %Draw the game screen
        image(scr_mat,'Parent',disp_axes);
        set(disp_axes,'XTickLabel',[],'YTickLabel',[]);
        if (map_number>0)
            title(map_name{map_number});
        else
            title('Open');
        end
        
        if(game_on ==0)         %If the player is not playing
            %Readjust the window screen to fit the aspect ratio of the level
            current_winpos = get(win,'Position');
            topright = current_winpos(2)+current_winpos(4);
            new_winpos = [0 0 width height]/max([0 0 width height])...
                *start_dim;
            new_winpos = new_winpos+[current_winpos(1) topright-new_winpos(4) 0 0];
            set(win,'Position',new_winpos);
        end
    end
    %Function to check the key presses
    function key_check(~,evtdata)
        %disp(evtdata.Key);
        if(game_on == 1)
        %When the game is running
        %Direction keys change the direction of the snake
        %The inputs are recorded up to 3 key presses for updating
            n = length(move_dir)+1;
            if (n<4)
                if (move_dir(end)~=2 && move_dir(end)~=1)
                    switch(evtdata.Key)
                        case 'leftarrow'
                            move_dir(n) = 1;
                        case 'rightarrow'
                            move_dir(n) = 2;
                        case 'a'
                            move_dir(n) = 1;
                        case 'd'
                            move_dir(n) = 2;
                    end
                elseif (move_dir(end)~=3 && move_dir(end)~=4)
                    switch(evtdata.Key)
                        case 'uparrow'
                            move_dir(n) = 3;
                        case 'downarrow'
                            move_dir(n) = 4;
                        case 'w'
                            move_dir(n) = 3;
                        case 's'
                            move_dir(n) = 4;
                    end
                end
            end
            %Press R to try again. restarting the screen
            if(strcmp(evtdata.Key,'r'))
                restart();
            end
        else
        %When the game is not running
        %Direction keys change the map
            if(strcmp(evtdata.Key,'leftarrow') ||strcmp(evtdata.Key,'rightarrow')||...
                    strcmp(evtdata.Key,'a') ||strcmp(evtdata.Key,'d'))
                switch(evtdata.Key)
                    case 'leftarrow'
                        map_number = map_number -1;
                    case 'rightarrow'
                        map_number = map_number +1;
                    case 'a'
                        map_number = map_number -1;
                    case 'd'
                        map_number = map_number +1;
                end
                if map_number>n_of_maps
                    map_number = 0;
                elseif map_number<0
                    map_number = n_of_maps;
                end
                restart();
            end
        end
        %Space to start the game
        if(strcmp(evtdata.Key,'space'))
            if(game_on == 0)
                set(load_map_button,'Enable','off');
                drawnow;
                start(update_t);
                game_on =1;
                set(console_text,'String',{sprintf('Score : %d\n',floor(score/10));} );
            end
        end
    end
%% Non Callback functions
    %Function to update the player coordinates and check is it dead
    function[isdead] = move(scr_mat)
        isdead = 0;
        player_newx = player_body(1,1);player_newy = player_body(2,1);
        %Check the next key press if there is one, otherwise last key press
        if(length(move_dir)>1)
            move_dir = move_dir(2:end);
        end
        switch(move_dir(1))
            case 1
                player_newx = player_newx - 1;
            case 2
                player_newx = player_newx + 1;
            case 3
                player_newy = player_newy - 1;
            case 4
                player_newy = player_newy + 1;
        end
        %Wrap the player around the edge of the map
        if player_newx>width
            player_newx = 1;
        end
        if player_newx<1
            player_newx = width;
        end
        if player_newy>height
            player_newy = 1;
        end
        if player_newy<1
            player_newy = height;
        end
        %Check if the head of the player intersect with the body
        xcheck = (player_body(1,2:end)==player_newx);
        ycheck = (player_body(2,2:end)==player_newy);
        if(sum(scr_mat(player_newy,player_newx,:))>2.9 ||any(xcheck & ycheck))
%             if(graze <1)
%                 graze = graze+1;
%             else
                isdead = 1;
                return
            %end
        else
            %graze = 0;
            if (player_len >1)
                player_body = [[player_newx;player_newy] player_body(:,1:end-1)];
            else
                player_body = [player_newx;player_newy];
            end
        end
        %Check if the player head intersect with the fruit
        if(player_body(1,1) == fruit_x && player_body(2,1) == fruit_y)
            fruit_x = -1;
            play(beep);
            player_len = player_len+1;
            player_body = [player_body player_body(:,end)];
            score = score + fruit_value;
            set(console_text,'String',{sprintf('Score : %d',floor(score/10)),...
                sprintf('+%.1f',fruit_value/10)} );
        else
        %Decrease the fruit value if it is not collected
            if fruit_value>10
                fruit_value = fruit_value -1;
            else
                fruit_value = 10;
            end
        end
    end
    %Function to spawn the fruit
    function [scr_mat] = spawn_fruit(scr_mat)
        comp_mat = sum(scr_mat,3);
        [empty_y,empty_x] = find(comp_mat==0);
        fruit_pos = floor(rand(1)*length(empty_x))+1;
        fruit_x = empty_x(fruit_pos);fruit_y = empty_y(fruit_pos);
    end
    %Function to restart the game
    function restart()
        stop(update_t);                     %Stop continuously updating the game
        game_on = 0;                        %Indicate the game is not running
        map_load(map_number);               %Load the selected map
        fruit_x = -1;                       %Remove the fruit
        fruit_value = 1;                    %Reset the fruit value
        score = 0;                          %Reset the score                     
        update_screen();                    %Update the screen 
        set(console_text,'String',{'WASD or Arrows key to select map','Space to start'});
        set(load_map_button,'Enable','on');
    end
    %Function to load the selected map
    function map_load(num)
        if(num>0)
            map = maze_map{num};
            map_sz = size(maze_map{num});
            map_sz_norm = map_sz/max(map_sz);
            width = map_sz(2);
            height = map_sz(1);
            set(update_t,'Period',round(1000/speed(num))/1000);
            max_value = ceil(60*map_sz(2)*map_sz(1)/900*speed(num)/12.5);
            set(console_text,'FontSize',round(default_ftsize*map_sz_norm(2)*map_sz_norm(1)));
            player_body = start_body{num};
            selected_colour = body_colour{num};
            player_len = length(player_body(1,:));
            if (player_len>1)
                if(player_body(1,1)==player_body(1,2))
                    if(player_body(2,1)>player_body(2,2))
                        move_dir = 4;
                    else
                        move_dir = 3;
                    end
                else
                    if(player_body(1,1)>player_body(1,2))
                        move_dir = 2;
                    else
                        move_dir = 1;
                    end
                end
            else
                move_dir = 2;
            end
        else
            width = 30;
            height = 30;
            map = zeros(height,width,3);
            set(update_t,'Period',default_updatetime);
            max_value = 60;
            set(console_text,'FontSize',default_ftsize);
            player_body = zeros(2,3);  %Reset the player body
            selected_colour = [0.7 0.2 0.5];
            player_headx = round(30/2);
            player_heady = round(30/2);
            player_len = 3;
            for n=1:player_len
                player_body(1,n) = player_headx-n+1;
                player_body(2,n) = player_heady;
            end
            move_dir = 2;
        end
    end
    function load_map_pack(fname)
        try
            mzmp = load(fname);
            maze_map = mzmp.map;            
            n_of_maps = length(maze_map);
            map_name = mzmp.map_name;
            speed = mzmp.speed;
            start_body = mzmp.player_body;
            body_colour = mzmp.colours;
            map_number = 0;
            map_load(map_number);
        catch
            errorbox = errordlg('mazemap.mat might not exist or not compatible within the directory. No levels loaded','modal');
            uiwait(errorbox);
            maze_map = {};
            n_of_maps = 0;
            map_number = 0;
%             player_body = zeros(2,3);  %Reset the player body
%             player_headx = round(30/2);
%             player_heady = round(30/2);
%             player_len = 3;
%             for n=1:player_len
%                 player_body(1,n) = player_headx-n+1;
%                 player_body(2,n) = player_heady;
%             end
            mapload(0);
        end
    end
    %Function to delete the timer when the game is closed
    function delete_t(~,~)
        stop(update_t);
        delete(update_t);
    end
    function select_mappack(~,~)
        winpos = get(win,'Position');
        change_pack = 0;change_confirm = 0;
        changepack = dialog('Name','Select a Map Pack','Position',[winpos(1:2)+winpos(3:4)/4 winpos(3:4)/1.5]);
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
            change_pack = matfiles{fnum};
            change_pack = strrep(change_pack,'.mat','');
            change_confirm = 1;
            close(changepack);
        end
        function cancel_change(~,~)
            close(changepack);
        end
        uiwait(changepack);
        
        if(change_confirm)
            load_map_pack(change_pack);
            restart();
            confirm = msgbox('Load Complete','modal');
            uiwait(confirm);
        end
        set(load_map_button,'Enable','off')
        drawnow;
        set(load_map_button,'Enable','on')
    end
end