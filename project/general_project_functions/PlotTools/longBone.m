function cyl = longBone(inferiorPoint,superiorPoint,radius,color)

center = mean([superiorPoint inferiorPoint],2);
axis = normalize(superiorPoint - inferiorPoint);
n = normalize(cross([0 0 1]',axis));
angle = acosd(dot(axis,[0 0 1]'));
[x,y,z] = cylinder(radius);
z = z * vecnorm(superiorPoint - inferiorPoint);
cyl = surf(x,y,z,'EdgeColor','none','FaceColor',color);
rotate(cyl,n,angle)
cyl.XData = cyl.XData + center(1) - mean(mean(cyl.XData));
cyl.YData = cyl.YData + center(2) - mean(mean(cyl.YData));
cyl.ZData = cyl.ZData + center(3) - mean(mean(cyl.ZData));
[x,y,z] = ellipsoid(superiorPoint(1),superiorPoint(2),superiorPoint(3),radius,radius,radius);
surf(x,y,z,'EdgeColor','none','FaceColor',color);
[x,y,z] = ellipsoid(inferiorPoint(1),inferiorPoint(2),inferiorPoint(3),radius,radius,radius);
surf(x,y,z,'EdgeColor','none','FaceColor',color);

end