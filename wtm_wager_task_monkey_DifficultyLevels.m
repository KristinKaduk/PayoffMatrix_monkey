% Kristin 20180911
% taking into account different perceptual performance related to the difficulty levels
%% 
Perf = [0.47 , 0.65,0.7,0.8,0.97]; 
AvPerf = sum(Perf)/size(Perf,2);
N_trials = 400/length(Perf);

%% payoff matrix
PayOff =	[0  3  5; % correct
		2  1  -4]; % incorrect

PayOff =	[0  0.12  0.3; % correct
          0.18  0.06  -8]; % incorrect
      
%% How to estimate this coefficients?
R = [1, 1.5, 1.5]; %gains
T = [1, 1, 0.5];
% risk seeking
S = 0.9  ;

Coefficient         =   2.25; %equalize utility PayOff_RW2(2,3)= -45;
PayOff_RW2          = wtm_ConvertTimeOut2Reward(PayOff,Coefficient);  
Utility_PayOff      = wtm_utility( PayOff_RW2,[R(3),T(3),S] );
Utility_PayOff      = round2(Utility_PayOff,0.1); 

Gain_PayOff         = PayOff;
Gain_PayOff(Gain_PayOff<0)    = 0;

%TIME/Loss
Time_perTrial                 = 5; %s % each trial has an average time to be completed
Time_PayOff                   = PayOff;
Time_PayOff(1,PayOff(1,:)>= 0)  = Time_perTrial;
Time_PayOff(2,PayOff(2,:)>=0) = Time_perTrial;
Time_PayOff                   = abs( Time_PayOff);

Coefficient     =    0.235;
PayOff_RW       =	 wtm_ConvertTimeOut2Reward(PayOff,Coefficient);
%% different behavior strategies & their principles
Allbehavioral_pattern = {...
    'random_uniform_wagering',...
    'NoMetacognition',...
    'UncertainOption',...
    'Certainty_Correct', ...
    'bidirectionalMetacognition'};

%%% Create all possible combination related to one behavior strategy
step         = 0.25;
options      = 0:step:1;
Combinations = combvec(options, options, options);
wp_c = Combinations(:,sum(Combinations,1)==1);
wp_i = Combinations(:,sum(Combinations,1)==1);
cwp = combvec(wp_c,wp_i)';
N_comb = size(cwp,1);

cwp = reshape(cwp,N_comb,3,2);
ind = 1: length(Combinations(1,:));
BigTable = [];    Table = [];pattern= [];


Table = []; T  = [];Table_Diff = [];EVw_perDiff = repmat(nan, 5, 3); EarningsPerWager_perDiff = repmat(nan, 5, 3);

for i_diff = 1:length(Perf) % difficulty levels
for k = 1:N_comb,
    wc = cwp(k,:,1);
    wi = cwp(k,:,2);
    
    if all(wc == wi),
        pattern{k} = 'no metacognition';
    else
        pattern{k} = 'weird pattern';
        % define two slopes
        slope32_c = wc(3)-wc(2);
        slope32_i = wi(3)-wi(2);
        
        slope21_c = wc(2)-wc(1); % negative means increase towards w1
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
    
    T(i_diff).DifficultyLevel               = i_diff;

    T(i_diff).performance = Perf(i_diff);
    T(i_diff).wagerProportions_correct = wc;
    T(i_diff).wagerProportions_wrong   = wi;
    % find the behavior pattern with max(Earning) && min(Time)
    Utility_Outcomes = [
        N_trials *Perf(i_diff)    *wc     .*Utility_PayOff(1,:);
        N_trials *(1-Perf(i_diff))*wi    .*Utility_PayOff(2,:)];
    T(i_diff).EarningsUtility    = sum(sum(Utility_Outcomes,1));
    
    
    GainOutcomes = [
        N_trials*Perf(i_diff)    *wc     .*Gain_PayOff(1,:);
        N_trials*(1-Perf(i_diff))*wi     .*Gain_PayOff(2,:)];
    T(i_diff).Gain       = sum(sum(GainOutcomes,1));
    
    
    TimeOutcomes = [
        N_trials*Perf(i_diff)        *wc .*Time_PayOff(1,:);
        N_trials*(1-Perf(i_diff) )   *wi .*Time_PayOff(2,:)];
    T(i_diff).Time        = sum(sum(TimeOutcomes,1));
    
    DropsOutcomes = [
        N_trials*Perf(i_diff)        *wc .*PayOff_RW(1,:);
        N_trials*(1-Perf(i_diff) )   *wi .*PayOff_RW(2,:)];
    T(i_diff).EarningsDrops        = sum(sum(DropsOutcomes,1));
    
    T(i_diff).payoff_correct        = {num2str(PayOff(1,:))};
    T(i_diff).payoff_incorrect      = {num2str(PayOff(2,:))};
    T(i_diff).PayOff_RW_correct        = {num2str(PayOff_RW(1,:))};
    T(i_diff).PayOff_RW_incorrect      = {num2str(PayOff_RW(2,:))};
    
    T(i_diff).PayOff_Utility_correct        = {num2str(Utility_PayOff(1,:))};
    T(i_diff).PayOff_Utility_incorrect      = {num2str(Utility_PayOff(2,:))};
    
    T(i_diff).behavioral_pattern = {pattern{k}};
    T(i_diff).Nr_BehPattern      = k;
    Row = struct2table(T);
    Table = [Table; Row];
    
    
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
    
end
end % difficulty levels

%% find a specific behavior pattern
c = 1;
for i = 1: size(Table,1)
if isequal(Table.wagerProportions_correct(i,:),[0 0 1]) &&  isequal(Table.wagerProportions_wrong(i,:),[1 0 0])
 idx(c) = i  ;
 c = c+1;
end
end

Tab = Table(idx,:);
sum(Tab.EarningsDrops)    
sum(Tab.EarningsUtility)    
sum(Tab.Gain) %106.46
sum(Tab.Time) %2000s
Tab.Nr_BehPattern

    %%
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
