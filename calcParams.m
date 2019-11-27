function [rXY, rR, chXY, chR, sQ, sXY, sR, scXY, vXY, vR, aRad, aDeg, centr] = calcParams(img,rR)
    if exist('rR','var')
        [rXY, rR] = imfindcircles(img, [rR-5, rR+5], 'ObjectPolarity', 'bright', 'Sensitivity', 0.96, 'Method', 'twostage');
    else
        [rXY, rR] = imfindcircles(img, [250, 450], 'ObjectPolarity', 'bright', 'Sensitivity', 0.96, 'Method', 'twostage');
    end
    
    img = cutRim(img, rXY, rR);
    
    [chXY, chR] = imfindcircles(img, [30, 45], 'ObjectPolarity', 'dark', 'Sensitivity', 0.9);
    [ohXY, ohR] = imfindcircles(img, [10, 22], 'ObjectPolarity', 'bright', 'Sensitivity', 0.895);
    [ihXY, ihR] = imfindcircles(img, [6, 13], 'ObjectPolarity', 'dark', 'Sensitivity', 0.87, 'Method', 'twostage');
    
    hR = [];
    ind = 1;
    for i = 1 : length(ohXY)
        flg = false;
        for j = 1 : length(ihXY)
            if ((ihXY(j,1) - ohXY(i,1)) ^ 2 + (ihXY(j,2) - ohXY(i,2)) ^2 <= ohR(i) ^ 2)
                if length(hR) < ind
                    hXY(ind,:) = ihXY(j,:);
                    hR(ind,1) = ihR(j);
                    flg = true;
                else
                    od = mean(abs(ohXY(i,:) - hXY(i,:)));
                    nd = mean(abs(ohXY(i,:) - ihXY(j,:)));
                    if nd < od
                        hXY(ind,:) = ihXY(j,:);
                        hR(ind,1) = ihR(j);
                    end
                end
            end
        end
        if flg
            ind = ind + 1;
        end
    end
    
    [~, ind] = min(hR);
    sXY = hXY;
    sR = hR;
    sXY(ind,:) = [];
    sR(ind,:) = [];
    vXY(1,:) = hXY(ind,:);
    vR(1,1) = hR(ind);
    
    sr = mean(hXY);
    o = atan2(hXY(:,2) - sr(2), hXY(:,1) - sr(1));
    [~, order] = sort(o);
    s = hXY(order,:);
    ind = find(s(:,1) == vXY(1) & s(:,2) == vXY(2));
    if ind < length(s)
        ind = ind + 1;
    else
        ind = 1;
    end

    oSs = sqrt((chXY(1) - s(ind,1)) ^ 2 + (chXY(2) - s(ind,2)) ^ 2);
    oSw = sqrt((chXY(1) - vXY(1)) ^ 2 + (chXY(2) - vXY(2)) ^ 2);
    osw = sqrt((s(ind,1) - vXY(1)) ^ 2 + (s(ind,2) - vXY(2)) ^ 2);

    aRad = acos((oSs ^ 2 + oSw ^ 2 - osw ^ 2) / (2 * oSs * oSw));
    aDeg = aRad * 180 / pi;
    
    sQ = length(sR);
    
    scXY = [mean(sXY(:,1)), mean(sXY(:,2))];
    centr = mean(abs(chXY - scXY));
end