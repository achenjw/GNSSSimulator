%% Trajectory File Creator - 
% Inputs:
%           ReadKML             : Parse trajectory data from .kml file
%
%           Coordinate System   : ECEF/LLH
%           Start Time          : Start time of data
%           End time            : End time of data
%           Epoch interval      : ...
%           Delta-Coordinate    : For Debug only (don't use).
%
%           

%% Config
clearvars;
output_path = 'C:\Local WorkSpace\Cpp\GnssSimulator\Simulator\TrajectoryTestFiles\';
output_name = 'TrajectoryFileExample_Generated_Fullday.txt';

% ReadKML: 1 = TRUE; 0 = FALSE;
ReadKML = 1;
KMLname = 'KML_Melbourne_Test1.kml.xml';

% Coordinate System: 1 = LLH ; 0 = ECEF
coorSys = 1;

% Start time
%   GPS WEEK
start_gpswk = 1966;
%   GPS SOW
start_gpssow = 4300;         %600
% End Time
%   GPS WEEK
end_gpswk = 1966;
%   GPS SOW
end_gpssow = 10000;         % 86310

% Epoch interval [s]
epoch_delta = 6;

% Delta-Coordinate , 
if coorSys == 1
    latitude = -37.868768;
    delta_lat = 0;
    longitude = 145.124401;
    delta_long = 0;
    height = 0;
    delta_height = 0;
elseif coorSys == 0
    x = 0;
    y = 0;
    z = 0;
end

%% Main

% Parse KML if set
if ReadKML
    coordinatesreached = 0;                 % If parsing has reached <coordinates> tag
    
    FID_KML = fopen([output_path KMLname],'r');
    while ~feof(FID_KML)
        tline = fgets(FID_KML);
        if strcmp('<coordinates>',strtrim(tline)) && coordinatesreached == 0
            coordinatesreached = 1;
            iterator = 1;
            continue
        end
        if coordinatesreached
            if strcmp('</coordinates>',strtrim(tline))
                break
            end
            [lat temp long temp height] = strread(tline,'%f%c%f%c%f');
            data(iterator,1:3) = [long lat height];
            iterator = iterator+1;
        end
    end
end

FID = fopen([output_path output_name],'w');
% Write Header
if coorSys == 1
    header_pos = 'Position LLH';
else
    header_pos = 'Position ECEF';
end
header = sprintf('GNSS Trajectory File\n%s\nEND OF HEADER\n',header_pos);
fprintf(FID,'%s',header);

% Write Data
%lines = (end_gpssow - start_gpssow)/epoch_delta; % For 1 GPSWeek currently
lines = size(data);
lines = lines(1,1);
sow = start_gpssow;
for i = 1:lines
    gpswk = start_gpswk;
    epoch_data = sprintf('%u  %5u    ',gpswk,sow);
    %coor_data = sprintf('%10.7f   %10.7f   %10.7f',latitude,longitude,height);
    coor_data = sprintf('%10.7f   %10.7f   %10.7f',data(i,1),data(i,2),data(i,3));
    
    sow = sow+epoch_delta;
    latitude = latitude + delta_lat;
    longitude = longitude + delta_long;
    height = height + delta_height;
    
    if latitude > 90
        latitude = -90;
    end
    if longitude > 180
        longitude = -180;
    end
    
    fprintf(FID,[epoch_data coor_data '\n']);
end

fclose(FID);