function [rXY, rR, chXY, chR, sQ, sXY, sR, scXY, vXY, vR, aRad, aDeg, centr] = calcParams(img, rimImfindcirclesBounds, centralHoleImfindcirclesBounds, outerHolesImfindcirclesBounds, innerHolesImfindcirclesBounds, rR, cutRimSize)
% output:
    % rXY - rim midpoint coordinates
    % rR - rim radius
    % chXY - central hole midpoint coordinates
    % chR - central hole radius
    % sQ - screws quantity
    % sXY - screws midpoints coordinates
    % sR - screws radiuses
    % scXY - calculated central hole midpoint coordinates (scXY mean)
    % vXY - ventil midpoint coordinates
    % vR - ventil radius
    % aRad - ventil to next screw radians
    % aDeg - ventil to next screw degrees
    % centr - difference between chXY and scXY
% input:
    % img - image
    % rimImfindcirclesBounds - bounds for rim imfindcircles
    % centralHoleImfindcirclesBounds - bounds for central hole imfindcircles
    % outerHolesImfindcirclesBounds - bounds for inner holes imfindcircles
    % innerHolesImfindcirclesBounds - bounds for outer holes imfindcircles
    % rR - nullable rim radius
    if exist('rR','var')
        [rXY, rR] = imfindcircles(img, [rR-5, rR+5], 'ObjectPolarity', 'bright', 'Sensitivity', 0.96, 'Method', 'twostage');
    else
        [rXY, rR] = imfindcircles(img, rimImfindcirclesBounds, 'ObjectPolarity', 'bright', 'Sensitivity', 0.96, 'Method', 'twostage');
    end
    
    img = cutRim(img, rXY, rR, cutRimSize);
    
    [chXY, chR] = imfindcircles(img, centralHoleImfindcirclesBounds, 'ObjectPolarity', 'dark', 'Sensitivity', 0.9);
    [ohXY, ohR] = imfindcircles(img, outerHolesImfindcirclesBounds, 'ObjectPolarity', 'bright', 'Sensitivity', 0.896);
    [ihXY, ihR] = imfindcircles(img, innerHolesImfindcirclesBounds, 'ObjectPolarity', 'dark', 'Sensitivity', 0.87, 'Method', 'twostage');
    
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