src=imread('barb.png');
[m,n]=size(src);
src=double(src);
[N,M]=meshgrid(1:n,1:m);

%图像乘以(-1)^(x+y)  中心变换
src_trans=src.*(-1).^(M+N);

% fft2 傅里叶变换
FF = fft2(src_trans);

P=m/2;
Q=n/2;
D=[10,20,40,80];
rank=1;
G=zeros(m,n);
Butterworth_filter=zeros(m,n);
figure;

for i=1:length(D)
    G = FF;
    %生成Butterworth低通滤波器
    Butterworth_filter =  1./ ( 1 + ( sqrt((M-P).^2 + (N-Q).^2) ./ D(i) ) .^(2*rank) ) ;
    %低通滤波
    G = G .* Butterworth_filter;
    %DFT反变换后取实部
    G=ifft2(G); G=real(G);
    %图像乘以(-1)^(x+y)  反中心变换
    G=G.*(-1).^(M+N);
    subplot(2,2,i);
    imshow(G,[]);title( sprintf('D0=%d',D(i)) );
end