function img = cutRim(img, xy, r)
    [nx, ny] = size(img);
    [X, Y] = meshgrid(1:ny, 1:nx);
    px(1,1) = xy(1);
    px(2,1) = xy(1) + r(1);
    py(1,1) = xy(2);
    py(2,1) = xy(2);
    th = linspace(0, 2*pi);
    xc = px(1) + r * cos(th); 
    yc = py(1) + r * sin(th);
    idx = inpolygon(X, Y, xc', yc);
    img(~idx) = 255;
end