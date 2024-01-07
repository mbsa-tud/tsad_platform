function jsonStruct = readJSONToStruct(fileName)
%READJSONTOSTRUCT Load JSON file and return matlab struct with same
%contents

try
    fid = fopen(fileName);
    raw = fread(fid, inf);
    str = char(raw');
    fclose(fid);
    jsonStruct = jsondecode(str);
catch ME
    error("Unable to open %s file.\n%s", fileName, ME.message);
end
end

