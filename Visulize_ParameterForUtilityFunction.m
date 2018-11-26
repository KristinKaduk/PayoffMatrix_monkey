Visulize_ParameterForUtilityFunction

R_gain = [1.5]; %gains
R_loss = [0.5];
% risk seeking
S = 0.9  ;

Coefficient    =   2.25; %equalize utility PayOff_RW2(2,3)= -45;
PayOff_RW2     = wtm_ConvertTimeOut2Reward(PayOff,Coefficient);  
Utility_PayOff = wtm_utility( PayOff_RW2,[R_gain(1),R_loss(1),S] );
Utility_PayOff = round2(Utility_PayOff,0.1); 

if Plotting
    for indR = 1: 3 %length(R)
        Utility_PayOff = wtm_utility( PayOff_RW,[R_gain(indR),R_loss(indR),S] );
        % plot a utility function from -10 to 10  & mark the points of the
        % PayoffMatrix
        figure(1)
        Value = -8:0.1:8;
        utility = wtm_utility( Value,[R_gain(indR),R_loss(indR),S] );
        plot(real(Value),utility,'k.-', 'MarkerSize',10); hold on;
        plot(real(PayOff_RW),real(Utility_PayOff),'b.', 'MarkerSize',25); hold on;
        line( [ min(Value) max(Value)],[0 0],'Color','black','LineStyle','--')
        line( [0 0],[min(utility)  max(utility)],'Color','black','LineStyle','--')
        title('Utility function with defined parameters: R, S & T')
        ylabel('utility','fontsize',20,'fontweight','b' );
        xlabel('value','fontsize',20,'fontweight','b' );
    end
    text(min(Value)+1,max(Value)-2,['R_gain = ',num2str(R_gain(indR)) ])
    text(min(Value)+1,max(Value)-4,['R_loss = ',num2str(R_loss(indR)) ])
    text(min(Value)+1,max(Value)-6,['S = ',num2str(S) ])
end