clear
clc
ind = 1;

for i = 4 : 4
    disp("noTranslations: " + i)
    disp("===============================================================")
    for j = 0 : 9
        path = "Rims/" + j + ".png";
        disp("path: " + path)
        result(ind).noTranslations = i;
        result(ind).rim = j;
        try
            [data, stat] = translateAndCalculate(path,i,2);
            result(ind).data = data;
            result(ind).stat = stat;
            result(ind).err = "";
        catch x
            result(ind).err = x;
        end
        ind = ind + 1;
        disp("-----------------------------------------------------------")
    end
    disp("===============================================================")
end