src_rgb=imread('office.jpg');
%rgb图像转成gray
src=double(rgb2gray(src_rgb));
[m,n]=size(src);
[N,M]=meshgrid(1:n,1:m);

%图像乘以(-1)^(x+y)  中心变换
src_trans=src.*(-1).^(M+N);

% fft2 傅里叶变换
FF = fft2(src_trans);

P=m/2;
Q=n/2;
D=[1,2,4,8];
rank=1;
G=zeros(m,n);
Butterworth_filter=zeros(m,n);
figure;

for i=1:length(D)
    G = FF;
    %生成Butterworth高通滤波器
    Butterworth_filter =  1./ ( 1 + ( D(i) ./ sqrt((M-P).^2 + (N-Q).^2) ) .^(2*rank) ) ;
    %高通滤波
    G = G .* Butterworth_filter;
    %DFT反变换后取实部
    G=ifft2(G);
    G=real(G);
    %图像乘以(-1)^(x+y)  反中心变换
    G=G.*(-1).^(M+N);
    %将图像像素值映射到[0,255]
    MAX=max(max(G));
    MIN=min(min(G));
    G=255.*(G-MIN) ./ (MAX-MIN);
    G=uint8(G);
    subplot(2,2,i);
    imshow(G,[]);title( sprintf('D0=%d',D(i)) );
end