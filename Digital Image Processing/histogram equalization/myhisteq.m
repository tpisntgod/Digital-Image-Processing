%����ͼƬ
H=imread('river.JPG');

%���ֱ��ͼ����ǰ��ͼƬ
figure;
subplot(2,3,1);
imshow(H);title('before histeq');
subplot(2,3,4);
imhist(H);title('before histeq');

%imhist������ͼ��ֱ��ͼͳ�ƣ�x�ǻҶ�ֵ������counts��x�ĻҶ�ֵ��Ӧ�����ظ���������
[counts,x]=imhist(H);

%Matlab�Դ�ֱ��ͼ����
B=histeq(H,256);

%�Լ�ֱ��ͼ���⴦��
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

%���Matlab�Դ��������Լ�����Ľ��
subplot(2,3,2);
imshow(B);title('Matlab histeq');
subplot(2,3,5);
imhist(B);title('Matlab histeq');
subplot(2,3,3);
imshow(H);title('my function histeq');
subplot(2,3,6);
imhist(H);title('my function histeq');