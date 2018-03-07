src=imread('book_cover.jpg');
[m,n]=size(src);
src=double(src);
[N,M]=meshgrid(1:n,1:m);
P=m/2;
Q=n/2;
%频率从0开始而不是1  (-1)^(x+y)中心变换后，频率(0,0)位于傅里叶变换后中心
U=M-1-P; V=N-1-Q;
%图像乘以(-1)^(x+y)  中心变换
src_trans=src.*(-1).^(M+N);
% fft2 傅里叶变换
FF = fft2(src_trans);
%根据5.6-11生成blurring filter  H是运动模糊退化函数
T=1.0;
a=0.1;
b=0.1;
K=U.*a+V.*b;
S=sin( pi.*K );
E=exp( (-1i*pi) .* K );
H= T ./ ( pi.* K ) .* S .* E;
sumzeros=(find(K==0));
H(sumzeros)=T;
%图像退化/图像模糊
Gfourier=H.*FF;
%DFT反变换后取实部
Gdegeneration=ifft2(Gfourier); G=real(Gdegeneration);
%图像乘以(-1)^(x+y)  反中心变换
G=G.*(-1).^(M+N);
%生成正态分布随机数，当做高斯噪声，加到运动模糊图像
avg=0; derivation=sqrt(500);
gaussian_noise=normrnd(avg,derivation,m,n);
%noise是运动模糊后图像的时域表达
noise=G+gaussian_noise;
% 应该不是直接在频率域进行逆滤波，我们拿到运动模糊退化后的图像基本是时域的
% %对运动模糊图像进行逆滤波
% Ginverse=Gfourier./H;
% %DFT反变换后取实部
% Ginverse=ifft2(Ginverse); Ginverse=real(Ginverse);
% %图像乘以(-1)^(x+y)  反中心变换
% Ginverse=Ginverse.*(-1).^(M+N);
%对运动模糊图像进行逆滤波，此时运动模糊图像是时域而不是频域
Gbeforeinv=G.*(-1).^(M+N);
GFtrans=fft2(Gbeforeinv);
Gafterinv=GFtrans./H;
Gafterinv( find(abs(H)<0.001) )=0;
Gafterinv=ifft2(Gafterinv); Gafterinv=real(Gafterinv);
Gafterinv=Gafterinv.*(-1).^(M+N);
%加高斯噪声后的图像逆滤波
D0=20;
Dis=sqrt((M-P).^2 + (N-Q).^2);
Butterworth=1./ ( 1 + ( Dis ./ D0 ) .^2 ) ;
threshold=find(Dis>70);
Hinverse=1./H;
%乘以(-1)^(x+y)  中心变换
noise_trans=noise.*(-1).^(M+N);
% fft2 傅里叶变换
Gnoisefourier = fft2(noise_trans);
%逆滤波
Gnoiseinverse=Gnoisefourier.*Hinverse;
Gnoiseinverse( find(abs(H)<0.001) )=0;
Gnoiseinverse=Butterworth.*Gnoiseinverse;
%DFT反变换后取实部
Gnoiseinverse=ifft2(Gnoiseinverse); Gnoiseinverse=real(Gnoiseinverse);
%图像乘以(-1)^(x+y)  反中心变换
Gnoiseinverse=Gnoiseinverse.*(-1).^(M+N);
figure;
subplot(2,4,1);
imshow(G,[]);title('blurred image');
subplot(2,4,2);
imshow(noise,[]);title('gaussian noise');
subplot(2,4,3);
imshow(Gafterinv,[]);title('inverse filter blurred image');
subplot(2,4,4);
imshow(Gnoiseinverse,[]);title('inverse filter blurred noisy image');
%维纳滤波
Hconj=conj(H);  %H共轭
Hsquare=Hconj.*H;  %H^2
Klist=[0.01,0.03,0.05];
for i = 1:3
    K=Klist(i);
    weiner= Hsquare ./ ( H .* ( Hsquare + K ) );
    weiner_after = weiner .* Gnoisefourier;
    %DFT反变换后取实部
    weiner_after=ifft2(weiner_after); weiner_after=real(weiner_after);
    %图像乘以(-1)^(x+y)  反中心变换
    weiner_after=weiner_after.*(-1).^(M+N);
    subplot(2,4,4+i);
    imshow(weiner_after,[]);title( sprintf('wiener filter K=%f ', K ));
end