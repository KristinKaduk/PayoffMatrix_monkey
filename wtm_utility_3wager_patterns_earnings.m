% function wtm_utility_3wager_patterns
%%
%create and visualize behavior patterns to wager
% calculate their earnings in utils with the 
 %given payoff matrix
 %performance
 %number of trials

%% create all possible behavior patterns to wager using a step size
step = 0.25;
wp  = ig_nchoosek_with_rep_perm([0:step:1],3);
wp = wp(sum(wp,2)==1,:);

n_wp = size(wp,1);

wp_c = wp;
wp_i = wp;

cwp = combvec(wp_c',wp_i')';

N_comb = size(cwp,1);

cwp = reshape(cwp,N_comb,3,2);

% plotting properties
map_c = summer(N_comb);
map_i = cool(N_comb);

map_c = repmat([0 1 0],N_comb,1);
map_i = repmat([1 0 0],N_comb,1);



%% exclude the behavior pattern according to specified assumptions
for k = 1:N_comb,
	% 	plot([1 2 3],squeeze(cwp(k,:,1)) + rand(1,3)/10,'Color',map_c(k,:),'LineWidth',0.25); hold on;
	% 	plot([1 2 3],squeeze(cwp(k,:,2)) + rand(1,3)/10,'Color',map_i(k,:),'LineWidth',0.25); hold on;
	
	wc = cwp(k,:,1);
	wi = cwp(k,:,2);
	
	if all(wc == wi),
		pattern{k} = 'no metacognition';
	else
		pattern{k} = 'weird pattern';
		% define two slopes
		slope32_c = wc(3)-wc(2);
		slope32_i = wi(3)-wi(2);
		
		slope21_c = wc(2)-wc(1);
		slope21_i = wi(2)-wi(1);
		
		CertCor = 0;
		CertInc = 0;
		
		if wc(3)>wi(3) && slope32_c>slope32_i
			CertCor = 1;
			pattern{k} = 'certainty correct';
		end
		
		if wc(1)<wi(1) && slope21_c>slope21_i
			CertInc = 1;
			pattern{k} = 'certainty incorrect';
		end
		
		if CertCor && CertInc
			pattern{k} = 'bidirectional certainty';
		end
			
		
	end
	
	switch pattern{k}
		
		case 'certainty correct'
			fignum = 1;
		case 'certainty incorrect'
			fignum = 2;
		case 'bidirectional certainty'
			fignum = 3;
		case 'weird pattern'
			fignum = 4;
		case 'no metacognition'
			fignum = 5;
			
	end
	
% 	figure(fignum);
% 	set(gcf,'Name',pattern{k});
% 	plot([1 2 3],squeeze(cwp(k,:,1)) + rand(1,3)/10,'Color',map_c(k,:),'LineWidth',0.25); hold on;
% 	plot([1 2 3],squeeze(cwp(k,:,2)) + rand(1,3)/10,'Color',map_i(k,:),'LineWidth',0.25); hold on;
	
end

N(1) =  sum(strcmp(pattern,'certainty correct'));
N(2) =  sum(strcmp(pattern,'certainty incorrect'));
N(3) =  sum(strcmp(pattern,'bidirectional certainty'));
N(4) =  sum(strcmp(pattern,'weird pattern'));
N(5) =  sum(strcmp(pattern,'no metacognition'));

idx_patterns = zeros(1,5);

%% 
perf = 0.9;
PayOff = round2(wtm_utility([0 2 5; 3 1 -45],[1.5,0.5,0.9]),0.1); %
N_trials = 100;
E(5).earnings = [];
E(5).k  = [];

for k = 1:N_comb,
	switch pattern{k}
		
		case 'certainty correct'
			fignum = 1;
		case 'certainty incorrect'
			fignum = 2;
		case 'bidirectional certainty'
			fignum = 3;
		case 'weird pattern'
			fignum = 4;
		case 'no metacognition'
			fignum = 5;
			
	end
	
	idx_patterns(fignum) = idx_patterns(fignum) + 1;
% 	
% 	figure(fignum);
% 	set(gcf,'Name',[pattern{k} sprintf(' %d patterns',N(fignum))]);
% 	subplot(ceil(N(fignum)/5),5,idx_patterns(fignum));
% 	plot([1 2 3],squeeze(cwp(k,:,1)) + rand(1,3)/10,'Color',map_c(k,:),'LineWidth',0.25); hold on;
% 	plot([1 2 3],squeeze(cwp(k,:,2)) + rand(1,3)/10,'Color',map_i(k,:),'LineWidth',0.25); hold on;

	
	
	%--
	wager_proportions = squeeze(cwp(k,:,:))';
	EVw = perf*PayOff(1,:) + (1-perf)*PayOff(2,:); % EV per wager given the performance

	% 
	Outcomes = [
		N_trials*perf*wager_proportions(1,:).*PayOff(1,:);
		N_trials*(1-perf)*wager_proportions(2,:).*PayOff(2,:)];

	EarningsPerWager = sum(Outcomes,1); % summary earnings of each of 3 wagers, given the performance and each wager frequency

	E(fignum).earnings(idx_patterns(fignum)) = sum(EarningsPerWager);
	E(fignum).k(idx_patterns(fignum)) = k;


end
	
figure('Name',sprintf('performance %.2f',perf),'Color',[1 1 1],'Position',[100 100 1400 260]);
for f = 1:5,
	subplot(1,5,f)
	idx_within_category = find(E(f).earnings == max(E(f).earnings));
	k = E(f).k(idx_within_category);
	disp(pattern{k});
	squeeze(cwp ( k, :, :))'
	disp(' ');
	
	plot([1 2 3],squeeze(cwp(k,:,1)),'Color',map_c(k,:),'LineWidth',2,'MarkerSize',40'); hold on;
	plot([1 2 3],squeeze(cwp(k,:,2)),'Color',map_i(k,:),'LineWidth',2,'MarkerSize',40'); hold on;
	title(sprintf('%s earnings %d',pattern{k},round(E(f).earnings(idx_within_category))));
	set(gca,'xtick',[1 2 3]);set(gca,'ylim',[0 1 ]);

end