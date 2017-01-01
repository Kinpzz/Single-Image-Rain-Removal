function [ output_hf ] = hf_process( input_hf )
    
    [M, N, l] = size(input_hf);
    for level = 1:l
        field = input_hf(:,:,level);
        k = 9;
        for i = 1:M
            for j = 1:N
                 rs = max(i-(k-1)/2,1);
                 re = min(i+(k-1)/2, M);
                 cs = max(j-(k-1)/2, 1);
                 ce = min(j+(k-1)/2, N);
                 patch = field(rs:re,cs:ce);
                 [m,n] = size(patch);
                 patch_vec = reshape(patch,[],m*n);
                 map(i,j) = var(patch_vec);
            end
        end
        th = graythresh(map);
        for i = 1:M
            for j = 1:N
                if(map(i,j)<th)
                    map(i,j) = 0;
                else
                    map(i,j) = 1;
                end
            end
        end
        output_hf(:,:,level) = field.*map;
    end
    
end

