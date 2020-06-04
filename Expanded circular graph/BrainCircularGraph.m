function BrainCircularGraph(GCM, GComp, Granularity, Glabels)
%BrainCircularGraph plots a circular graph representation 
%of all model input datasets, including :
%Global white matter connectomics (based on connectivity matrix- GCM N*N matrix)
%Grey matter laminar composition (based on composition matrix per region- GComps N*3 matrix)
%Cortical granularity indices (based on index vector- Granularity N*1 vector)
%Labels per region- Glabels (1*N cell vector)

GComp(isnan(GComp))=0; %remove any NaNs
x=(GCM); 

%plot global white matter connectomics:
figure;
myColorMap=hot(length(x)); %hot colormap

circularGraph2(x,'Colormap',myColorMap,'Label',Glabels);

t = linspace(-pi,pi,length(x) + 1).'; % theta for each node
hold on %figure;
a=-0.027; b=-0.03; %centering
w=0.02; w2=0.1; %size for bars
r1=1.1;

%add to plot grey matter composition bars per region:
for i = 1:length(x)
    h=0;
    if GComp(i,1)~=0 %IG (infragranular components)
        pos = [a+r1*cos(t(i))+h b+r1*sin(t(i)) w w2*GComp(i,1)];
        p=rectangle('Position',pos,'FaceColor',[255 255 0]./255,'EdgeColor',[0.5 0.5 0.5]);%,'Curvature',[1 1])
    end
    h=h+w;

    if GComp(i,2)~=0 %G (granular components)
        pos = [a+r1*cos(t(i))+h b+r1*sin(t(i)) w w2*GComp(i,2)];
        p=rectangle('Position',pos,'FaceColor',[146 208 80]./255,'EdgeColor',[0.5 0.5 0.5]);%,'Curvature',[1 1])
    end
    h=h+w;

    if GComp(i,3)~=0 %SG (supragranular components)
        pos = [a+r1*cos(t(i))+h b+r1*sin(t(i)) w w2*GComp(i,3)];
        p=rectangle('Position',pos,'FaceColor',[0 176 80]./255,'EdgeColor',[0.5 0.5 0.5]);%,'Curvature',[1 1])
    end
end
hold on 

rr=1.15;
grancol=[255 255 0;226 240 217;197 224 180;169 209 142;84 130 53;56 87 35]./255;
%above: colormap for indices (yellow to green scale with increasing
%granular presence)

%add to plot granlaurity indices:
for i = 1:length(x)
    h=0;
    if Granularity(i)~=0 %granularity index
        pos = [a+rr*1.054*cos(t(i)) b+rr*1.054*sin(t(i)) 0.05 0.05];
        rectangle('Position',pos,'FaceColor',grancol(Granularity(i),:),'Curvature',[1 1],'EdgeColor',[0.5 0.5 0.5]);
    end
end
 axis square; grid off       
      
set(gcf,'Color','k')
      
colormap(myColorMap)
colorbar('Ticks',[],'TicksMode','auto',...
'TickLabels',num2str(round(linspace(min(min(x)),max(max(x)),11))'),...
'Color','w','Position',[0.89 0.02 0.02 0.8],'FontSize',10)
   
      

    
end

