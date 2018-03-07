src=imread('book_cover.jpg');
[m,n]=size(src);
src=double(src);
[N,M]=meshgrid(1:n,1:m);
P=m/2;
Q=n/2;
%Ƶ�ʴ�0��ʼ������1  (-1)^(x+y)���ı任��Ƶ��(0,0)λ�ڸ���Ҷ�任������
U=M-1-P; V=N-1-Q;
%ͼ�����(-1)^(x+y)  ���ı任
src_trans=src.*(-1).^(M+N);
% fft2 ����Ҷ�任
FF = fft2(src_trans);
%����5.6-11����blurring filter  H���˶�ģ���˻�����
T=1.0;
a=0.1;
b=0.1;
K=U.*a+V.*b;
S=sin( pi.*K );
E=exp( (-1i*pi) .* K );
H= T ./ ( pi.* K ) .* S .* E;
sumzeros=(find(K==0));
H(sumzeros)=T;
%ͼ���˻�/ͼ��ģ��
Gfourier=H.*FF;
%DFT���任��ȡʵ��
Gdegeneration=ifft2(Gfourier); G=real(Gdegeneration);
%ͼ�����(-1)^(x+y)  �����ı任
G=G.*(-1).^(M+N);
%������̬�ֲ��������������˹�������ӵ��˶�ģ��ͼ��
avg=0; derivation=sqrt(500);
gaussian_noise=normrnd(avg,derivation,m,n);
%noise���˶�ģ����ͼ���ʱ����
noise=G+gaussian_noise;
% Ӧ�ò���ֱ����Ƶ����������˲��������õ��˶�ģ���˻����ͼ�������ʱ���
% %���˶�ģ��ͼ��������˲�
% Ginverse=Gfourier./H;
% %DFT���任��ȡʵ��
% Ginverse=ifft2(Ginverse); Ginverse=real(Ginverse);
% %ͼ�����(-1)^(x+y)  �����ı任
% Ginverse=Ginverse.*(-1).^(M+N);
%���˶�ģ��ͼ��������˲�����ʱ�˶�ģ��ͼ����ʱ�������Ƶ��
Gbeforeinv=G.*(-1).^(M+N);
GFtrans=fft2(Gbeforeinv);
Gafterinv=GFtrans./H;
Gafterinv( find(abs(H)<0.001) )=0;
Gafterinv=ifft2(Gafterinv); Gafterinv=real(Gafterinv);
Gafterinv=Gafterinv.*(-1).^(M+N);
%�Ӹ�˹�������ͼ�����˲�
D0=20;
Dis=sqrt((M-P).^2 + (N-Q).^2);
Butterworth=1./ ( 1 + ( Dis ./ D0 ) .^2 ) ;
threshold=find(Dis>70);
Hinverse=1./H;
%����(-1)^(x+y)  ���ı任
noise_trans=noise.*(-1).^(M+N);
% fft2 ����Ҷ�任
Gnoisefourier = fft2(noise_trans);
%���˲�
Gnoiseinverse=Gnoisefourier.*Hinverse;
Gnoiseinverse( find(abs(H)<0.001) )=0;
Gnoiseinverse=Butterworth.*Gnoiseinverse;
%DFT���任��ȡʵ��
Gnoiseinverse=ifft2(Gnoiseinverse); Gnoiseinverse=real(Gnoiseinverse);
%ͼ�����(-1)^(x+y)  �����ı任
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
%ά���˲�
Hconj=conj(H);  %H����
Hsquare=Hconj.*H;  %H^2
Klist=[0.01,0.03,0.05];
for i = 1:3
    K=Klist(i);
    weiner= Hsquare ./ ( H .* ( Hsquare + K ) );
    weiner_after = weiner .* Gnoisefourier;
    %DFT���任��ȡʵ��
    weiner_after=ifft2(weiner_after); weiner_after=real(weiner_after);
    %ͼ�����(-1)^(x+y)  �����ı任
    weiner_after=weiner_after.*(-1).^(M+N);
    subplot(2,4,4+i);
    imshow(weiner_after,[]);title( sprintf('wiener filter K=%f ', K ));
end