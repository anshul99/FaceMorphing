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