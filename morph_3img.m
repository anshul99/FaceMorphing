line([0,1], [0,sqrt(3)]);
hold on;
line([1,2], [sqrt(3),0]);
line([2,0], [0,0]);
text(0,0,'Img 1');
text(1,sqrt(3),'Img 2');
text(2,0,'Img 3');
[x1, y1] = getpts;
hold off;
[fname1,user_canceled1] = imgetfile;
[fname2,user_canceled2] = imgetfile;
[fname3,user_canceled3] = imgetfile;
a = imread(fname1);
b = imread(fname2);
c = imread(fname3);
a = imresize(a,[512 512]);
b = imresize(b,[512 512]);
c = imresize(c,[512 512]);
tr = triangulation([1 2 3],[0;1;2],[0;sqrt(3);0]);
imshow([a b c]);
[x, y] = getpts;
p1 = [x(1:3:end) y(1:3:end)];
p2 = [x(2:3:end) y(2:3:end)];
p3 = [x(3:3:end) y(3:3:end)];
p2(:,1) = p2(:,1) - 512;
p3(:,1) = p3(:,1) - 1024;
p1 = [p1;1 1;1 512;512 1;512 512];
p2 = [p2;1 1;1 512;512 1;512 512];
p3 = [p3;1 1;1 512;512 1;512 512];
t1 = delaunayTriangulation(p1);
t2 = delaunayTriangulation(p2);
t3 = delaunayTriangulation(p3);
imgs = cell(size(x1,1),1);
for j = 1:size(x1,1)
    f = cartesianToBarycentric(tr,1,[x1(j) y1(j)]);
    p4 = f(1)*p1 + f(2)*p2 + f(3)*p3;
    t4 = delaunayTriangulation(p4);
    tri = {t1 t2 t3 t4};
    dt = cell(4,1);
    strt = cell(4,1);
    for i = 1:4
        strt{i} = sort_tri(t4);
        dt{i} = triangulation(strt{i},tri{i}.Points);
    end
    img = uint8((f(1)*warp(a,dt{1},dt{4},strt{4}) + f(2)*warp(b,dt{2},dt{4},strt{4}) + f(3)*warp(c,dt{3},dt{4},strt{4})));
    imgs{j} = img;
end
for i = 1:j
    fname = sprintf('%d.jpg',i);
    imwrite(imgs{i},fname);
end
function [strt] = sort_tri(t4)
    strt = t4.ConnectivityList;
    for i = 1:size(strt,1)
    strt(i,:) = sort(strt(i,:));
    end
    strt = sortrows(strt);
end
function [imt] = warp(im,dt,dt4,strt4)
    imt = zeros(512,512,3);
    [m, ~] = size(dt4);
    for i = 1:m
        xmin = fix(min(dt4.Points(strt4(i,1),1),min(dt4.Points(strt4(i,2),1),dt4.Points(strt4(i,3),1))));
        ymin = fix(min(dt4.Points(strt4(i,1),2),min(dt4.Points(strt4(i,2),2),dt4.Points(strt4(i,3),2))));
        xmax = ceil(max(dt4.Points(strt4(i,1),1),max(dt4.Points(strt4(i,2),1),dt4.Points(strt4(i,3),1))));
        ymax = ceil(max(dt4.Points(strt4(i,1),2),max(dt4.Points(strt4(i,2),2),dt4.Points(strt4(i,3),2))));
        for j = xmin:xmax
            for k = ymin:ymax
                f = cartesianToBarycentric(dt4,i,[j k]);
                if f(1) >= 0 && f(2) >= 0 && f(3) >= 0
                    c = barycentricToCartesian(dt,i,f);
                    x = round(c(1));
                    y = round(c(2));
                    imt(k,j,1) = im(y,x,1);
                    imt(k,j,2) = im(y,x,2);
                    imt(k,j,3) = im(y,x,3);
                end
            end
        end
    end
end