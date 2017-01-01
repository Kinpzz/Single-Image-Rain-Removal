function [lf_enhanced, dof] = lf_process(input, lf, t)
    dof = computeDoF(input);
    d = rescale(abs(dof));
    d((d < t)==1) = 0;
    lf_enhanced(:,:,1) = d.*input(:,:,1) + (-d+1).*lf(:,:,1);
    lf_enhanced(:,:,2) = d.*input(:,:,2) + (-d+1).*lf(:,:,2);
    lf_enhanced(:,:,3) = d.*input(:,:,3) + (-d+1).*lf(:,:,3);
end
