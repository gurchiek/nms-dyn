function [d1,d2] = fdiffmat(mat,time,npoint)

% time derivative of matrix where third dimension is time (ie each page is
% a different time instant)
% mat - r x c x p matrix
% time - time array
% npoint - 3 or 5 (see fdiff)

mat = permute(mat,[1 3 2]);
[nrow,ncol,npag] = size(mat);
d1 = zeros(nrow,ncol,npag);
d2 = d1;
for k = 1:npag; [d1(:,:,k),d2(:,:,k)] = fdiff(mat(:,:,k),time,npoint); end
d1 = permute(d1,[1 3 2]);
d2 = permute(d2,[1 3 2]);

end