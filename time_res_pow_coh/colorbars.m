
%plotting a seperate image just for colorbar
zlim = [-40 40];
newstr = num2str(zlim);
strsave = strrep(newstr,'         ',' ');
ax = axes;
c = colorbar(ax);
cm = cbrewer('div','RdBu',80);
% cm = cbrewer('seq','Reds',80);
% colormap(cm);
colormap(flipud(cm));
c.Location = 'West';
hold on
set(c,'Position',[0.3,0.4,0.05,0.375])
set(c,'Position',[0.15,0.1,0.05,0.40])
set(c,'Position',[0.15,0.1,0.04,0.65])

ax.Visible = 'off';
caxis([zlim])

set(gca,'ZTick',[])
ax = gca;
ax.FontSize = 60;
% c.Ticks = [];
% c.TickLabels = {};
set(gcf,'Units','inches','Position',[0, 0, 8.5, 11])
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpdf','-r300',['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_movaligned/colbars/colorbar_',strsave,'.pdf'])
% exportgraphics(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_movaligned/colbars/colorbar_',strsave,'.pdf'],'Resolution', 300')
% print(gcf,'-dpdf','-r300',['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_movaligned/colbars/colorbar_noticks_short_5',strsave,'.pdf'])
% print(gcf,'-dpdf','-r300','-fillpage',['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_movaligned/colbars/colorbar_noticks_short_',strsave,'.pdf'])
% close all

  