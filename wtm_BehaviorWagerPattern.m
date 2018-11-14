function [Out] = wtm_BehaviorWagerPattern(step)
%createbehavior patterns to wager

if nargin < 1
   step = 0.25;
end

%% create all possible behavior patterns to wager using a step size
wp  = ig_nchoosek_with_rep_perm([0:step:1],3);
wp = wp(sum(wp,2)==1,:);

n_wp = size(wp,1);

wp_c = wp;
wp_i = wp;

cwp = combvec(wp_c',wp_i')';

Out.nb_wagerPattern = size(cwp,1);

cwp = reshape(cwp,Out.nb_wagerPattern,3,2);

%% exclude the behavior pattern according to specified assumptions (Principles)
Out.pattern = []; 
for k = 1:Out.nb_wagerPattern,	
	Out.wagerCorrect(k,:) = cwp(k,:,1);
	Out.wagerIncorrect(k,:) = cwp(k,:,2);
	
	if all(Out.wagerCorrect(k,:) == Out.wagerIncorrect(k,:)),
		Out.pattern{k} = 'no metacognition';
	else
		Out.pattern{k} = 'weird pattern';
		% define two slopes
		slope32_c = Out.wagerCorrect(k,3)-Out.wagerCorrect(k,2);
		slope32_i = Out.wagerIncorrect(k,3)-Out.wagerIncorrect(k,2);
		
		slope21_c = Out.wagerCorrect(k,2)-Out.wagerCorrect(k,1);
		slope21_i = Out.wagerIncorrect(k,2)-Out.wagerIncorrect(k,1);
		
		CertCor = 0;
		CertInc = 0;
		
		if Out.wagerCorrect(k,3)>Out.wagerIncorrect(k,3) && slope32_c>slope32_i
			CertCor = 1;
			Out.pattern{k} = 'certainty correct';
		end
		
		if Out.wagerCorrect(k,1)<Out.wagerIncorrect(k,1) && slope21_c>slope21_i
			CertInc = 1;
			Out.pattern{k} = 'certainty incorrect';
		end
		
		if CertCor && CertInc
			Out.pattern{k} = 'bidirectional certainty';
		end
			
		
	end
	
	switch Out.pattern{k}
		
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
