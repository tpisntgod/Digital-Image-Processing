src=imread('sport car.pgm');
[M,N]=size(src);
t1=rand(M,N)*255;
t2=rand(M,N)*255;
%处理t1(i,j)==t2(i,j)的情况，保证t1(i,j)!=t2(i,j)
for i=1:M
    for j=1:N
        while t1(i,j)==t2(i,j)
            t2(i,j)=rand()*255;
        end
    end
end
f=zeros(M,N);

for i=1:M
    for j=1:N
        if ( src(i,j)>t1(i,j) && src(i,j)>t2(i,j) )
            f(i,j)=255;
        elseif ( src(i,j)<t1(i,j) && src(i,j)<t2(i,j) )
            f(i,j)=0;
        else
            f(i,j)=src(i,j);
        end
    end
end
f=uint8(f);
B=medfilt2(f,[3 3]);

%填充源图像
pm=1; pn=1;
f_exp=padarray(f,[pm,pn],'symmetric','both');
f_median_filter=zeros(M,N);
%中值滤波
for i=pm+1:pm+M
    for j=pn+1:pn+N
        submatrix=f_exp(i-pm:i+pm,j-pn:j+pn);
        sub_vec=submatrix(:);
        M=median(sub_vec);
        f_median_filter(i-pm,j-pn)=M;
    end
end
f_median_filter=uint8(f_median_filter);

figure;
subplot(2,2,1);
imshow(src);title('原图像');
subplot(2,2,2);
imshow(f);title('椒盐噪声图像');
subplot(2,2,3);
imshow(f_median_filter);title('中值滤波图像')
subplot(2,2,4);
imshow(B);title('medfilt2');