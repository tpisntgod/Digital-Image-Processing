source=imread('car.png');
template=imread('wheel.png');
[M,N]=size(source);
[m,n]=size(template);
temp_vec=double(template(:));
temp_norm=norm(temp_vec);

%填充源图像
src_exp=padarray(source,[(m-1)/2,(n-1)/2],0,'both');
corr=zeros(M,N);
hm=(m-1)/2; hn=(n-1)/2;
%相关检测
for i=hm+1:hm+M
    for j=hn+1:hn+N
        submatrix=src_exp(i-hm:i+hm,j-hn:j+hn);
        sub_vec=double(submatrix(:));
        corr(i-hm,j-hn)=temp_vec'*sub_vec/ (norm(sub_vec)*temp_norm+eps);
    end
end

%显示图像的相关值结果
file=fopen('correlation(图像的相关值).txt','w');
[r,c]=size(corr);
for i=1:r
    for j=1:c
        fprintf(file,'%5f\t',corr(i,j));
    end
    fprintf(file,'\r\n');
end
fclose(file);

%找出相关值符合要求的像素的坐标
[i_corr,j_corr]=find(corr>0.95);
%[i_corr,j_corr]=find(corr == max(corr(:)));

%列出在图像中检测到的所有目标的（x，y）坐标到文件中
file2=fopen('target_coordinate(检测到目标的坐标).txt','w');

figure;
imshow(source);
hold on
for i=1:length(i_corr)
    %在输出图中列出检测到的所有目标的（x，y）坐标
    text((2*i-1)*40,-10,['(',num2str(j_corr(i)),','],'horiz','center');
    text((2*i-1)*40+20,-10,[num2str(i_corr(i)), ')'],'horiz','center');
    %列出在图像中检测到的所有目标的（x，y）坐标到文件中
    fprintf(file2,'target %d: (%d,%d)',i,j_corr(i),i_corr(i));
    fprintf(file,'\r\n');
    %在输出图中用四条线组成矩形，标出检测到的目标的范围，用*标出中心
    plot(j_corr(i),i_corr(i),'*');
    %上
    plot([j_corr(i)-hn,j_corr(i)+hn],[i_corr(i)-hm,i_corr(i)-hm]);
    %下
    plot([j_corr(i)-hn,j_corr(i)+hn],[i_corr(i)+hm,i_corr(i)+hm]);
    %左
    plot([j_corr(i)-hn,j_corr(i)-hn],[i_corr(i)-hm,i_corr(i)+hm]);
    %右
    plot([j_corr(i)+hn,j_corr(i)+hn],[i_corr(i)-hm,i_corr(i)+hm]);
end
fclose(file2);