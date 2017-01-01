function [ DoF ] = computeDoF( input )
    I = 0.299*input(:,:,1) + 0.587*input(:,:,2) + 0.114*input(:,:,3);
    dx = [0,0,0;0,1,-1;0,0,0];
    dy = [0,0,0;0,1,0;0,-1,0];
    %every point's intensity distribution
    %I_dx = imfilter(I,dx,'replicate');
    %I_dy = imfilter(I,dy,'replicate');
    %p_x1 = getHistMap(I_dx, I_dx);
    %p_y1 = getHistMap(I_dy, I_dy);
    p_x1 = abs(imfilter(I, dx, 'replicate'));
    %p_x1 = p_x1./sum(p_x1(:));
    p_y1 = abs(imfilter(I, dy, 'replicate'));
    %p_y1 = p_y1./sum(p_y1(:));
    m = 3;
    n = 3;
    extra_col = (m-1)/2;
    extra_row = (n-1)/2;
    p_x1 = mirrorEdge(p_x1,extra_row,extra_col);
    p_y1 = mirrorEdge(p_y1,extra_row,extra_col);

    p_x = ones(size(I,1),size(I,2),3);
    p_y = p_x;
    D = p_x;
    for i = 1:3
        k = 2*i + 1;
        blur_filter = 1/k^2.*ones(k,k);
        blur_image = imfilter(I, blur_filter,'replicate');
        
        %p_x(:,:,i) = getHistMap(imfilter(blur_image, dx, 'replicate'),I_dx);
        %p_y(:,:,i) = getHistMap(imfilter(blur_image, dy, 'replicate'),I_dy);
        p_x(:,:,i) = abs(imfilter(blur_image, dx, 'replicate'));
        %p_x(:,:,i) = p_x(:,:,i)./sum(sum(p_x(:,:,i)));
        p_y(:,:,i) = abs(imfilter(blur_image, dy, 'replicate'));
        %p_y(:,:,i) = p_y(:,:,i)./sum(sum(p_y(:,:,i)));
        D(:,:,i) = computeD(p_x(:,:,i), p_y(:,:,i), p_x1, p_y1);
    end
    DoF = D(:,:,1) + D(:,:,2) + D(:,:,3);
end
function [ D ] = computeD( p_xk, p_yk, p_x1, p_y1 )
    D = ones(size(p_xk,1),size(p_xk,2));
    %window size
    m = 3;
    n = 3;
    extra_col = (m-1)/2;
    extra_row = (n-1)/2;
    p_xk = mirrorEdge(p_xk,extra_row,extra_col);
    p_yk = mirrorEdge(p_yk,extra_row,extra_col);
    for i = 1+extra_col:size(p_xk,1)-extra_col
        for j = 1+extra_row:size(p_xk,2)-extra_row
            M = (1:m)+i-2;
            N = (1:n)+j-2;
            D(i-extra_col,j-extra_row) = sum(sum(computeKL(p_xk,p_x1, M,N))) + ...
                sum(sum(computeKL(p_yk,p_y1,M,N)));
        end
    end
end

function [ KL ] = computeKL(p, q, M, N)
    KL = ones(length(M),length(N));
    for i = 1:length(M)
        for j = 1:length(N)
            m = M(i);
            n = N(j);
            if p(m,n) <= 0 || q(m,n) <= 0
                KL(i,j) = 0;
            else
                KL(i,j) = p(m,n)*log(p(m,n)/q(m,n));
            end
        end
    end         
end

function [output] = mirrorEdge(input,extra_row,extra_col)
    input = [repmat(input(:,1),1,extra_col),input];
    input = [input,repmat(input(:,size(input,2)),1,extra_col)];
    input = [repmat(input(1,:),extra_row,1);input];
    input = [input;repmat(input(size(input,1),:),extra_row,1)];
    output = input;
end

function [output] = getHistMap(f,I)
    f = round(f.*255);
    bins = max(size(I));
    [N,edges] = histcounts(f,bins);
    N = N./sum(N);
    g = round(I.*255)+abs(edges(1));
    g = g - min(g(:));
    output = N(g);
end