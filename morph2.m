[fname1,user_canceled1] = imgetfile;
[fname2,user_canceled2] = imgetfile;
a = imread(fname1);
b = imread(fname2);
a = imresize(a,[300 300]);
b = imresize(b,[300 300]);
[p1, p2] = cpselect(a,b,'Wait',true);
% p1 = facedetection(a);
% p2 = facedetection(b);
p1 = [p1;1 300;300 1;1 1;300 300];
p2 = [p2;1 300;300 1;1 1;300 300];
t1 = delaunayTriangulation(p1);
t2 = delaunayTriangulation(p2);
[x, y] = size(p1);
p3 = zeros(x,y);
imgs = cell(11,1);
imgs{1} = a;
for t = 0.1:0.1:0.9
    for i = 1:min(size(p1,1),size(p2,1))
        p3(i,1) = t*p2(i,1)+(1-t)*p1(i,1);    
        p3(i,2) = t*p2(i,2)+(1-t)*p1(i,2);
    end
    t3 = delaunayTriangulation(p3);
        strt1 = t3.ConnectivityList;
        for i = 1:size(strt1,1)
            strt1(i,:) = sort(strt1(i,:));
        end
        strt1 = sortrows(strt1);
        dt1 = triangulation(strt1,p1);   
        strt2 = t3.ConnectivityList;
        for i = 1:size(strt2,1)
            strt2(i,:) = sort(strt2(i,:));
        end
        strt2 = sortrows(strt2);
        dt2 = triangulation(strt2,p2);
        strt3 = t3.ConnectivityList;
        for i = 1:size(strt3,1)
            strt3(i,:) = sort(strt3(i,:));
        end
        strt3 = sortrows(strt3);
        dt3 = triangulation(strt3,p3);
    %
    imt = warp(a,dt1,dt3,strt3);
    imt2 = warp(b,dt2,dt3,strt3);
    imgs{fix(10*t+1)} = uint8(t*double(imt2) + (1-t)*double(imt));
end
imgs{11} = b;
for i = 1:11
    fname = sprintf('%d.jpg',i);
    imwrite(imgs{i},fname);
end
% writerObj = VideoWriter('morph2video.avi');
% writerObj.FrameRate = 5;
% open(writerObj);
% for u=1:length(imgs)
%     frame = im2frame(imgs{u});
%     writeVideo(writerObj, frame);
% end
% close(writerObj);
function [imt] = warp(im,dt,dt4,strt4)
    imt = zeros(size(im,1),size(im,2),3);
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
                    x = ceil(c(1));
                    y = ceil(c(2));
                    if x > size(im,1)
                        x = size(im,1);
                    end
                    if y > size(im,2)
                        y = size(im,2);
                    end
                    imt(k,j,1) = im(y,x,1);
                    imt(k,j,2) = im(y,x,2);
                    imt(k,j,3) = im(y,x,3);
                end
            end
        end
    end
    imt = uint8(imt);
end