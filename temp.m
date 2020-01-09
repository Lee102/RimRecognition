clear
clc

disp("Calculating classifier")
classifier = recTrainer("Rims/RimsRec/Raw");

for i = 0 : 1
    disp("noTranslations: " + i)
    disp("===============================================================")
    for j = 0 : 9
        path = "Rims/" + j + ".png";
        disp("path: " + path)
        result(i+1, j+1).noTranslations = i;
        result(i+1, j+1).rim = j;
        try
            [data, stat, recognized] = translateAndCalculate(classifier, path, i, 2);
            result(i+1, j+1).data = data;
            result(i+1, j+1).stat = stat;
            result(i+1, j+1).recognized = recognized;
            result(i+1, j+1).err = "";
        catch x
            result(i+1, j+1).err = x;
        end
        disp("-----------------------------------------------------------")
    end
    disp("===============================================================")
end
