function [] = simGif(model,body,filename,rate,istart,iend,options)

for n = istart:iend
    if nargin == 7
        fig = plotBody(model,body,n,options);
    else
        fig = plotBody(model,body,n);
    end
    drawnow 
      % Capture the plot as an image 
      frame = getframe(fig); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256); 
      % Write to the GIF File 
      if n == istart
          imwrite(imind,cm,filename,'gif','DelayTime',rate,'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','DelayTime',rate,'WriteMode','append'); 
      end 
      close all
end
end