[fname1,user_canceled1] = imgetfile;
[fname2,user_canceled2] = imgetfile;
a = imread(fname1);
b = imread(fname2);
a = imresize(a,[512 512]);
b = imresize(b,[512 512]);
[p1, p2] = cpselect(a,b,'Wait',true);
p1 = [p1;1 512;512 1;1 1;512 512];
p2 = [p2;1 512;512 1;1 1;512 512];
t1 = delaunayTriangulation(p1);
t2 = delaunayTriangulation(p2);
[x, y] = size(p1);
p3 = zeros(x,y);
imgs = cell(11,1);
imgsplot=cell(11,1);
imgs{1} = a;
figure('Visible','off');
imshow(a);
hold on;
triplot(t1);
f=getframe(gcf);
fg=frame2im(f);
hold off;
fg(1:32,:,:) = [];
fg(512:593,:,:) = [];
fg(:,1:91,:) = [];
fg(:,513:605,:) = [];
imgsplot{1}=fg;
for t = 0.1:0.1:0.9
    for i = 1:size(p1,1)
        p3(i,1) = t*p2(i,1)+(1-t)*p1(i,1);    
        p3(i,2) = t*p2(i,2)+(1-t)*p1(i,2);
    end
    t3 = delaunayTriangulation(p3);
    sort_tri;
    warp;
    warp2;
    figure('Visible','off')
    fig= uint8(t*double(imt2) + (1-t)*double(imt));
    imshow(fig);
    hold on;
    triplot(t3);
    f=getframe(gcf);
    fg=frame2im(f);
    hold off;
    fg(1:32,:,:) = [];
    fg(512:593,:,:) = [];
    fg(:,1:91,:) = [];
    fg(:,513:605,:) = [];
    imgsplot{fix(10*t+1)}=fg;
    imgs{fix(10*t+1)} = uint8(t*double(imt2) + (1-t)*double(imt));
end
imgs{11} = b;
figure('Visible','off');
imshow(b);
hold on;
triplot(t2);
f=getframe(gcf);
fg=frame2im(f);
fg(1:32,:,:) = [];
fg(512:593,:,:) = [];
fg(:,1:91,:) = [];
fg(:,513:605,:) = [];
imgsplot{11}=fg;
hold off
for i = 1:11
    fname = sprintf('C:\\Users\\anshu\\OneDrive\\Documents\\MATLAB\\%d.jpg',i);
    imwrite(imgs{i},fname);
    fname = sprintf('C:\\Users\\anshu\\OneDrive\\Documents\\MATLAB\\tri_%d.jpg',i);
    imwrite(imgsplot{i},fname);
end