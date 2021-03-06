clc; clear all;
cd Y:\Projects\Wagering_monkey\Program\PayoffMatrix_monkey
Plotting =0;
%% Measurable | imposed by experimenter:
Perf        = 0.75;
N_trials    = 100;
% define in drops
PayOff =	[0  2  5; % correct
            3  1  -5]; % incorrect
% defined in ml & time
% PayOff =	[0 0.2  0.5; % correct
%             0.3  0.1  -10]; % incorrect

                
%         PayOff =	[0  0.2  0.5; % correct
%             0.3  0.1  -15]; % incorrect
%% transformation of the payoff-matrix
%GAIN
Gain_PayOff                   = PayOff;
%Gain_PayOff(Gain_PayOff<0)    = 0.001;
%TIME/Loss
Time_perTrial                 = 4; %s % each trial has an average time to be completed
Time_PayOff                   = PayOff;
Time_PayOff(1,PayOff(1,:)>= 0)  = Time_perTrial;
Time_PayOff(2,PayOff(2,:)>=0) = Time_perTrial;
Time_PayOff(2,PayOff(2,:)<0) = abs(Time_PayOff(2,PayOff(2,:)<0)) + Time_perTrial; 
Time_PayOff                   = abs( Time_PayOff);

% Reward/Time
GainByTimePayoff = Gain_PayOff./Time_PayOff; 
%% convertion from Time into units of Reward to calculate Utility
% IK: better to convert before the Power-function
% ex. 1Rw -> 5s;
Coefficient    = 0.235; %equalize %by 30s timeout
PayOff_RW      = wtm_ConvertTimeOut2Reward(PayOff,Coefficient);
Coefficient    = 2.25; %equalize utility PayOff_RW2(2,3)= -45;
PayOff_RW2     = wtm_ConvertTimeOut2Reward(PayOff,Coefficient);  
%% UTILITY FUNCTION ... 
% How to estimate the following coefficients?
R_gain = [1.5]; %gains
R_loss = [0.5];
% risk seeking
S = 0.9  ;

Utility_GainByTimePayoff = wtm_utility( GainByTimePayoff,[R_gain(1),R_loss(1),S] );
Utility_PayOff = wtm_utility( Gain_PayOff,[R_gain(1),R_loss(1),S] );
Utility_PayOff = round2(Utility_PayOff,0.1); 

%% Plot the different Payoff-matrixes on the utility function with the given parameters
if Plotting
        figure(1)
        Value = -6:0.1:6;
        utility = wtm_utility( Value,[R_gain,R_loss,S] );
        plot(real(Value),utility,'k-', 'MarkerSize',10); hold on;
        plot(real(Gain_PayOff),real(Utility_PayOff),'b.', 'MarkerSize',30); hold on;
        
        %plot(real(GainByTimePayoff),real(Utility_GainByTimePayoff),'r.', 'MarkerSize',15); hold on;

        line( [ min(Value) max(Value)],[0 0],'Color','black','LineStyle','--')
        line( [0 0],[min(utility)  max(utility)],'Color','black','LineStyle','--')
        %title('Utility function with defined parameters: R, S & T')
        ylabel('Utility (utils)','fontsize',20,'fontweight','b' );
        xlabel('Reward magnitude (drops)','fontsize',20,'fontweight','b' );
        xt = get(gca, 'XTick');
        set(gca, 'FontSize', 16)
    text(min(Value)+1,max(Value)-1,['R gain = ',num2str(R_gain)])
    text(min(Value)+1,max(Value)-2.5,['R loss = ',num2str(R_loss)])
    text(min(Value)+1,max(Value)-4,['S = ',num2str(S) ])
end


%% expected Value for each Wager
EVw_RW = Perf*PayOff_RW(1,:) + (1-Perf)*PayOff_RW(2,:); % EV per wager given the performance
EVw_GainByTime = Perf*GainByTimePayoff(1,:) + (1-Perf)*GainByTimePayoff(2,:); % EV per wager given the performance
EVw = Perf*Utility_PayOff(1,:) + (1-Perf)*Utility_PayOff(2,:); % EV per wager given the performance

%% Optimization: max(Reward) & min(Costs) -> utility
%% behavior patterns for three wagers  &  principles
% Create all possible behavior pattern for three wagers
% sort the generated wagering patterns based on rules
step = 0.25; 
Out = wtm_BehaviorPattern_3Wagers(step); 
%% Calculate earnings related to the different Units of the payoff-matrix
Table = [];
for i_pattern = 1:Out.nb_wagerPattern,  
    T.wagerProportions_correct = Out.wagerCorrect(i_pattern,:);
    T.wagerProportions_wrong   = Out.wagerIncorrect(i_pattern,:);
    
    % payoff-matrix in utils
    Utility_Outcomes = [
        N_trials*Perf    *Out.wagerCorrect(i_pattern,:)     .*Utility_PayOff(1,:);
        N_trials*(1-Perf)*Out.wagerIncorrect(i_pattern,:)     .*Utility_PayOff(2,:)];
    T.EarningsUtility    = sum(sum(Utility_Outcomes,1));
    
    % payoff-matrix in ml
    GainOutcomes = [
        N_trials*Perf    *Out.wagerCorrect(i_pattern,:)     .*Gain_PayOff(1,:);
        N_trials*(1-Perf)*Out.wagerIncorrect(i_pattern,:)     .*Gain_PayOff(2,:)];
    T.Gain       = sum(sum(GainOutcomes,1));
    
    % payoff-matrix in seconds
    TimeOutcomes = [
        N_trials*Perf       *Out.wagerCorrect(i_pattern,:) .*Time_PayOff(1,:);
        N_trials*(1-Perf)   *Out.wagerIncorrect(i_pattern,:) .*Time_PayOff(2,:)];
    T.Time        = sum(sum(TimeOutcomes,1));
    
    % payoff-matrix in drops
    DropsOutcomes = [
        N_trials*Perf       *Out.wagerCorrect(i_pattern,:) .*PayOff_RW(1,:);
        N_trials*(1-Perf)   *Out.wagerIncorrect(i_pattern,:) .*PayOff_RW(2,:)];
    T.EarningsDrops        = sum(sum(DropsOutcomes,1));
    
    
    T.payoff_correct                = {num2str(PayOff(1,:))};
    T.payoff_incorrect              = {num2str(PayOff(2,:))};
    T.PayOff_RW_correct             = {num2str(PayOff_RW(1,:))};
    T.PayOff_RW_incorrect           = {num2str(PayOff_RW(2,:))};
    T.PayOff_Utility_correct        = {num2str(Utility_PayOff(1,:))};
    T.PayOff_Utility_incorrect      = {num2str(Utility_PayOff(2,:))};
    
    
    %% meta-D calculations
    % !!! Download FUNCTION type2_SDT_SSE 
    %n_wagers*2 values in a vector -> 
    % ordered... nR_S1(correct, incorrect) && nR_S2(incorrect, correct) 
    % highest conf "S1" ... lowest conf "S1", lowest conf "S2", ... highest conf "S2"
    % original order 1 2 3
    nR_S1    = [flip(T.wagerProportions_correct), T.wagerProportions_wrong]*(N_trials*Perf); % highest conf "S1" ... lowest conf "S1"
    nR_S2    = [flip(T.wagerProportions_wrong),T.wagerProportions_correct]*(N_trials*(1-Perf)); %lowest conf "S2", ... highest conf "S2"
    
    out      = type2_SDT_SSE(nR_S1, nR_S2);
    T.metaD  = out.meta_da ; 
    T.Dprime = out.da ; 
    
    %%
    T.PatternKategoryNr = Out.PatternKategoryNr(i_pattern);

    T.behavioral_pattern = {Out.pattern{i_pattern}};
    T.Nr_BehPattern      = i_pattern;
    Row = struct2table(T);
    Table = [Table; Row];
    
    
end

%% save Table
writetable(Table,'Y:\Projects\Wagering_monkey\Data\PayoffMatrix\Table_BehaviorPattern_Earnings.txt', 'Delimiter', ',')
path_save = 'Y:\Projects\Wagering_monkey\Data\PayoffMatrix\';
cd(path_save)
copyfile('Table_BehaviorPattern_Earnings.txt','Table_BehaviorPattern_Earnings.m');
save([path_save, 'Table_BehaviorPattern_Earnings' ],'Table');

% path_save = 'Y:\Projects\Wagering_monkey\Data\PayoffMatrix\';
% dir(path_save)
% load( [path_save, 'Table_BehaviorPattern_Earnings.m']);
% 
% Data = importdata('Table_BehaviorPattern_Earnings.txt') %loads data into array A.
% filename = 'Table_BehaviorPattern_Earnings.txt';
% delimiterIn = ' ';
% headerlinesIn = 1;
% importdata(filename,delimiterIn,headerlinesIn);

%%
%Table = sortrows(Table,'EarningsUtility');
%Table = sortrows(Table,'behavioral_pattern');
Table = sortrows(Table,{'PatternKategoryNr', 'EarningsUtility'});
Table.Nr_BehPattern(:) = 1:length(Table.EarningsUtility)';


%% find a specific behavior pattern
c = 1;
for i = 1: size(Table,1)
if isequal(Table.wagerProportions_correct(i,:),[0 0 1]) &&  isequal(Table.wagerProportions_wrong(i,:),[1 0 0])
 idx(c) = i  ;
 c = c+1;
end
end




%% 1. What is the optimal wager pattern (max earnings)?
Table(Table.EarningsUtility == max(Table.EarningsUtility),:) % bidrectional certainty - 100% follow the feedback
%% 2. To which wagering category it belong?
Table.behavioral_pattern(Table.EarningsUtility == max(Table.EarningsUtility))
%% 3. Meta-D for the optimal wager pattern given the payoff-matrix
Table.metaD(Table.EarningsUtility == max(Table.EarningsUtility))
max(Table.metaD)
%% 4.%%  What is the optimal wager pattern (max metaD)?
Table(Table.metaD == max(Table.metaD),:) %
%% 3. How different it is from the rest in time, reward, utils?
% Graphs - all possible behavior pattern for the three wager & their earning
figure(2)
bar(Table.Nr_BehPattern, Table.EarningsUtility,'k') ;
ylabel('Earnings(utils)','fontsize',15,'fontweight','b' );
%color a specific bar

figure(3)
title('What is the best behavior pattern?','fontsize',20,'fontweight','b' );
annotation('textbox', [0, 1,0.1,0], 'string', 'PayOff');
annotation('textbox', [0, 0.98,0.1,0], 'string', num2str(PayOff(1,:))) ;
annotation('textbox', [0, 0.95,0.1,0], 'string', num2str(PayOff(2,:)));

annotation('textbox', [0, 0.9,0.1,0], 'string', 'Transformed to Reward-Payoff'); %annotation('textbox',[x y w h]
annotation('textbox', [0, 0.88,0.1,0], 'string', num2str(PayOff_RW(1,:)));
annotation('textbox', [0, 0.85,0.1,0], 'string', num2str(PayOff_RW(2,:)));

annotation('textbox', [0, 0.8,0.1,0], 'string', 'Transformed to Utility-Payoff')
annotation('textbox', [0, 0.78,0.1,0], 'string', num2str(round(Utility_PayOff(1,:),2)));
annotation('textbox', [0, 0.75,0.1,0], 'string', num2str(round(Utility_PayOff(2,:),2)));


ax1 = subplot(3,1,1);
bar(Table.Nr_BehPattern, Table.EarningsUtility,'k') ;
ylabel('Earnings(utils)','fontsize',15,'fontweight','b' );
% categories as x-legend for the wager pattern categories

ax1 = subplot(4,1,2);
bar(Table.Nr_BehPattern, Table.EarningsDrops) ;
ylabel('Earnings(drops)','fontsize',15,'fontweight','b' );

ax1 = subplot(3,1,2);
b = bar(Table.wagerProportions_correct, 'Stacked') ;
ylabel('Nr. of Trials (correct)','fontsize',15,'fontweight','b' );
set(gca, 'box', 'off');
legend(b, {'wager1', 'wager2', 'wager3'})

ax1 = subplot(3,1,3);
b = bar(Table.wagerProportions_wrong, 'Stacked') ;
ylabel('Nr. of Trials (incorrect)','fontsize',15,'fontweight','b' );
set(gca, 'box', 'off');
legend(b, {'wager1', 'wager2', 'wager3'})
%% Graph: show the be.pattern with the highest earnings of each category
% IGORS PLOT!!!


%% Graph: maximum Earnings in utils for the winning be.pattern of each category
WagerCategories = unique(Table.behavioral_pattern); 
Tab = []; 
for ind_WagCat = 1: length(WagerCategories)
Tab.WagCat(ind_WagCat)              = WagerCategories(ind_WagCat); 
Tab.NrPatternsInCategory(ind_WagCat)             = sum(strcmp(Table.behavioral_pattern,  WagerCategories(ind_WagCat))); 
Tab.maxUtilityWagCat(ind_WagCat)    =  max((Table.EarningsUtility(strcmp(Table.behavioral_pattern,  WagerCategories(ind_WagCat))))); 
end

figure(4)
bar(1:length(Tab.maxUtilityWagCat), Tab.maxUtilityWagCat,'k') ;
ylabel('Earnings(utils)','fontsize',15,'fontweight','b' );
set(gca,'XtickLabel', cellstr(Tab.WagCat),'fontsize',10)
set(gca, 'XTickLabelRotation',45)
title(['Performance =', num2str(Perf)])
set(gca, 'TickLabelInterpreter', 'none')
ylim([0, 1200])
%color a specific bar

%% save the figures

%% how much extra time is needed to come to the same amount of earnings as the pattern with max earning
for I_behaviors = 1:size(Allbehavioral_pattern,2)
	behavioral_pattern = Allbehavioral_pattern{8};
	
	behavioral_pattern = Allbehavioral_pattern{I_behaviors};
	switch behavioral_pattern
		
		case 'notRisky_bidirectionalMetacognition'
			wager_proportions = [	0.1 0.3 0.6;
						0.6 0.3 0.1];
		case 'moderatelyRisky_bidirectionalMetacognition'
			wager_proportions = [	0.1 0.2 0.7;
						0.3 0.2 0.5];
		case 'moderatelyRisky_bidirectionalMetacognition'
			wager_proportions = [	0.1 0.2 0.7;
						0.3 0.2 0.5];
		case 'random_uniform_wagering:0.33 0.33 0.33'
			wager_proportions = [	0.33 0.33 0.33;
						0.33 0.33 0.33];
		case 'absolutelyRisky_NoMetacognition: 0 0 1'
			wager_proportions = [	0 0 1;
						0 0 1];
		case 'UncertainOption_NoMetacognition: 0 1 0'
			wager_proportions = [	0 1 0;
						0 1 0];
		case 'Certainty_Correct'
			for i_Diff = 1: size(perf,2)
				
				wager_proportions = [	0 0.2 0.8;
							0 0.5 0.5];
			end
		case 'Certainty_Correct_perf'
			wager_proportions = [	0 (1-AvPerf) AvPerf;
						0 AvPerf (1-AvPerf)/2];
		case 'moderatelyRisky_NoMetacognition'
			wager_proportions = [	0 0.2 0.8;
						0 0.2 0.8];
		case 'Following_Feedback_100'
			wager_proportions = [	0 0 1;
						1 0 0];
			
		case 'DifficultyLevel'
			
		case 'Certainty_Correct'
			for i_Diff = 1: size(perf,2)
				
				wager_proportions{i_Diff} = [	0 (1-perf(i_Diff))	perf(i_Diff);
								0 ((1-perf(i_Diff))/2) ((1-perf(i_Diff))/2)];
			end
			
			wager_proportions{1} = [	0 (1-perf) perf;
							0 (1-perf) perf];
			
			
	end
	
	EVw = AvPerf*PayOff(1,:) + (1-AvPerf)*PayOff(2,:); % EV per wager given the performance
	for i_Diff = 1: size(perf,2)
		EVw_perDiff(i_Diff, :) = perf(i_Diff)*PayOff(1,:) + (1- perf(i_Diff))*PayOff(2,:); % EV per wager given the performance
		Outcomes_perDiff = [
			N_trials*perf(i_Diff)*wager_proportions(1,:).*PayOff(1,:);
			N_trials*(1-perf(i_Diff))*wager_proportions(2,:).*PayOff(2,:)];
		EarningsPerWager_perDiff(i_Diff, :) = sum(Outcomes_perDiff,1); % summary earnings of each of 3 wagers, given the performance and each wager frequency
	end
	%
	Outcomes = [
		N_trials*AvPerf*wager_proportions(1,:).*PayOff(1,:)
		N_trials*(1-AvPerf)*wager_proportions(2,:).*PayOff(2,:)];
	
	EarningsPerWager                = sum(Outcomes,1); % summary earnings of each of 3 wagers, given the performance and each wager frequency
	
	Earnings                        = sum(EarningsPerWager);
	TotalEarningsPerWager_perDiff   = sum(EarningsPerWager_perDiff);
	TotalEarnings_perDiff           = sum(sum(EarningsPerWager_perDiff));
	
	% Table
	format short g
	T.Earnings           = Earnings;
	T.behavioral_pattern = {behavioral_pattern};
	T.NrTrials           = N_trials;
	T.NeedTrials_CompensateNoMetacognition           = N_trials;
	T.payoff_correct     = {num2str(PayOff(1,:))};
	T.payoff_incorrect   = {num2str(PayOff(2,:))};
	T.EVw                =  {num2str(EVw)};
	
	T.EarningsPerWager   = {num2str(round(EarningsPerWager,2))};
	T.Perf               = perf;
	T.NrTrials           = N_trials;
	T.wagerProportions_behavioral_pattern1 = wager_proportions(1,:);
	T.wagerProportions_behavioral_pattern2 = wager_proportions(2,:);
	
	Row = struct2table(T);
	Table = [Table; Row];
	
	T_Diff = [];
	
	for i_Diff = 1: size(perf,2)
		% cDiff = 5 +i_Diff;
		cDiff= i_Diff
		T_Diff(cDiff).DifLEvel               = i_Diff;
		T_Diff(cDiff).Perf                   = perf(i_Diff);
		T_Diff(cDiff).behavioral_pattern     = {behavioral_pattern};
		T_Diff(1).Earnings                   = Earnings;
		T_Diff(cDiff).wagerProportions_Correct                = wager_proportions(1,:);
		T_Diff(cDiff).wagerProportions_Incorrect              = wager_proportions(2,:);
		T_Diff(cDiff).EVw_perDiff                =  {num2str(EVw_perDiff(i_Diff, :))}; %!!!
		T_Diff(cDiff).EarningsPerWager_perDiff   = EarningsPerWager_perDiff(i_Diff, :);
		T_Diff(cDiff).EarningsPerWager           = TotalEarningsPerWager_perDiff;
		T_Diff(1).NrTrials                       = N_trials;
		
		T_Diff(cDiff).payoff_correct     = {num2str(PayOff(1,:))};
		T_Diff(cDiff).payoff_incorrect   = {num2str(PayOff(2,:))};
		T_Diff(cDiff).NeedTrials_CompensateNoMetacognition    = N_trials;
	end
	
	T_DiffRow = struct2table(T_Diff);
	Table_Diff = [Table_Diff; T_DiffRow];
	
	% sort the behavioral strategz according to it's Earnings
	
end

