function img = cutRim(img, xy, r, nSize)
% output:
    % img - cutted image
% input:
    % img - image to cut
    % xy - midpoint coordinates
    % r - radius
    
%     [nx, ny] = size(img);
%     [X, Y] = meshgrid(1:ny, 1:nx);
%     px(1,1) = xy(1);
%     px(2,1) = xy(1) + r(1);
%     py(1,1) = xy(2);
%     py(2,1) = xy(2);
%     th = linspace(0, 2*pi);
%     xc = px(1) + r * cos(th); 
%     yc = py(1) + r * sin(th);
%     idx = inpolygon(X, Y, xc', yc);
%     img(~idx) = 255;

%     if xy(1) < xy(2)
%         pxy(1) = r + mar;
%         pxy(2) = r + mar + (xy(2) - xy(1));
%     else
%         if xy(2) < xy(1)
%             pxy(1) = r + mar + (xy(1) - xy(2));
%             pxy(2) = r + mar;
%         else
%             pxy(1:2) = r + mar;
%         end
%     end

    nxy(1:2) = ceil(nSize / 2);
    
    img = imtranslate(img, nxy - xy);
    img = imcrop(img, [0, 0, nSize, nSize]);
    
    [X, Y] = meshgrid(1 : nSize, 1 : nSize);
    th = linspace(0, 2 * pi);
    xc = nxy(1) + r * cos(th);
    yc = nxy(2) + r * sin(th);
    idx = inpolygon(X, Y, xc', yc);
    img(~idx) = 255;
end