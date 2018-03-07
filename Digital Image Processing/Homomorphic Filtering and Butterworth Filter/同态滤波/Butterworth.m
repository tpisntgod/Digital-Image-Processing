src_rgb=imread('office.jpg');
%rgbͼ��ת��gray
src=double(rgb2gray(src_rgb));
[m,n]=size(src);
[N,M]=meshgrid(1:n,1:m);

%ͼ�����(-1)^(x+y)  ���ı任
src_trans=src.*(-1).^(M+N);

% fft2 ����Ҷ�任
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
    %����Butterworth��ͨ�˲���
    Butterworth_filter =  1./ ( 1 + ( D(i) ./ sqrt((M-P).^2 + (N-Q).^2) ) .^(2*rank) ) ;
    %��ͨ�˲�
    G = G .* Butterworth_filter;
    %DFT���任��ȡʵ��
    G=ifft2(G);
    G=real(G);
    %ͼ�����(-1)^(x+y)  �����ı任
    G=G.*(-1).^(M+N);
    %��ͼ������ֵӳ�䵽[0,255]
    MAX=max(max(G));
    MIN=min(min(G));
    G=255.*(G-MIN) ./ (MAX-MIN);
    G=uint8(G);
    subplot(2,2,i);
    imshow(G,[]);title( sprintf('D0=%d',D(i)) );
end