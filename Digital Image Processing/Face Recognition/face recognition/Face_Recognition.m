function [] = Face_Recognition()

function [pic, pic_identity, avg_training_pic] = read_training_images_and_deduct_mean_from_images()
    % ����ѵ����ͼƬ��������ؾ�ֵ��ÿ��ͼƬ����ֵ����ȥ��ֵ
    global num_training_face num_trainingpic_per_face num_training_pic
    global p
    global training_set_index
    % pic�����������ѵ����ͼƬ m*n*k k��ѵ����ͼƬ������һ���ض���k0��ʾm*n��С��һ��ͼƬ
    % pic(:, i) ��������xi.  pic_identity �ǵ�i��ͼƬ�������Ϣ
    pic = zeros(p,1,num_training_pic);
    pic_identity = zeros(num_training_pic, 2);
    % sum_training_pic ѵ����ͼƬ���������������ֵ֮��
    sum_training_pic = zeros(p,1);
    index = 0;
    for i=1:num_training_face
        for j=1:num_trainingpic_per_face
            index = index + 1;
            read_path_i = i;
            read_path_j = training_set_index(i, j);
            facePath = sprintf('att_faces\\s%d\\%d.pgm', read_path_i, read_path_j);
            read_pic = imread(facePath);
            % m*n��ͼƬ��� p*1 ��������
            read_pic = reshape(read_pic, p, 1);
            pic(:, 1, index) = read_pic;
            pic_identity(index, 1) = read_path_i;
            pic_identity(index, 2) = read_path_j;
            sum_training_pic = sum_training_pic + pic(:, 1, index);
        end
    end
    
    % Compute the mean of the given images
    avg_training_pic = sum_training_pic / num_training_pic;
    
    % Deduct the mean from each point:    
    for i=1:num_training_pic
        pic(:, 1, i) = pic(:, 1, i) - avg_training_pic;
    end

end

function [L, picX] = compute_XTX(pic)
    % ���ټ����������� ������� L = X^TX
    % X^T��X��ת��
    global num_training_pic
    global p
    % Compute X^TX size N*N reducing computational complexity
    picX = zeros(p, num_training_pic);
    for i=1:num_training_pic
        picX(:,i) = pic(:, 1, i);
    end
    L = picX' * picX ;
    %L = L / (num_training_pic - 1);
end

function [V,D] = calculate_normalized_eigenvectors_and_eigenvalues_of_C(L, picX)
    % ��L���������� W , ����ֵD, ����W��Э�������C����������V��V = XW
    % Ȼ��V��λ��
    global num_training_pic
    % Find the eigenvectors W of L
    [W,D] = eig(L);
    % Obtain the eigenvectors of C from those of L
    V = picX * W;
    % Unit-normalize the columns of V
    for i=1:num_training_pic
        V(:, i) = V(:, i) ./ norm( V(:,i) );
    end
end

function [Veig, VeigTrans] = pick_eigenvectors_corresponding_to_k_largest_eigenvalues(V, D)
    % ��������ֵ��С�������У���Ӧ����������Ҳ�������У�ѡ��k����������ֵ��Ӧ���������������eigenspace
    % Veig��eigenspace,VeigTrans��Veig��ת��
    global k
    [Dsort,I] = sort(diag(-D));
    % -Dsort���ǰ��ս������е�C������ֵD
    Dsort=-Dsort;
    % ����������������ֵ��������
    V = V(:, I);
    % Extract the k eigenvectors corresponding to the k largest eigenvalues. This is called the extracted eigenspace
    Veig = V(:, 1:k);
    VeigTrans = Veig';
end

function [covariance] = covariance_matrix(pic)
    global num_training_face num_trainingpic_per_face num_training_pic
    global p
    % ��Э�������C
    % Compute the covariance matrix of these mean-deducted points
    % use XX^T size d*d
    covariance = zeros(p,p);
    for i=1:num_training_face
        for j=1:num_trainingpic_per_face
            kk = (i-1) * num_trainingpic_per_face + j;
            covariance = covariance + pic(:, 1, kk) * pic(:, 1, kk)';
        end
    end
    covariance = covariance / (num_training_pic - 1);
end

function [V,D] = get_eigenvectors_of_covariance_matrix(covariance)
    % ��Э�������C����������V������ֵD
    % Find the eigenvectors of C covariance
    [V,D] = eig(covariance);
end

function coefficients_eig = project_image_onto_eigenspace(VeigTrans, pic)
    % ��ÿ��ͼƬ��ȥ����ƽ��ֵ֮�������ӳ�䵽eigenspace,�õ�eigen-coefficients
    % coefficients_eig �� eigen-coefficients ����ʦpdf�е�aik
    % Project each point onto the eigenspace, giving a vector of k eigen-coefficients for that point
    % global num_training_face num_trainingpic_per_face num_training_pic
    global num_training_pic
    global k
    coefficients_eig = zeros(k, num_training_pic);

    for i=1:num_training_pic
        coefficients_eig(:, i) = VeigTrans * pic(:, 1, i);
    end
end

function [result, correct_rate_info] = test_phase(pic_identity, VeigTrans, coefficients_eig, avg_training_pic)
    % ���Խ׶� �Ƚ�����ͼ���n*m�����Ϊp*1������Zp p=n*m
    % Zp��ȥѵ���׶������ͼ����������ƽ������ֵ
    % ӳ��Zp��eigenspace,���Zp��eigen-coefficients
    % ��Zp��eigen-coefficients��ѵ����ͼƬ��eigen-coefficients��ŷ����þ����ƽ��jp
    % jp��Сֵ��Ӧ��ѵ����ͼƬ����ƥ��ͼƬ
    % Test phase
    % num_test_face �ṩͼƬ�Ĳ���������  num_testpic_per_face ÿ�������ߵĲ���ͼƬ����
    % success_match �ɹ�ƥ������� fail_match ����ƥ�������
    % sum_diff �� difference �ǲ���ͼ���ѵ��ͼ���ŷ����þ����ƽ��
    % test_index ����ͼ���±�
    global num_training_face num_trainingpic_per_face
    global num_test_face num_testpic_per_face num_test_pic
    global p
    global correct_rate_list test_info_saved_index k_index
    global test_set_index
    
    success_match = 0;
    fail_match = 0;
    test_index = 0;
    for i=1:num_test_face
        for j=1:num_testpic_per_face
            test_index = test_index + 1;
            read_path_i = i;
            read_path_j = test_set_index(i, j);
            testpic_facePath = sprintf('att_faces\\s%d\\%d.pgm', read_path_i, read_path_j);
            %index = (i-1) * num_testpic_per_face + j;
            read_test_pic = imread(testpic_facePath);
            Zp = reshape(read_test_pic, p, 1);
            Zp = double(Zp);
            Zp = Zp - avg_training_pic;
            test_coefficients_eig = VeigTrans * Zp;

            % compare ap with all the aik in the database
            min_diff = 10^8;
            match_index_i = 0;
            match_index_j = 0;
            index = 0;
            for i2=1:num_training_face
                for j2=1:num_trainingpic_per_face
                    index = index + 1;
                    diff = test_coefficients_eig - coefficients_eig(:, index);
                    diff = diff.^2;
                    sum_diff = sum(diff);
                    if sum_diff < min_diff
                        match_index_i = pic_identity(index, 1);
                        match_index_j = pic_identity(index, 2);
                        min_diff = sum_diff;
                    end
                end
            end

            testpic_output = imread(testpic_facePath);
            if match_index_i ~= i
                fail_match = fail_match + 1;
                fail_info = sprintf('test image s%d %d , mismatch to training image s%d %d', i, j, match_index_i, match_index_j);
                
                % disp(fail_info);
                
            else
                success_match = success_match + 1;
            end
            
        end
    end

    correct_rate = success_match / num_test_pic;
    correct_rate_list(test_info_saved_index, k_index) = roundn(correct_rate, -4);
    result = sprintf('success match %d , mismatch %d', success_match, fail_match);
    correct_rate_info = sprintf('correct_rate %f',correct_rate);
end


[pic, pic_identity, avg_training_pic] = read_training_images_and_deduct_mean_from_images();

% �Ż���ķ���
[L, picX] = compute_XTX(pic);
[V,D] = calculate_normalized_eigenvectors_and_eigenvalues_of_C(L, picX);

% �Ż�ǰ�ķ���
% covariance = covariance_matrix(pic);
% [V,D] = get_eigenvectors_of_covariance_matrix(covariance);

[~, VeigTrans] = pick_eigenvectors_corresponding_to_k_largest_eigenvalues(V, D);
coefficients_eig = project_image_onto_eigenspace(VeigTrans, pic);
[result, correct_rate_info] = test_phase(pic_identity, VeigTrans, coefficients_eig, avg_training_pic);

% disp(result);
% disp(correct_rate_info);

end