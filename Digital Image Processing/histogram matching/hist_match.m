%读入图片
H=imread('EightAM.png');

%输出直方图匹配前的图片
subplot(2,3,1);
imshow(H);title('before histogram match');
subplot(2,3,4);
imhist(H);title('before histogram match');

%imhist函数对图像直方图统计，x是灰度值向量，counts是x的灰度值对应的像素个数的向量
[counts,x]=imhist(H);

%对原始图像进行直方图均衡变换
[M,N]=size(H);
Htrans=zeros(M,N);
A=zeros(length(x),1);
pixels=M*N;
sum=0;
for i=1:length(x)
    sum=sum+counts(i);
    P=find(H==x(i));
    A(i)=(length(x)-1)*sum/pixels;
    Htrans(P)=(length(x)-1)*sum/pixels;
end
Atoint=uint8(A);
H=uint8(Htrans);

T=imread('LENA.png');
[counts2,y]=imhist(T);

%Matlab自带函数进行直方图匹配
target_hist=imhist(T);
match_hist=histeq(H,target_hist);

%对目标图像做直方图均衡
[M2,N2]=size(T);
A2=zeros(length(y),1);
pixels2=M2*N2;
sum2=0;
for i=1:length(y)
    sum2=sum2+counts2(i);
    A2(i)=(length(y)-1)*sum2/pixels2;
end
A2toint=uint8(A2);

balance=zeros(M,N);

%对每个原始图像均衡后的像素值sk，去目标图像均衡后G图寻找相应的Zq值，映射
for i=1:length(Atoint)
    k=99999; l=0;
    for j=1:length(A2toint)
        if abs(Atoint(i)-A2toint(j)) < k
            k=abs(Atoint(i)-A2toint(j));
            l=j-1;
        end
    end
    Afind=find(H==Atoint(i));
    balance(Afind)=l;
end

H=uint8(balance);

% figure;
% imshow(H);title('my function after match');
% figure;
% imhist(H);title('my function after match');

%输出Matlab自带函数和自己处理的结果
subplot(2,3,2);
% figure;
imshow(match_hist);title('Matlab histogram match');
subplot(2,3,5);
% figure;
imhist(match_hist);title('Matlab histogram match');
subplot(2,3,3);
imshow(H);title('my histogram match');
subplot(2,3,6);
imhist(H);title('my histogram match');            