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
step = 0.25; 
wtm_BehaviorWagerPattern(step)

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
