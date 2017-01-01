function test(testcase)
%testcase = 1;
% house [3 15] 0.1 0.001 0.0001 d<0.2
% woman [10 15] 0.2 0.001 0.001 d<0.1
if testcase == 'house'
    input = im2double(imread('test_images/house.png'));
    w = [3 15];
    e1 = 0.1;
    e2 = 0.001;
    e3 = 0.0001;
    DoF_t = 0.2;
else
    if testcase == 'woman'
        input = im2double(imread('test_images/woman.jpg'));
        w = [10 15];
        e1 = 0.2;
        e2 = 0.001;
        e3 = 0.001;
        DoF_t = 0.1;
    else
        error('no testcase %d', testcase);
    end
end

% first guided filter
I_LF = imguidedfilter(input,'NeighborhoodSize',w,'DegreeOfSmoothing',...
    e1);
I_HF = input - I_LF;
% high frequency process
%I_HF_E = hf_process(I_HF);
I_HF_E = I_HF; % TO SPEED up ignore first

% low frequency process
[I_LF_E,DoF] = lf_process(input, I_LF, DoF_t);
% only for show
newDoF = abs(DoF);
newDoF((newDoF<0.5)==1) = 0;
% edge enhancing using laplacian
I_LF_EDGE = I_LF_E;
laplacian_filter = [1,1,1;1,-8,1;1,1,1];
I_LF_EDGE = I_LF_EDGE + 0.1*imfilter(I_LF_EDGE,laplacian_filter,'replicate');

% second guided filter
I_HF_2 = imguidedfilter(I_HF_E,I_LF_EDGE,'NeighborhoodSize',w,...
    'DegreeOfSmoothing',e2);

% recover image
Ir = I_HF_2 + I_LF_EDGE;

% clear recover image using min
Icr = min(Ir,input);
% weight
b=0.5;
Iref = b*Icr + (1-b)*Ir;
% third guided filter
Irr = imguidedfilter(Icr,Iref,'NeighborhoodSize',w,...
    'DegreeOfSmoothing',e3);

imwrite(im2uint8(I_LF),['output/',testcase,'_lf.tif'],'tif');
imwrite(im2uint8(I_HF),['output/',testcase,'_hf.tif'],'tif');
imwrite(im2uint8(I_LF_EDGE),['output/', testcase, '_lf_e.tif'],'tif');
imwrite(im2uint8(abs(DoF)),['output/', testcase, '_dof.tif'],'tif');
imwrite(im2uint8(newDoF),['output/', testcase, '_dof_t.tif'],'tif');
imwrite(im2uint8(Ir),['output/', testcase, '_recover.tif'],'tif');
imwrite(im2uint8(Icr),['output/', testcase, '_recover_min.tif'],'tif');
imwrite(im2uint8(Irr),['output/', testcase, '_recover_clear.tif'],'tif');
end