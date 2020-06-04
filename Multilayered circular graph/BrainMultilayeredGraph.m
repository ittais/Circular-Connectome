function BrainMultilayeredGraph(Gadj, Glabels)
%BrainMultilayeredGraph plots a multilayered circular graph representation 
%of our model of coritcal laminar connectivity, based on the following:
%Adjacency matrix representing cortical laminar connectome:
%(N*3)*(N*3) matrix, where first N values in each dimnsions represent IG (infragranular),
%second N values represent G (granular), and third N values represent SG (supragranular).
%In other words, N cortical regions * 3 laminar position in each region. 
%Matrix formed based on standard connectome (WM connectivity), grey matter
%composition, and granular indices- applied according to model described in paper. 

x2=(Gadj); 
[edges1 edges2]=find(x2); %connecting nodes of non-zero edges
myColorMap=zeros(length(edges1),3);

%Create colormap for connections based on connecting laminar groups: 
ADJc=zeros(size(x2)); %matrix for colors

IG2IGc=zeros(87,87)+1; IG2Gc=zeros(87,87)+2; IG2SGc=zeros(87,87)+3;
G2IGc=zeros(87,87)+2; G2Gc=zeros(87,87)+4; G2SGc=zeros(87,87)+5;
SG2IGc=zeros(87,87)+3; SG2Gc=zeros(87,87)+5; SG2SGc=zeros(87,87)+6;

len=87;
ADJc(1:len,1:len)=IG2IGc; ADJc((len+1):len*2,1:len)=G2IGc; ADJc((len*2+1):end,1:len)=SG2IGc;
ADJc(1:len,(len+1):len*2)=IG2Gc; ADJc((len+1):len*2,(len+1):len*2)=G2Gc; ADJc((len*2+1):end,(len+1):len*2)=SG2Gc;
ADJc(1:len,(len*2+1):end)=IG2SGc; ADJc((len+1):len*2,(len*2+1):end)=G2SGc; ADJc((len*2+1):end,(len*2+1):end)=SG2SGc;
jetc=hsv(length(unique(ADJc))); %jet

for i=1:length(edges1)
    myColorMap(i,:)=jetc(ADJc(edges1(i),edges2(i)),:);
end

myLabel2 = cell(length(x2));
for i = 1:length(x2)-87
  myLabel2{i} = " ";
end
for i = length(x2)-86:length(x2)
  myLabel2{i} = Glabels(i);
end

%plot multilayered circulr graph
figure;
circularGraphCL(x2,'Colormap',myColorMap,'Label',myLabel2); 
hold on;

lenlen=1+length(x2)/3;
t = cat(1,linspace(-pi,pi,lenlen).',linspace(-pi,pi,lenlen).',linspace(-pi,pi,lenlen).'); % theta for each node
C1=8; C2=20; C3=32; %heights for IG, G, SG circular graphs
a=-0.027; b=-0.03;

for i = 1:lenlen 
    if i~=87
        scatter3(a+C1*cos(t(i)), b+C1*sin(t(i)), C1, 50,[255 255 0]./255,'filled');
    end
end
hold on
for i=lenlen+1:lenlen*2 
    if i~=87*2+1
        scatter3(a+C2*cos(t(i)), b+C2*sin(t(i)), C2, 50,[146 208 80]./255,'filled');
    end
end
hold on
for i=lenlen*2+2:lenlen*3 
    if i~=87*3+2
        scatter3(a+C3*cos(t(i)), b+C3*sin(t(i)), C3, 50,[0 176 80]./255,'filled');
    end
end

%specific viewpoints: 
view(0,50) %tilted side view
% view(0,90) %top view
% view(90,0) %side view


end

