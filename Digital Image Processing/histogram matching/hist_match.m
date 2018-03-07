%����ͼƬ
H=imread('EightAM.png');

%���ֱ��ͼƥ��ǰ��ͼƬ
subplot(2,3,1);
imshow(H);title('before histogram match');
subplot(2,3,4);
imhist(H);title('before histogram match');

%imhist������ͼ��ֱ��ͼͳ�ƣ�x�ǻҶ�ֵ������counts��x�ĻҶ�ֵ��Ӧ�����ظ���������
[counts,x]=imhist(H);

%��ԭʼͼ�����ֱ��ͼ����任
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

%Matlab�Դ���������ֱ��ͼƥ��
target_hist=imhist(T);
match_hist=histeq(H,target_hist);

%��Ŀ��ͼ����ֱ��ͼ����
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

%��ÿ��ԭʼͼ�����������ֵsk��ȥĿ��ͼ������GͼѰ����Ӧ��Zqֵ��ӳ��
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

%���Matlab�Դ��������Լ�����Ľ��
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