classdef circularGraphCL < handle
% circularGraphCL Plots plots a multilayered circular graph to illustrate 
% cortical laminar connections in a network.
%
%% Syntax
% circularGraphCL(X)
% circularGraphCL(X,'PropertyName',propertyvalue,...)
% h = circularGraphCL(...)
%
%% Description
% A 'circular graph' is a visualization of a network of nodes and their
% connections. The nodes are laid out along a circle, and the connections
% are drawn within the circle. Click on a node to make the connections that
% emanate from it more visible or less visible. 
% A multilayered circular graph includes more than one circle of nodes,
% where each circle is located in a different location in the z axis and 
% all nodes are interconnected. 
%
% Required input arguments.
% X : Ajacency  matrix of numeric or logical values, in the following
% format:
% [IG-IG IG-G IG-SG; 
% G-IG G-G G-SG; 
% SG-IG SG-G SG-SG]
% Where each individual matrix represent layer-to-layer connections, with a
% size of N2 (number of nodes in a single-layered network).
% Overall X size: (3*N2)*(3*N2)
% 
% Optional properties.
% Colormap : A N0 by 3 matrix of [r g b] triples, where No is the 
%            number of nonzero elements in adjacenyMatrix.
% Label    : A cell array of N1 strings, were N1 is the number of nodes (3*N2, 
%            where N2 in the number of nodes in a single-layered network).
%%
% Copyright 2016 The MathWorks, Inc.
  properties
    Node = node2(0,0,0); %Array of nodes with Z dimension
    ColorMap;         % Colormap
    Label;            % Cell array of strings
    ShowButton;       % Turn all nodes on
    HideButton;       % Turn all nodes off
  end
  
  methods
    function this = circularGraphCL(adjacencyMatrix,varargin)
      % Constructor
      p = inputParser;
      
      defaultColorMap = parula(length(adjacencyMatrix));
      defaultLabel = cell(length(adjacencyMatrix));
      for i = 1:length(defaultLabel)
        defaultLabel{i} = num2str(i);
      end
      
      addRequired(p,'adjacencyMatrix',@(x)(isnumeric(x) || islogical(x)));
      addParameter(p,'ColorMap',defaultColorMap)%,@(colormap)length(colormap) == length(adjacencyMatrix));
      addParameter(p,'Label'   ,defaultLabel   ,@iscell);
      
      parse(p,adjacencyMatrix,varargin{:});
      this.ColorMap = p.Results.ColorMap;
      this.Label    = p.Results.Label;
      
      this.ShowButton = uicontrol(...
        'Style','pushbutton',...
        'Position',[0 40 80 40],...
        'String','Show All',...
        'Callback',@circularGraphCL.showNodes,...
        'UserData',this);
      
      this.HideButton = uicontrol(...
        'Style','pushbutton',...
        'Position',[0 0 80 40],...
        'String','Hide All',...
        'Callback',@LaminarCircos.hideNodes,...
        'UserData',this);
      
      fig = gcf;
      set(fig,...
        'UserData',this,...
        'CloseRequestFcn',@circularGraphCL.CloseRequestFcn);
      
      % Draw the nodes
      delete(this.Node);
      t = cat(1,linspace(-pi,pi,1+length(adjacencyMatrix)/3).',linspace(-pi,pi,1+length(adjacencyMatrix)/3).',linspace(-pi,pi,1+length(adjacencyMatrix)/3).'); % theta for each node
      extent = zeros(length(adjacencyMatrix),1);

      C1=8; C2=20; C3=32; %NEW
      C123=[C1;C2;C3];

      for i = 1:length(adjacencyMatrix)
          if i<=87
            this.Node(i) = node2(C1.*cos(t(i)),C1.*sin(t(i)),C1); %IG
          elseif i>87 && i<=174
            this.Node(i) = node2(C2.*cos(t(i+1)),C2*sin(t(i+1)),C2); %G
          elseif i>174
            this.Node(i) = node2(C3.*cos(t(i+2)),C3.*sin(t(i+2)),C3); %G
          end

        this.Node(i).Color = this.ColorMap(i,:);
        this.Node(i).Label = this.Label{i};
      end
      
      % Find non-zero values of s and their indices
      [row,col,v] = find(adjacencyMatrix);
      
      % Calculate line widths based on values of s (stored in v).
      minLineWidth  = 0.5;
      lineWidthCoef = 5;
      lineWidthCoef = 2;
      lineWidth = v./max(v);
      lineWidth2 = histeq(lineWidth); %histogram equalization
      if sum(lineWidth) == numel(lineWidth) % all lines are the same width.
        lineWidth = repmat(minLineWidth,numel(lineWidth),1);
      else % lines of variable width.
        lineWidth = lineWidthCoef*lineWidth + minLineWidth;
      end
      
      for i = 1:length(v)
        if row(i) ~= col(i)
            if row(i)<=87 && col(i)<=87                     %IG2IG
                u = [C1.*cos(t(row(i)));C1.*sin(t(row(i)));C1];
                v = [C1.*cos(t(col(i)));C1.*sin(t(col(i)));C1];
            elseif row(i)<=87 && (col(i)>87 && col(i)<=174)  %IG2G
                u = [C1.*cos(t(row(i)));C1.*sin(t(row(i)));C1];
                v = [C2.*cos(t(col(i)));C2.*sin(t(col(i)));C2];
            elseif row(i)<=87 && col(i)>174                  %IG2SG
                u = [C1.*cos(t(row(i)));C1.*sin(t(row(i)));C1];
                v = [C3.*cos(t(col(i)));C3.*sin(t(col(i)));C3];
                
            elseif (row(i)>87 && row(i)<=174) && col(i)<=87        %G2IG
                u = [C2.*cos(t(row(i)));C2.*sin(t(row(i)));C2];
                v = [C1.*cos(t(col(i)));C1.*sin(t(col(i)));C1];
            elseif (row(i)>87 && row(i)<=174) && (col(i)>87 && col(i)<=174)  %G2G
                u = [C2.*cos(t(row(i)));C2.*sin(t(row(i)));C2];
                v = [C2.*cos(t(col(i)));C2.*sin(t(col(i)));C2];
            elseif row(i)<=87 && col(i)>174                  %G2SG
                u = [C2.*cos(t(row(i)));C2.*sin(t(row(i)));C2];
                v = [C3.*cos(t(col(i)));C3.*sin(t(col(i)));C3];

            elseif row(i)>174 && col(i)<=87            %SG2IG
                u = [C3.*cos(t(row(i)));C3.*sin(t(row(i)));C3];
                v = [C1.*cos(t(col(i)));C1.*sin(t(col(i)));C1];
            elseif row(i)>174 && (col(i)>87 && col(i)<=174)  %SG2G
                u = [C3.*cos(t(row(i)));C3.*sin(t(row(i)));C3];
                v = [C2.*cos(t(col(i)));C2.*sin(t(col(i)));C2];
            elseif row(i)>174 && col(i)>174                  %SG2SG
                u = [C3.*cos(t(row(i)));C3.*sin(t(row(i)));C3];
                v = [C3.*cos(t(col(i)));C3.*sin(t(col(i)));C3];
            end    
            
          if abs(row(i) - col(i)) - length(adjacencyMatrix)/2 == 0 
            % points are diametric, so draw a straight line
            
                
            %u = [cos(t(row(i)));sin(t(row(i)))];
            %v = [cos(t(col(i)));sin(t(col(i)))];
            this.Node(row(i)).Connection(end+1) = line(...
              [u(1);v(1)],...
              [u(2);v(2)],...
              [u(3);v(3)],...
              'LineWidth', lineWidth(i),...
              'Color', this.ColorMap(i,:));%ceil(lineWidth2(i)*length(adjacencyMatrix)),:)); %this.ColorMap(row(i),:),...
              %'PickableParts','none');
          else % points are not diametric, so draw an arc
%             u  = [cos(t(row(i)));sin(t(row(i)))];
%             v  = [cos(t(col(i)));sin(t(col(i)))];
            x0 = -(u(2)-v(2))/(u(1)*v(2)-u(2)*v(1));
            y0 =  (u(1)-v(1))/(u(1)*v(2)-u(2)*v(1));
            r  = sqrt(x0^2 + y0^2 - 1);
            thetaLim(1) = atan2(u(2)-y0,u(1)-x0);
            thetaLim(2) = atan2(v(2)-y0,v(1)-x0);
            
            if u(1) >= 0 && v(1) >= 0 
              % ensure the arc is within the unit disk
              theta = [linspace(max(thetaLim),pi,50),...
                       linspace(-pi,min(thetaLim),50)].';
            else
              theta = linspace(thetaLim(1),thetaLim(2)).';
            end
         
            this.Node(row(i)).Connection(end+1) = line(...
              [u(1);v(1)],...
              [u(2);v(2)],...
              [u(3);v(3)],...
              'LineWidth', lineWidth(i),...
              'Color', this.ColorMap(i,:)); 
          
          end
        end
      end
      
      axis image;
      ax = gca;
      for i = 1:length(adjacencyMatrix)
        extent(i) = this.Node(i).Extent;
      end
      extent = max(extent(:));
      ax.XLim = ax.XLim + extent*[-1 1];
      fudgeFactor =0.3;%0.2;% 1.75; % Not sure why this is necessary. Eyeballed it.
      ax.YLim = ax.YLim + fudgeFactor*extent*[-1 1];
      ax.Visible = 'off';
      ax.SortMethod = 'depth';
      
      fig = gcf;
      fig.Color = [1 1 1];
      
      set(gcf,'Color','k')
      view(0,50) %side tilted
      set(gcf,'Color','k')
      rotate3d on
    end
    
  end
  
  methods (Static = true)
    function showNodes(this,~)
      % Callback for 'Show All' button
      n = this.UserData.Node;
      for i = 1:length(n)
        n(i).Visible = true;
      end
    end
    
    function hideNodes(this,~)
      % Callback for 'Hide All' button
      n = this.UserData.Node;
      for i = 1:length(n)
        n(i).Visible = false;
      end
    end
    
    function CloseRequestFcn(this,~)
      % Callback for figure CloseRequestFcn
      c = this.UserData;
      for i = 1:length(c.Node)
        delete(c.Node(i));
      end
      delete(gcf);
    end
    
  end
  
end