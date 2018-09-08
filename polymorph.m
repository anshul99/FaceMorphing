n=input('enter the number of images: ');
if n>2
    images=cell(n,1);
    triangulate=cell(n,1);
    im=[];
    for i=1:n
        [filename,user_canceled1] = imgetfile;
        a=imread(filename);
        a=imresize(a,[512 512]);
        images{i}=a;
        im=[im a];
    end
    figure('Visible','on');
    imshow(im);
    [q,w]=getpts();
    hold off;
    figure('Visible','on')
    viscircles([1,1],1);
    theta=2*pi/n;
    hold on;
    plot(1,1,'o');
    x=1;
    y=1;
    txt='average image';
    text(x,y,txt);
    j=1;
    x=zeros(n,1);
    y=zeros(n,1);
    for i=0:theta:2*pi
        x(j)=cos(i)+1;
        y(j)=sin(i)+1;
        plot(x(j),y(j),'o');
        txt=sprintf('image %d',j);
        text(x(j),y(j),txt);
        j=j+1;
    end
    [u,v]=getpts();
    points=cell(n,1);
    averagepoints=zeros((length(q)/n)+4,2);
    for i=1:n
        points{i}(:,1)=q(i:n:end);
        points{i}(:,2)=w(i:n:end);
        points{i}(:,1)=points{i}(:,1)-512*(i-1);
        points{i}=[points{i};1,1;512,512;512,1;1,512];
        averagepoints=averagepoints+points{i};
        triangulate{i}=delaunayTriangulation(points{i});
    end
    averagepoints=averagepoints/n;
    averagetriangulation=delaunayTriangulation(averagepoints);
    averageimage=uint8(zeros(512,512,3));
    for i=1:n
        warpimage=warp(images{i},triangulate{i},points{i},averagepoints);
        averageimage=averageimage+warpimage/n;
    end
    
    morphs=cell(1,1);
    count=1;
    for i=1:length(u)
        [index,bary]=checktriangle(u(i),v(i),x,y);
        if index>0 && index<n
            pts=bary(1)*averagepoints+bary(2)*points{index}+bary(3)*points{index+1};
            warpavg=warp(averageimage,averagetriangulation,averagepoints,pts);
            warpind=warp(images{index},triangulate{index},points{index},pts);
            warpind2=warp(images{index+1},triangulate{index+1},points{index+1},pts);
            morphs{count}=bary(1)*warpavg+bary(2)*warpind+bary(3)*warpind2;
            count=count+1;
        elseif index==n
            pts=bary(1)*averagepoints+bary(2)*points{index}+bary(3)*points{1};
            warpavg=warp(averageimage,averagetriangulation,averagepoints,pts);
            warpind=warp(images{index},triangulate{index},points{index},pts);
            warpind2=warp(images{1},triangulate{1},points{1},pts);
            morphs{count}=bary(1)*warpavg+bary(2)*warpind+bary(3)*warpind2;
            count=count+1;
        end
    end
    writerObj = VideoWriter('imagemorphingvideo.avi');
    writerObj.FrameRate = 12;
    open(writerObj);
    for u=1:length(morphs)
        frame = im2frame(morphs{u});
        writeVideo(writerObj, frame);
    end
    close(writerObj);
else
    disp('enter valid number of images');
end
function[index,bary]=checktriangle(u,v,x,y)
for i=1:length(x)-1
    
    tri=[1,1;x(i),y(i);x(i+1),y(i+1)];
    t=triangulation([1 2 3],tri);
    bary=cartesianToBarycentric(t,1,[u,v]);
    if bary(1)>=0 && bary(2)>=0 && bary(3)>=0
        index=i;
        return;
    end
end
tri=[1,1;x(length(x)),y(length(x));x(1),y(1)];
t=triangulation([1 2 3],tri);
bary=cartesianToBarycentric(t,1,[u,v]);
if bary(1)>=0 && bary(2)>=0 && bary(3)>=0
    index=length(x);
    return;
else
    index=-1;
    return
end
end
function warpa = warp(a,t1,p1,p3)
[m,n,~]=size(a);
warpa=zeros(m,n);
[s,~]=size(t1.ConnectivityList);
for i=1:s
    pt1=p1(t1.ConnectivityList(i,:),:);
    pt3=p3(t1.ConnectivityList(i,:),:);
    zer=zeros(3);
    on=ones(3,1);
    mat=[pt3 on zer ; zer pt3 on];
    mat2=[pt1(:,1);pt1(:,2)];
    mat=mat^-1;
    asd=mat*mat2;
    tform=[asd(1),asd(2),asd(3);asd(4),asd(5),asd(6);0,0,1];
    q=round(min(pt3));
    w=round(max(pt3));
    P1=pt3(1,:);
    P2=pt3(2,:);
    P3=pt3(3,:);
    P12 = P1-P2; P23 = P2-P3; P31 = P3-P1;
    for k=q(1):w(1)
        for j=q(2):w(2)
            P=[k,j];
            r=sign(det([P31;P23]))*sign(det([P3-P;P23])) >= 0 & ...
                sign(det([P12;P31]))*sign(det([P1-P;P31])) >= 0 & ...
                sign(det([P23;P12]))*sign(det([P2-P;P12])) >= 0 ;
            if r==1
                u = tform*[k;j;1];
                if u(1)>0 && u(1)<=m && u(2)>0 && u(2)<=n
                    warpa(j,k,1)=a(ceil(u(2)),ceil(u(1)),1);
                    warpa(j,k,2)=a(ceil(u(2)),ceil(u(1)),2);
                    warpa(j,k,3)=a(ceil(u(2)),ceil(u(1)),3);
                end
            end
        end
    end
end
warpa=uint8(warpa);
end