%读入图片
H=imread('river.JPG');

%输出直方图均衡前的图片
figure;
subplot(2,3,1);
imshow(H);title('before histeq');
subplot(2,3,4);
imhist(H);title('before histeq');

%imhist函数对图像直方图统计，x是灰度值向量，counts是x的灰度值对应的像素个数的向量
[counts,x]=imhist(H);

%Matlab自带直方图均衡
B=histeq(H,256);

%自己直方图均衡处理
[M,N]=size(H);
A=zeros(M,N);
pixels=M*N;
sum=0;
for i=1:length(x)
    sum=sum+counts(i);
    P=find(H==x(i));
    A(P)=(length(x)-1)*sum/pixels;
end
H=uint8(A);

%输出Matlab自带函数和自己处理的结果
subplot(2,3,2);
imshow(B);title('Matlab histeq');
subplot(2,3,5);
imhist(B);title('Matlab histeq');
subplot(2,3,3);
imshow(H);title('my function histeq');
subplot(2,3,6);
imhist(H);title('my function histeq');