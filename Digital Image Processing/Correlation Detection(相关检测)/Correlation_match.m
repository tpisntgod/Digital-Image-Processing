source=imread('car.png');
template=imread('wheel.png');
[M,N]=size(source);
[m,n]=size(template);
temp_vec=double(template(:));
temp_norm=norm(temp_vec);

%���Դͼ��
src_exp=padarray(source,[(m-1)/2,(n-1)/2],0,'both');
corr=zeros(M,N);
hm=(m-1)/2; hn=(n-1)/2;
%��ؼ��
for i=hm+1:hm+M
    for j=hn+1:hn+N
        submatrix=src_exp(i-hm:i+hm,j-hn:j+hn);
        sub_vec=double(submatrix(:));
        corr(i-hm,j-hn)=temp_vec'*sub_vec/ (norm(sub_vec)*temp_norm+eps);
    end
end

%��ʾͼ������ֵ���
file=fopen('correlation(ͼ������ֵ).txt','w');
[r,c]=size(corr);
for i=1:r
    for j=1:c
        fprintf(file,'%5f\t',corr(i,j));
    end
    fprintf(file,'\r\n');
end
fclose(file);

%�ҳ����ֵ����Ҫ������ص�����
[i_corr,j_corr]=find(corr>0.95);
%[i_corr,j_corr]=find(corr == max(corr(:)));

%�г���ͼ���м�⵽������Ŀ��ģ�x��y�����굽�ļ���
file2=fopen('target_coordinate(��⵽Ŀ�������).txt','w');

figure;
imshow(source);
hold on
for i=1:length(i_corr)
    %�����ͼ���г���⵽������Ŀ��ģ�x��y������
    text((2*i-1)*40,-10,['(',num2str(j_corr(i)),','],'horiz','center');
    text((2*i-1)*40+20,-10,[num2str(i_corr(i)), ')'],'horiz','center');
    %�г���ͼ���м�⵽������Ŀ��ģ�x��y�����굽�ļ���
    fprintf(file2,'target %d: (%d,%d)',i,j_corr(i),i_corr(i));
    fprintf(file,'\r\n');
    %�����ͼ������������ɾ��Σ������⵽��Ŀ��ķ�Χ����*�������
    plot(j_corr(i),i_corr(i),'*');
    %��
    plot([j_corr(i)-hn,j_corr(i)+hn],[i_corr(i)-hm,i_corr(i)-hm]);
    %��
    plot([j_corr(i)-hn,j_corr(i)+hn],[i_corr(i)+hm,i_corr(i)+hm]);
    %��
    plot([j_corr(i)-hn,j_corr(i)-hn],[i_corr(i)-hm,i_corr(i)+hm]);
    %��
    plot([j_corr(i)+hn,j_corr(i)+hn],[i_corr(i)-hm,i_corr(i)+hm]);
end
fclose(file2);