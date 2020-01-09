clear
clc
warning('off', 'images:imfindcircles:warnForLargeRadiusRange');
img = imread("Rims/0.png");

[rXY, rR, chXY, chR, sQ, sXY, sR, scXY, vXY, vR, aRad, aDeg, centr] = calcParams(img);

img = cutRim(img, rXY, rR);
imshow(img)
hold on;

imshow(img)
plot([rXY(1), rXY(1)+rR(1)], [rXY(2), rXY(2)], 'g', 'LineWidth', 2); 
viscircles(rXY, rR, 'Color', 'b');
plot(rXY(1), rXY(2), 'r.', 'MarkerSize', 15);

imshow(img)
plot([chXY(1), chXY(1)+chR(1)], [chXY(2), chXY(2)], 'g', 'LineWidth', 2); 
viscircles(chXY, chR, 'Color', 'b');
plot(chXY(1), chXY(2), 'r.', 'MarkerSize', 15);

imshow(img)
for i=1:5
    plot([sXY(i,1), sXY(i,1)+sR(i)], [sXY(i,2), sXY(i,2)], 'g', 'LineWidth', 2);
end
viscircles(sXY, sR, 'Color', 'b');
for i=1:5
    plot(sXY(i,1), sXY(i,2), 'r.', 'MarkerSize', 10);
end

imshow(img)
plot([vXY(1), vXY(1)+vR(1)], [vXY(2), vXY(2)], 'g', 'LineWidth', 2);
viscircles(vXY, vR, 'Color', 'b');
plot(vXY(1), vXY(2), 'm.', 'MarkerSize', 10);

hXY = sXY;
hXY(6,:) = vXY;
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

imshow(img)
pkt = [chXY(1) + 100, chXY(2)];
oSs = sqrt((chXY(1) - s(ind,1)) ^ 2 + (chXY(2) - s(ind,2)) ^ 2);
oSp = sqrt((chXY(1) - pkt(1)) ^ 2 + (chXY(2) - pkt(2)) ^ 2);
osp = sqrt((s(ind,1) - pkt(1)) ^ 2 + (s(ind,2) - pkt(2)) ^ 2);
oSw = sqrt((chXY(1) - vXY(1)) ^ 2 + (chXY(2) - vXY(2)) ^ 2);
owp = sqrt((vXY(1) - pkt(1)) ^ 2 + (vXY(2) - pkt(2)) ^ 2);
sRad = acos((oSs ^ 2 + oSp ^ 2 - osp ^ 2) / (2 * oSs * oSp));
vRad = acos((oSw ^ 2 + oSp ^ 2 - owp ^ 2) / (2 * oSw * oSp));

r = 55;
th = -vRad:pi/180:sRad;
x = r * cos(th) + chXY(1);
y = r * sin(th) + chXY(2);
plot(x,y,'r','LineWidth', 2)
plot([chXY(1), s(ind,1)],[chXY(2), s(ind,2)],'b','LineWidth', 2);
plot([chXY(1), vXY(1)],[chXY(2), vXY(2)],'g','LineWidth', 2);

imshow(img)
o=[];
cXY = [mean(sXY(:,1)), mean(sXY(:,2))];
for i=1:5
    o(i) = sqrt((cXY(1) - sXY(i,1)) ^ 2 + (cXY(2) - sXY(i,2)) ^ 2);
end
 viscircles(cXY,mean(o),'Color','b');
for i=1:5
    plot([sXY(i,1), cXY(1)],[sXY(i,2), cXY(2)],'r','LineWidth', 2)
end
plot(chXY(1), chXY(2), 'g.', 'MarkerSize', 15);