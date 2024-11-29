function JSONData = loadJsonFromFile(pathOrFileName)
%LOADJSONFROMFILE Loads json from file-name or path-name

fid = fopen(pathOrFileName);
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
JSONData = jsondecode(str);
end