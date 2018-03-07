src=imread('barb.png');
[m,n]=size(src);
src=double(src);
[N,M]=meshgrid(1:n,1:m);

%ͼ�����(-1)^(x+y)  ���ı任
src_trans=src.*(-1).^(M+N);

% fft2 ����Ҷ�任
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
    %����Butterworth��ͨ�˲���
    Butterworth_filter =  1./ ( 1 + ( sqrt((M-P).^2 + (N-Q).^2) ./ D(i) ) .^(2*rank) ) ;
    %��ͨ�˲�
    G = G .* Butterworth_filter;
    %DFT���任��ȡʵ��
    G=ifft2(G); G=real(G);
    %ͼ�����(-1)^(x+y)  �����ı任
    G=G.*(-1).^(M+N);
    subplot(2,2,i);
    imshow(G,[]);title( sprintf('D0=%d',D(i)) );
end