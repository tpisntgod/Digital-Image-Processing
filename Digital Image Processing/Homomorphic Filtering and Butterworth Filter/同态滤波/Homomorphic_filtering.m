src_rgb=imread('office.jpg');
%rgbͼ��ת��gray
src=double(rgb2gray(src_rgb));
%ȡ����
src=log(src+1);
[m,n]=size(src);
[N,M]=meshgrid(1:n,1:m);

% fft2 ����Ҷ�任
FF = fft2(src);

P=m/2;
Q=n/2;
D=[100,500,1000,2000];
rh=2.0; rl=0.25; c=1.0;
rank=1;
G=zeros(m,n);
Homomorphic_filter=zeros(m,n);
figure;

for i=1:length(D)
    G = FF;
    %����̬ͬ�˲���
    Homomorphic_filter = (rh-rl) .* ( 1 - exp ( (-c) .* ( ( (M-P).^2 + (N-Q).^2 ) ./ D(i).^2 ) ) ) + rl;
    %̬ͬ�˲�
    G = G .* Homomorphic_filter;
    %DFT���任
    G=ifft2(G);
    %��ȡָ������ȡʵ�������-1����Ϊ�������ʱ��+1
    G=real(exp(G))-1;
    %��ͼ������ֵӳ�䵽[0,255]
    MAX=max(max(G));
    MIN=min(min(G));
    G=255.*(G-MIN) ./ (MAX-MIN);
    G=uint8(G);
    subplot(2,2,i);
    %imshow(G,[]);title( sprintf('D0=%d',D(i)) );
    imshow(G);title( sprintf('D0=%d',D(i)) );
end