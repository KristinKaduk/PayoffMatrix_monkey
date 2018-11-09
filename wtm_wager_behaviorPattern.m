clc; clear all; 
cd Y:\Projects\Wagering_monkey\Program\payoff-Matrix
%% Measurable | imposed by experimenter: 
Perf        = 1;
N_trials    = 100;
% defined in ml & time
PayOff =	[0  2  5; % correct
            3  1  -20]; % incorrect
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
%% expected Value for each Wager
EVw_RW = Perf*PayOff_RW(1,:) + (1-Perf)*PayOff_RW(2,:); % EV per wager given the performance


%% How to estimate this coefficients?
R = [1, 1.5, 1.5]; %gains
T = [1, 1, 0.5];
% risk seeking
S = 0.9  ;
PayOff_RW(2,3)= -155;
Utility_PayOff = wtm_utility( PayOff_RW,[R(3),T(3),S] );

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


Utility_PayOff = wtm_utility( PayOff_RW,[R(1),T,S] );

EVw = Perf*Utility_PayOff(1,:) + (1-Perf)*Utility_PayOff(2,:); % EV per wager given the performance

%% Optimization: max(Reward) & min(Costs) -> utility
%% different behavior strategies & their principles
Allbehavioral_pattern = {...
    'random_uniform_wagering',...
    'NoMetacognition',...
    'UncertainOption',...
    'Certainty_Correct', ...
    'bidirectionalMetacognition',...
    
    };
%% Create all possible combination related to one behavior strategy
step         = 0.1;
options      = 0:step:1;
Combinations = CombVec(options, options, options);
ind = 1: length(Combinations(1,:));
BigTable = [];
for i_behaviors = 1:size(Allbehavioral_pattern,2)
    
    behavioral_pattern = Allbehavioral_pattern{i_behaviors};
    wagerProportions_correct = []; wagerProportions_wrong= []; wager_proportions= [];
    switch behavioral_pattern
        case 'random_uniform_wagering'
            wagerProportions_correct = [0.33; 0.33; 0.33];
            wagerProportions_wrong   = [0.33; 0.33; 0.33];
        case 'NoMetacognition'
            wagerProportions_correct = Combinations(:,sum(Combinations(:,ind))==1);
            wagerProportions_wrong = wagerProportions_correct;
        case 'UncertainOption'
            wagerProportions_correct = [0; 1; 0];
            wagerProportions_wrong   = [0; 1; 0];
        case 'Certainty_Correct'
            wager_proportions = Combinations(:,sum(Combinations(:,ind))==1);
            wagerProportions_correct       = wager_proportions(:,wager_proportions(1,:) <wager_proportions(2,:) & wager_proportions(2,:) <wager_proportions(3,:));
            wagerProportions_correctExtra  = wager_proportions(:,wager_proportions(1,:) == wager_proportions(2,:) & wager_proportions(2,:) <wager_proportions(3,:));
            wagerProportions_correctExtra2 = wager_proportions(:,wager_proportions(1,:) < wager_proportions(2,:) & wager_proportions(2,:) == wager_proportions(3,:));
            wagerProportions_correct       = [wagerProportions_correct, wagerProportions_correctExtra,wagerProportions_correctExtra2];
            wagerProportions_wrong         = repmat([0.33; 0.33; 0.33], 1, length( wagerProportions_correct(1,:)));
        case 'bidirectionalMetacognition'
            %Problem: contaminated with risk seeking ... because that are
            %all possibilities
            wager_proportions = Combinations(:,sum(Combinations(:,ind))==1);
            % w1< w2< w3; !!! add Specialfall: w1=w2< w3
            wagerProportions_correct      = wager_proportions(:,wager_proportions(1,:) <wager_proportions(2,:) & wager_proportions(2,:) <wager_proportions(3,:));
            wagerProportions_correctExtra = wager_proportions(:,wager_proportions(1,:) == wager_proportions(2,:) & wager_proportions(2,:) <wager_proportions(3,:));

            wagerProportions_correct      = [wagerProportions_correct, wagerProportions_correctExtra];
            % w1< w2< w3 !!! add Specialfall: w1>w2= w3
            wagerProportions_wrong      = wager_proportions(:,wager_proportions(1,:) >wager_proportions(2,:) & wager_proportions(2,:) > wager_proportions(3,:));
            wagerProportions_wrongExtra = wager_proportions(:,wager_proportions(1,:) >wager_proportions(2,:) & wager_proportions(2,:) == wager_proportions(3,:));

            wagerProportions_wrong = [wagerProportions_wrong, wagerProportions_wrongExtra];
            % it's possible to have all combination of wagerProportions_wrong & wagerProportions_correct?
            WagerProportion = CombVec(wagerProportions_correct, wagerProportions_wrong); 
            wagerProportions_correct = WagerProportion(1:3,:);
            wagerProportions_wrong   = WagerProportion(4:6,:);
    end
    
    
     for i_combinations = 1:length( wagerProportions_correct(1,:))
    figure(2)
        plot(1:3,wagerProportions_correct(:,i_combinations)','g.-', 'MarkerSize',15); hold on;

    plot(1:3,wagerProportions_wrong(:,i_combinations)','r.-', 'MarkerSize',15); hold on;
set(gca,'ylim',[0 1 ]); set(gca,'Xtick', [1,2,3] )


     end
    Table = [];

    for i_combinations = 1:length( wagerProportions_correct(1,:))
        T = [];
        T.wagerProportions_correct = wagerProportions_correct(:,i_combinations)';
        T.wagerProportions_wrong = wagerProportions_wrong(:,i_combinations)';
        % find the behavior pattern with max(Earning) && min(Time)
        Utility_Outcomes = [
            N_trials*Perf*wagerProportions_correct(:,i_combinations)'.*Utility_PayOff(1,:);
            N_trials*(1-Perf)*wagerProportions_wrong(:,i_combinations)'.*Utility_PayOff(2,:)];
        T.EarningsUtility    = sum(sum(Utility_Outcomes,1));
        
        
        GainOutcomes = [
            N_trials*Perf*wagerProportions_correct(:,i_combinations)'.*Gain_PayOff(1,:);
            N_trials*(1-Perf)*wagerProportions_wrong(:,i_combinations)'.*Gain_PayOff(2,:)];
        T.Gain       = sum(sum(GainOutcomes,1));
        
        
        TimeOutcomes = [
            N_trials*Perf*wagerProportions_correct(:,i_combinations)'.*Time_PayOff(1,:);
            N_trials*(1-Perf)*wagerProportions_wrong(:,i_combinations)'.*Time_PayOff(2,:)];
        T.Time        = sum(sum(TimeOutcomes,1));
        
        
        
    T.payoff_correct        = {num2str(PayOff(1,:))};
	T.payoff_incorrect      = {num2str(PayOff(2,:))};
    T.PayOff_RW_correct        = {num2str(PayOff_RW(1,:))};
	T.PayOff_RW_incorrect      = {num2str(PayOff_RW(2,:))};
    
    T.PayOff_Utility_correct        = {num2str(Utility_PayOff(1,:))};
	T.PayOff_Utility_incorrect      = {num2str(Utility_PayOff(2,:))};
        
        T.behavioral_pattern = {behavioral_pattern};
        T.Nr_BehPattern      = i_combinations;
        Row = struct2table(T);
        Table = [Table; Row];
    end

    Table = sortrows(Table,'EarningsUtility');
    Table.Nr_BehPattern(:) = 1:length(Table.EarningsUtility)';
    BigTable = [BigTable; Table];

end %different behavior pattern

%% graphs
figure(2)
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


ax1 = subplot(4,1,1);
bar(Table.Nr_BehPattern, Table.EarningsUtiity,'k') ;
ylabel('Earnings(utility)','fontsize',15,'fontweight','b' );

ax1 = subplot(4,1,2);
bar(Table.Nr_BehPattern, Table.Gain) ;
ylabel('Gain (ml)','fontsize',15,'fontweight','b' );

ax1 = subplot(4,1,3);
bar(Table.Nr_BehPattern, Table.Time,'k') ;
ylabel('Time(s)','fontsize',15,'fontweight','b' );

ax1 = subplot(4,1,4);
b = bar(Table.wager_proportions, 'Stacked') ;
ylabel('proportion of each wager','fontsize',15,'fontweight','b' );
set(gca, 'box', 'off');
legend(b, {'wager1', 'wager2', 'wager3'})
%color a specific bar
b = bar(1:10,'FaceColor','flat');
b.CData(2,:) = [0 0.8 0.8];
