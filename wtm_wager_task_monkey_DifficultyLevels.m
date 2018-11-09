% wtm_wager_task_monkey

% 3 wagers, 1 difficulty level
% payoff matrix
% constructed after 4 Principles
% 1. Higher than chance performance should be rewarded
% 2. Detection of correct and incorrect decisions should be rewarded
% -> Difference in proportion of using 3 wagers for correct vs. incorrect trials
% 3. Non-discriminative risky behavior will be counteracted by a long timeout
% 4. Difference between I don't know and I made an error (for not rational subjects which are influenced by loss aversion)

perf = [ 0.97, 0.8, 0.7, 0.65, 0.47];
AvPerf = sum(perf)/size(perf,2);
N_trials = 400;

% payoff matrix


% EV same for all wagers
% PayOff =	[0  1  4; % correct
% 		0  1  4]; % incorrect

% Balanced
% PayOff =	[0  1  4; % correct
% 		2  1  -2]; % incorrect

% Strong punishment for risky behavior
% PayOff =	[0  1  4; % correct
% 		2  1  -3.9]; % incorrect


% Inverted for correct and incorrect: not good, since there is no effect of performance
% PayOff =	[-3.9  1  4; % correct
% 		4  1  -3.9]; % incorrect

% ...
% PayOff =	[0  1  4; % correct
% 		4  1  -3.9]; % incorrect

% a la Middlebrooks and Sommers 2011, except low wager
% PayOff =	[0  2  4; % correct
% 		2  1  -2]; % incorrect

% Correct > incorrect except low wager
% PayOff =	[0  2  4; % correct
% 		1  0  -3.9]; % incorrect

PayOff =	[0  3  5; % correct
		2  1  -4]; % incorrect

% Expected Values of the Wagers more equal....
PayOff =	[0  2  5; % correct
		2  1  -4]; % incorrect
%
% ml = 0.05;
PayOff =	[0  0.12  0.3; % correct
          0.18  0.06  -8]; % incorrect


% behavioral_pattern in wager_proportions
% What is the percentage a specific wager is choosen?
Allbehavioral_pattern = {...
		'random_uniform_wagering:0.33 0.33 0.33',...
		'moderatelyRisky_NoMetacognition',...
		'absolutelyRisky_NoMetacognition: 0 0 1',...
		'UncertainOption_NoMetacognition: 0 1 0',...
		'Following_Feedback_100',...
		'moderatelyRisky_bidirectionalMetacognition',...
		'notRisky_bidirectionalMetacognition',...
		'Certainty_Correct',...
		'DifficultyLevel',...
		};
Table = []; T  = [];Table_Diff = [];EVw_perDiff = repmat(nan, 5, 3); EarningsPerWager_perDiff = repmat(nan, 5, 3);

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

% How many trials are need to have the same outcome as the strategy with the highest earnings
for I_behaviors = 1:      size(Allbehavioral_pattern,2)
	
	behavioral_pattern = Allbehavioral_pattern{I_behaviors};
	wager_proportions1 = Table.wagerProportions_behavioral_pattern1(I_behaviors,:);
	wager_proportions2 = Table.wagerProportions_behavioral_pattern2(I_behaviors,:);
	
	
	NeedTrials_CompensateNoMetacognition = Table.NrTrials(I_behaviors);
	Earnings = Table.Earnings(I_behaviors);
	while max(Table.Earnings) > Earnings
		NeedTrials_CompensateNoMetacognition = NeedTrials_CompensateNoMetacognition +1;
		Outcomes = [
			NeedTrials_CompensateNoMetacognition.*AvPerf.*wager_proportions1.*PayOff(1,:);
			NeedTrials_CompensateNoMetacognition.*(1-AvPerf).*wager_proportions2.*PayOff(2,:)];
		
		EarningsPerWager = sum(Outcomes,1); % summary earnings of each of 3 wagers, given the performance and each wager frequency
		Earnings = [];
		Earnings = sum(EarningsPerWager);
		Table.NeedTrials_CompensateNoMetacognition(I_behaviors) = NeedTrials_CompensateNoMetacognition;
	end
	Table.NeedTrials_CompensateNoMetacognition(I_behaviors) = Table.NeedTrials_CompensateNoMetacognition(I_behaviors) -100;
end

Table = sortrows(Table,'Earnings');


writetable(Table,'Y:\Projects\Wagering_monkey\Results\PayoffMatrix\Overview_PayOff_Outcomes.xls', 'Sheet',1)
writetable(Table_Diff,'Y:\Projects\Wagering_monkey\Results\PayoffMatrix\Overview_PayOff_Outcomes_DIFFICULTYLEVELS.xls', 'Sheet',1)
