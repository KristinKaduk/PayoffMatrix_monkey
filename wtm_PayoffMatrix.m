function [Out] = wtm_PayoffMatrix(step, min, max)
%createbehavior patterns to wager
Output = [];
Perf        = 0.75;
N_trials    = 100;

   step_pay = 1;
   min = -5; %drops
   max = 5; %drops

%% create all possible behavior patterns to wager using a step size
p_i  = ig_nchoosek_with_rep_perm([min:step_pay:max],3);
p_c  = ig_nchoosek_with_rep_perm([0:step_pay:5],3);

% delete all pattern where timeout is on wager 1 after incorrect 
cp = combvec(p_c',p_i')';
Output(1).nb_Payoffs = size(cp,1);%46656
cp = reshape(cp,Output.nb_Payoffs,3,2);%Matrix Nrx3x2

%%
R_gain = [1.5]; %gains
R_loss = [0.5];
% risk seeking
S = 0.9  ;
%% What is the payoff-matrix which elicits bidirectional certainty & highest metaD?
for idx_PayoffMatrix = 1:Output.nb_Payoffs
    Output(idx_PayoffMatrix).PayoffCorrect = cp(idx_PayoffMatrix,:,1);
    Output(idx_PayoffMatrix).PayoffIncorrect = cp(idx_PayoffMatrix,:,2);    
    Output(idx_PayoffMatrix).PayoffMatrix = [ Output(idx_PayoffMatrix).PayoffCorrect; Output(idx_PayoffMatrix).PayoffIncorrect];
    Output(idx_PayoffMatrix).Utility_PayOff = wtm_utility(  [Output(idx_PayoffMatrix).PayoffCorrect ; Output(idx_PayoffMatrix).PayoffIncorrect],[R_gain,R_loss,S] );
    
end

%% Optimization: max(Reward) & min(Costs) -> utility
%% behavior patterns for three wagers  &  principles
% Create all possible behavior pattern for three wagers
% sort the generated wagering patterns based on rules
step = 0.25; 
Out = wtm_BehaviorPattern_3Wagers(step);

%% find a specific behavior pattern
for i = 1: size(Out.pattern,2)
if isequal(Out.wagerCorrect(i,:),[0 0 1]) &&  isequal(Out.wagerIncorrect(i,:),[1 0 0])
 idx = i  ;
end
end
% index 211
%% exclude the behavior pattern according to specified assumptions (Principles)
%% Calculate earnings related to the different Units of the payoff-matrix
Table = [];
for idx_PayoffMatrix = 1:Output(1).nb_Payoffs
for i_pattern = 211%1:Out.nb_wagerPattern,  
    T.wagerProportions_correct = Output(idx_PayoffMatrix).PayoffCorrect;
    T.wagerProportions_wrong   = Output(idx_PayoffMatrix).PayoffIncorrect;
    
    % payoff-matrix in utils
    Utility_Outcomes = [
        N_trials*Perf    * Output(idx_PayoffMatrix).PayoffCorrect     .* Output(idx_PayoffMatrix).Utility_PayOff(1,:);
        N_trials*(1-Perf)* Output(idx_PayoffMatrix).PayoffIncorrect   .* Output(idx_PayoffMatrix).Utility_PayOff(2,:)];
    T.EarningsUtility    = sum(sum(Utility_Outcomes,1));
    
    % payoff-matrix in ml
    GainOutcomes = [
        N_trials*Perf    *Output(idx_PayoffMatrix).PayoffCorrect    .*Output(idx_PayoffMatrix).PayoffMatrix(1,:);
        N_trials*(1-Perf)*Output(idx_PayoffMatrix).PayoffIncorrect   .*Output(idx_PayoffMatrix).PayoffMatrix(2,:)];
    T.Gain       = sum(sum(GainOutcomes,1));
    
    % payoff-matrix in seconds
    TimeOutcomes = [
        N_trials*Perf       * Output(idx_PayoffMatrix).PayoffCorrect .*   Output(idx_PayoffMatrix).PayoffMatrix(1,:);
        N_trials*(1-Perf)   * Output(idx_PayoffMatrix).PayoffIncorrect .* Output(idx_PayoffMatrix).PayoffMatrix(2,:)];
    T.Time        = sum(sum(TimeOutcomes,1));
    
    
    
    T.payoff_correct                = {num2str(Output(idx_PayoffMatrix).PayoffMatrix(1,:))};
    T.payoff_incorrect              = {num2str(Output(idx_PayoffMatrix).PayoffMatrix(2,:))};
    T.PayOff_Utility_correct        = {num2str(Output(idx_PayoffMatrix).Utility_PayOff(1,:))};
    T.PayOff_Utility_incorrect      = {num2str(Output(idx_PayoffMatrix).Utility_PayOff(2,:))};
    
    
    %% meta-D calculations
    % !!! Download FUNCTION type2_SDT_SSE 
    %n_wagers*2 values in a vector -> 
    % ordered... nR_S1(correct, incorrect) && nR_S2(incorrect, correct) 
    % highest conf "S1" ... lowest conf "S1", lowest conf "S2", ... highest conf "S2"
    % original order 1 2 3
   % nR_S1    = [flip(T.wagerProportions_correct), T.wagerProportions_wrong]*(N_trials*Perf); % highest conf "S1" ... lowest conf "S1"
   % nR_S2    = [flip(T.wagerProportions_wrong),T.wagerProportions_correct]*(N_trials*(1-Perf)); %lowest conf "S2", ... highest conf "S2"
    
   % out      = type2_SDT_SSE(nR_S1, nR_S2);
   % T.metaD  = out.meta_da ; 
   % T.Dprime = out.da ; 
    
    %%
    T.PatternKategoryNr = Out.PatternKategoryNr(i_pattern);

    T.behavioral_pattern = {Out.pattern{i_pattern}};
    T.Nr_BehPattern      = i_pattern;
    T.Nr_PayOff      = idx_PayoffMatrix;
    Row = struct2table(T);
    Table = [Table; Row];
    
    
end 
end


%% save Table
writetable(Table,'Y:\Projects\Wagering_monkey\Data\PayoffMatrix\Table_AllPayOffMatrix_BehaviorPattern_Earnings2.txt', 'Delimiter', ',')
path_save = 'Y:\Projects\Wagering_monkey\Data\PayoffMatrix\';
cd(path_save)
copyfile('Table_BehaviorPattern_Earnings.txt','Table_AllPayOffMatrix_BehaviorPattern_Earnings.m');
save([path_save, 'Table_AllPayOffMatrix_BehaviorPattern_Earnings' ],'Table');

%% 1. What is the optimal wager pattern (max earnings)?
Table(Table.EarningsUtility == max(Table.EarningsUtility),:) % bidrectional certainty - 100% follow the feedback
%% 2. To which wagering category it belong?
Table.behavioral_pattern(Table.EarningsUtility == max(Table.EarningsUtility))
%% 3. Meta-D for the optimal wager pattern given the payoff-matrix
Table.metaD(Table.EarningsUtility == max(Table.EarningsUtility))
max(Table.metaD)
%% 4.%%  What is the optimal wager pattern (max metaD)?
Table(Table.metaD == max(Table.metaD),:) %


