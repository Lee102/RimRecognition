function value = getDefaultValue(key)
% GETDEFAULTVALUE  Returns default values.
%   value = GETDEFAULTVALUE(key) - returns the default value for the passed key.
    
    switch key
        case 'rimRadiusBounds'
            value = [250, 450];
        case 'rimObjectPolarity'
            value = 'bright';
        case 'rimSensitivity'
            value = 0.96;
        case 'rimMethod'
            value = 'twostage';
            
        case 'centralHoleRadiusBounds'
            value = [30, 45];
        case 'centralHoleObjectPolarity'
            value = 'dark';
        case 'centralHoleSensitivity'
            value = 0.9;
        case 'centralHoleMethod'
            value = 'phasecode';
            
        case 'smallHolesObjectPolarity'
            value = 'dark';
        case 'smallHolesSensitivity'
            value = 0.87;
        case 'smallHolesMethod'
            value = 'twostage';
            
        case 'screwHolesRadiusBounds'
            value = [8 17];
        case 'screwHolesScoreMaxDiff'
            value = 0.2;
        case 'screwRadiusMaxDiff'
            value = 1;
        case 'screwAngleMaxDiff'
            value = 5;
            
        case 'ventilHoleRadiusBounds'
            value = [4 10];
            
        case 'hogCellSize'
            value = [16 16];
        case 'hogNumBins'
            value = 25;
    end
end