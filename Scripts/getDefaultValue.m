function value = getDefaultValue(key)
% GETDEFAULTVALUE  Returns default values.
%   value = GETDEFAULTVALUE(key) - returns the default value for the passed key.
    
    switch key
        case 'hogCellSize'
            value = [55 55];
        case 'hogNumBins'
            value = 25;
            
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
            
        case 'smallOuterHolesRadiusBounds'
            value = [10, 22];
        case 'smallOuterHolesObjectPolarity'
            value = 'bright';
        case 'smallOuterHolesSensitivity'
            value = 0.91;
        case 'smallOuterHolesMethod'
            value = 'phasecode';
            
        case 'smallInnerHolesRadiusBounds'
            value = [6, 13];
        case 'smallInnerHolesObjectPolarity'
            value = 'dark';
        case 'smallInnerHolesSensitivity'
            value = 0.87;
        case 'smallInnerHolesMethod'
            value = 'twostage';
    end
end