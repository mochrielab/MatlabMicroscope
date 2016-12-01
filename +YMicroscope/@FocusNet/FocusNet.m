classdef FocusNet < handle
    % FOCUSNET
    % using deep learning to predict focal plane
    
    properties
        net
        batchsize
        input
        mean
        var
    end
    
    methods
        % constructor
        function obj = FocusNet(model_path, batchsize)
            obj.batchsize = batchsize;
            switch batchsize
                case 1
                    model_def = fullfile(model_path,'deploy_1_1.prototxt');
                case 4
                    model_def = fullfile(model_path,'deploy_1_4.prototxt');
                case 16
                    model_def = fullfile(model_path,'deploy_1_16.prototxt');
                otherwise
                    error('unsupported batch size')
            end
            model_weights = fullfile(model_path,'stage_1_final_1.caffemodel');
            caffe.reset_all();
            % caffe.set_mode_cpu();
            caffe.set_mode_gpu();
            caffe.set_device(0);
            obj.net = caffe.Net(model_def, model_weights, 'test');
        end
        
        % convert images
        function loadImages(obj, img, varargin)
            have_max_min = 0;
            if nargin == 4
                have_max_min = 1;
                imgmax = varargin{1};
                imgmin = varargin{2};
            end
            [height, width] = size(img);
            obj.input = zeros(96, 96, 1, obj.batchsize);
            if height == 256 && width == 256 && obj.batchsize == 1
                obj.input(:, :, 1, 1) = preprocess(img);
            elseif height == 512 && width ==512 && obj.batchsize == 4
                input_index = 1;
                for ic = 0:1
                    for ir = 0:1
                        obj.input(:, :, 1, input_index) = ...
                            preprocess(img(ir*256+(1:256), ic*256+(1:256)));
                        input_index = input_index + 1;
                    end
                end
            elseif width == 1024 && height == 1344 && obj.batchsize == 16
                input_index = 1;
                for ic = 0:3
                    for ir = 0:3
                        obj.input(:, :, 1, input_index) = ...
                            preprocess(img(ir*256+(1:256)+160, ic*256+(1:256)));
                        input_index = input_index + 1;
                    end
                end
                % elseif height == 256 && width ==256 && obj.batchsize = 16
            else
                error('not matching image and batchsize')
            end
            function img = preprocess(img)
                img = single(imresize(img, [96 96]));
                if have_max_min
                    img = (img - imgmin)/(imgmax - imgmin)*256-128;
                else
                    if maximg > minimg
                        img = (img - mean(img(:)))/std(img(:))*16;
                    else
                        img = zeros(size(img))+128;
                    end
                end
            end
        end
        
        % inference
        function inference(obj)
            loss = obj.net.forward({obj.input});
            obj.mean = loss{1};
            obj.var = loss{2};
        end
        
        % plot
        function plot(obj, varargin)
            if nargin >= 2
                imagesc(varargin{1}); axis image; axis off; colormap gray; hold on;
            end
            switch obj.batchsize
                case 1
                    error('not implemented')
                case 4
                    error('not implemented')
                case 16
                    input_index = 1;
                    for ic = 0:3
                        for ir = 0:3
                            rectangle(...
                                'Position', [ic*256+1, ir*256+161, 256, 256], ...
                                'EdgeColor', 'g');
                            text(ic*256+1+80, ir*256+161+80, ...
                                [num2str(obj.mean(input_index), '%1.2f'), '\pm',...
                                num2str(sqrt(obj.var(input_index)+0.01), '%1.2f')],...
                                'Color','r');
                            input_index = input_index + 1;
                        end
                    end
                otherwise
                    error('unsupported batchsize')
            end
        end
        
    end
    
end

