global num_training_face num_trainingpic_per_face num_training_pic
global num_test_face num_testpic_per_face num_test_pic
global m n p k test_info_saved_index k_index
global correct_rate_list
global training_set_index test_set_index

num_training_face = 40;
num_trainingpic_per_face = 7;
num_training_pic = num_training_face * num_trainingpic_per_face;
pic_get_row_column = imread('att_faces\s1\1.pgm');
% m和n，图片长和宽大小  p 图片像素数量
[m,n] = size(pic_get_row_column);
p = m*n;
% k = 50;

num_test_face = 40;
% num_testpic_per_face = 8;
num_testpic_per_face = 3;
num_test_pic = num_test_face * num_testpic_per_face;

test_times = 10;
k_start = 50; k_end = 100;
k_num = k_end - k_start + 1;
% correct_rate_list存放不同值的k的多次测试的正确率
% 每一列保存ki的10次测试的正确率 (i,j) 是k=j的第i次测试的正确率
correct_rate_list = zeros(test_times, k_num);
k_index_list = zeros(k_num, 1);
k_index = 0;

for i = k_start : k_end
    k_index = k_index + 1;
    k_index_list(k_index) = i;
end

for i = 1:test_times
    [training_set_index, test_set_index] = generate_random_sequence_to_define_training_and_test_images();
    k_index = 0;
    test_info_saved_index = i;
    for k = k_start : k_end
        k_index = k_index + 1;
        Face_Recognition();
    end
end

k_rate_list = sum(correct_rate_list) / test_times;
[k_rate_sort,k_rate_I] = sort(-k_rate_list);
k_rate_sort = -k_rate_sort;
k_index_list = k_index_list(k_rate_I);
fprintf('best k :%d , correct rate: %.4f\n', k_index_list(1), k_rate_sort(1));

%disp('Face Recognition finished');