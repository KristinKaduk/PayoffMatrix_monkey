clc; clear all;
cd Y:\Projects\Wagering_monkey\Program\PayoffMatrix_monkey
Plotting =0;
%% Measurable | imposed by experimenter:
Perf        = 0.75;
N_trials    = 100;
% defined in ml & time
PayOff =	[0  2  5; % correct
            3  1  -20]; % incorrect
PayOff_RW_Time =	[0/0.1  0.2/0.1  0.5/0.1; % correct
                    0.3/0.1  0.1/0.1  0.001/10]; % incorrect
%         PayOff =	[0  0.2  0.5; % correct
%             0.3  0.1  -15]; % incorrect
%% transformation of the payoff-matrix
%GAIN
Gain_PayOff                   = PayOff;
Gain_PayOff(Gain_PayOff<0)    = 0;
%TIME/Loss
Time_perTrial                 = 5; %s % each trial has an average time to be completed
Time_PayOff                   = PayOff;
Time_PayOff(1,PayOff(1,:)>= 0)  = Time_perTrial;
Time_PayOff(2,PayOff(2,:)>=0) = Time_perTrial;
Time_PayOff                   = abs( Time_PayOff);

% convertion from Time into units of Reward to calculate Utility
% IK: better to convert before the Power-function
% ex. 1Rw -> 5s;
% !!
Coefficient     =    0.235;
PayOff_RW       =	 wtm_ConvertTimeOut2Reward(PayOff,Coefficient);

%% How to estimate this coefficients?
R = [1, 1.5, 1.5]; %gains
T = [1, 1, 0.5];
% risk seeking
S = 0.9  ;

Coefficient    =   2.25; %equalize utility PayOff_RW2(2,3)= -45;
PayOff_RW2     = wtm_ConvertTimeOut2Reward(PayOff,Coefficient);  
Utility_PayOff = wtm_utility( PayOff_RW2,[R(3),T(3),S] );
Utility_PayOff = round2(Utility_PayOff,0.1); 

if Plotting
    for indR = 1: 3 %length(R)
        Utility_PayOff = wtm_utility( PayOff_RW,[R(indR),T(indR),S] );
        % plot a utility function from -10 to 10  & mark the points of the
        % PayoffMatrix
        figure(1)
        Value = -8:0.1:8;
        utility = wtm_utility( Value,[R(indR),T(indR),S] );
        plot(real(Value),utility,'k.-', 'MarkerSize',10); hold on;
        plot(real(PayOff_RW),real(Utility_PayOff),'b.', 'MarkerSize',25); hold on;
        line( [ min(Value) max(Value)],[0 0],'Color','black','LineStyle','--')
        line( [0 0],[min(utility)  max(utility)],'Color','black','LineStyle','--')
        title('Utility function with defined parameters: R, S & T')
        ylabel('utility','fontsize',20,'fontweight','b' );
        xlabel('value','fontsize',20,'fontweight','b' );
    end
    text(min(Value)+1,max(Value)-2,['R = ',num2str(R(indR)) ])
    text(min(Value)+1,max(Value)-4,['T = ',num2str(T(indR)) ])
    text(min(Value)+1,max(Value)-6,['S = ',num2str(S) ])
end


%% expected Value for each Wager
EVw_RW = Perf*PayOff_RW(1,:) + (1-Perf)*PayOff_RW(2,:); % EV per wager given the performance
EVw = Perf*Utility_PayOff(1,:) + (1-Perf)*Utility_PayOff(2,:); % EV per wager given the performance
%% Optimize payoff matrix
% Can I improve the payoff-matrix that there are more benefist to behavior in a bidirectional manner?
%1. approach: 
% all possible payoff matrixes in a step wise manner
% -> find the payoff matrix with the highest gain (2nd step: and less time)
% 2. approach
% possible payoff-matrix combinations based on principles
% the pattern with the highest earning 
% set pinciples for the payoff matrix



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
    
    T.payoff_correct        = {num2str(PayOff(1,:))};
    T.payoff_incorrect      = {num2str(PayOff(2,:))};
    T.PayOff_RW_correct        = {num2str(PayOff_RW(1,:))};
    T.PayOff_RW_incorrect      = {num2str(PayOff_RW(2,:))};
    T.PayOff_Utility_correct        = {num2str(Utility_PayOff(1,:))};
    T.PayOff_Utility_incorrect      = {num2str(Utility_PayOff(2,:))};
    
    T.behavioral_pattern = {Out.pattern{i_pattern}};
    T.Nr_BehPattern      = i_pattern;
    Row = struct2table(T);
    Table = [Table; Row];
    
    
end


%Table = sortrows(Table,'EarningsUtility');
%Table = sortrows(Table,'behavioral_pattern');
Table = sortrows(Table,{'behavioral_pattern', 'EarningsUtility'});
Table.Nr_BehPattern(:) = 1:length(Table.EarningsUtility)';



