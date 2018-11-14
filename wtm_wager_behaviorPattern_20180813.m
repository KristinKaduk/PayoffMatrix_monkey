clc; clear all;
cd Y:\Projects\Wagering_monkey\Program\payoff-Matrix
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
%% expected Value for each Wager
EVw_RW = Perf*PayOff_RW(1,:) + (1-Perf)*PayOff_RW(2,:); % EV per wager given the performance


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

%Utility_PayOff = wtm_utility( PayOff_RW2,[R(3),T(3),S] );
%Utility_PayOff = round(Utility_PayOff,1); 

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
step         = 0.25;
options      = 0:step:1;
Combinations = CombVec(options, options, options);
wp_c = Combinations(:,sum(Combinations,1)==1);
wp_i = Combinations(:,sum(Combinations,1)==1);
cwp = CombVec(wp_c,wp_i)';
N_comb = size(cwp,1);

cwp = reshape(cwp,N_comb,3,2);
ind = 1: length(Combinations(1,:));
BigTable = [];    Table = [];pattern= [];

%% sort the generated wagering patterns based on rules
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
    
    
    
    T.wagerProportions_correct = wc;
    T.wagerProportions_wrong   = wi;
    % find the behavior pattern with max(Earning) && min(Time)
    Utility_Outcomes = [
        N_trials*Perf    *wc     .*Utility_PayOff(1,:);
        N_trials*(1-Perf)*wi     .*Utility_PayOff(2,:)];
    T.EarningsUtility    = sum(sum(Utility_Outcomes,1));
    
    
    GainOutcomes = [
        N_trials*Perf    *wc     .*Gain_PayOff(1,:);
        N_trials*(1-Perf)*wi     .*Gain_PayOff(2,:)];
    T.Gain       = sum(sum(GainOutcomes,1));
    
    
    TimeOutcomes = [
        N_trials*Perf       *wc .*Time_PayOff(1,:);
        N_trials*(1-Perf)   *wi .*Time_PayOff(2,:)];
    T.Time        = sum(sum(TimeOutcomes,1));
    
    DropsOutcomes = [
        N_trials*Perf       *wc .*PayOff_RW(1,:);
        N_trials*(1-Perf)   *wi .*PayOff_RW(2,:)];
    T.EarningsDrops        = sum(sum(DropsOutcomes,1));
    
    T.payoff_correct        = {num2str(PayOff(1,:))};
    T.payoff_incorrect      = {num2str(PayOff(2,:))};
    T.PayOff_RW_correct        = {num2str(PayOff_RW(1,:))};
    T.PayOff_RW_incorrect      = {num2str(PayOff_RW(2,:))};
    
    T.PayOff_Utility_correct        = {num2str(Utility_PayOff(1,:))};
    T.PayOff_Utility_incorrect      = {num2str(Utility_PayOff(2,:))};
    
    T.behavioral_pattern = {pattern{k}};
    T.Nr_BehPattern      = k;
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

%Table = sortrows(Table,'EarningsUtility');
%Table = sortrows(Table,'behavioral_pattern');
Table = sortrows(Table,{'behavioral_pattern', 'EarningsUtility'});

Table.Nr_BehPattern(:) = 1:length(Table.EarningsUtility)';


%% graphs
% figure(2)
% title('What is the best behavior pattern?','fontsize',20,'fontweight','b' );
% annotation('textbox', [0, 1,0.1,0], 'string', 'PayOff');
% annotation('textbox', [0, 0.98,0.1,0], 'string', num2str(PayOff(1,:))) ;
% annotation('textbox', [0, 0.95,0.1,0], 'string', num2str(PayOff(2,:)));
% 
% annotation('textbox', [0, 0.9,0.1,0], 'string', 'Transformed to Reward-Payoff'); %annotation('textbox',[x y w h]
% annotation('textbox', [0, 0.88,0.1,0], 'string', num2str(PayOff_RW(1,:)));
% annotation('textbox', [0, 0.85,0.1,0], 'string', num2str(PayOff_RW(2,:)));
% 
% annotation('textbox', [0, 0.8,0.1,0], 'string', 'Transformed to Utility-Payoff')
% annotation('textbox', [0, 0.78,0.1,0], 'string', num2str(round(Utility_PayOff(1,:),2)));
% annotation('textbox', [0, 0.75,0.1,0], 'string', num2str(round(Utility_PayOff(2,:),2)));
% 
% 
% ax1 = subplot(3,1,1);
% bar(Table.Nr_BehPattern, Table.EarningsUtility,'k') ;
% ylabel('Earnings(utils)','fontsize',15,'fontweight','b' );
% % categories as x-legend for the wager pattern categories
% 
% ax1 = subplot(4,1,2);
% bar(Table.Nr_BehPattern, Table.EarningsDrops) ;
% ylabel('Earnings(drops)','fontsize',15,'fontweight','b' );
% 
% ax1 = subplot(3,1,2);
% b = bar(Table.wagerProportions_correct, 'Stacked') ;
% ylabel('Nr. of Trials (correct)','fontsize',15,'fontweight','b' );
% set(gca, 'box', 'off');
% legend(b, {'wager1', 'wager2', 'wager3'})
% 
% ax1 = subplot(3,1,3);
% b = bar(Table.wagerProportions_wrong, 'groups') ;
% ylabel('Nr. of Trials (incorrect)','fontsize',15,'fontweight','b' );
% set(gca, 'box', 'off');
% legend(b, {'wager1', 'wager2', 'wager3'})
% 
% 
% figure(3)
% bar(Table.Nr_BehPattern, Table.EarningsUtility,'k') ;
% ylabel('Earnings(utils)','fontsize',15,'fontweight','b' );
% %color a specific bar

WagerCategories = unique(Table.behavioral_pattern); 
Tab = []; 

for ind_WagCat = 1: length(WagerCategories)
Tab.WagCat(ind_WagCat)              = WagerCategories(ind_WagCat); 
Tab.NrPatternsInCategory(ind_WagCat)             = sum(strcmp(Table.behavioral_pattern,  WagerCategories(ind_WagCat))); 
% Tab.Index_InsideWagCat(ind_WagCat)  = find(Table.EarningsUtility(strcmp(Table.behavioral_pattern,  WagerCategories(ind_WagCat))) == max((Table.EarningsUtility(strcmp(Table.behavioral_pattern,  WagerCategories(ind_WagCat))))),1); 
% if ind_WagCat == 1
%     Tab.Index_WagCat(ind_WagCat)        =Tab.Index_InsideWagCat(ind_WagCat); 
% else
% Tab.Index_WagCat(ind_WagCat)        = Tab.NrPatternsInCategory(1:ind_WagCat-1)   + Tab.Index_InsideWagCat(ind_WagCat) ; 
% end
Tab.maxUtilityWagCat(ind_WagCat)    =  max((Table.EarningsUtility(strcmp(Table.behavioral_pattern,  WagerCategories(ind_WagCat))))); 




end

% figure(3+ ind_WagCat)
% plot(1:3,Table.wagerProportions_correct(Tab.Index_WagCat(ind_WagCat),:),'g.-', 'MarkerSize',40','LineWidth',4); hold on;
% plot(1:3,Table.wagerProportions_wrong(Tab.Index_WagCat(ind_WagCat),:),'r.-', 'MarkerSize',40,'LineWidth',4); hold on;
% set(gca,'ylim',[0 1 ]); set(gca,'Xtick', [1,2,3] )
% title([Tab.WagCat(ind_WagCat) , 'Uility =', Tab.maxUtilityWagCat(ind_WagCat)])

figure(9)
bar(1:length(Tab.maxUtilityWagCat), Tab.maxUtilityWagCat,'k') ;
ylabel('Earnings(utils)','fontsize',15,'fontweight','b' );
set(gca,'XtickLabel', cellstr(Tab.WagCat),'fontsize',10)
set(gca, 'XTickLabelRotation',45)
title(['Performance =', num2str(Perf)])
set(gca, 'TickLabelInterpreter', 'none')
ylim([0, 1200])
%color a specific bar

