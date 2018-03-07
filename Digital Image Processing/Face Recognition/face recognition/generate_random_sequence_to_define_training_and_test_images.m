function [training_set_index, test_set_index] = generate_random_sequence_to_define_training_and_test_images()
    % 生成不重复的随机整数序列,用来随机选择训练集和测试集
    % training_set_index 是训练集
    % test_set_index 是测试集
    global num_training_face num_trainingpic_per_face
    global num_test_face num_testpic_per_face
    training_set_index = zeros(num_training_face, num_trainingpic_per_face);
    test_set_index = zeros(num_test_face, num_testpic_per_face);
    generate_times = num_training_face;
    generate_number = num_trainingpic_per_face + num_testpic_per_face;
    for i=1:generate_times
        random_index = randperm(generate_number);
        training_set_index(i, :) = sort( random_index(1: num_trainingpic_per_face) );
        test_set_index(i, :) = sort( random_index(num_trainingpic_per_face + 1: generate_number) );
    end
end