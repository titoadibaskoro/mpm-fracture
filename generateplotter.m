function main()
	%switchdir;SwitchablePrototype;switchdirback
	%dos 'startmatlab2'
	%clear all
	%return;
	%switchdir;
	%1;
	FileName='mpmfracture.m';
	FileNameNom=FileName(1:length(FileName)-2);

	try
		com.mathworks.mlservices.MatlabDesktopServices.getDesktop.getMainFrame.setTitle(['Plotting ' FileNameNom]);
	end
	FileNameOpen=[FileNameNom '.m'];

	%mkdir(['codegecan\lib\' FileNameNom]);
	%mkdir(['codegen\lib\' FileNameNom '\' FileNameNom]);
	%disp('start of move via dos');
	%dos(['move /Y Out-' FileNameNom '* codegen\lib\' FileNameNom '\' FileNameNom]);
	%disp('end of move via dos');

	FileNameSave=[FileNameNom 'plot.m'];
	SwitchableNumber=2;

	TextFileOpen=fopen(FileNameOpen);
	CharArrayIn=fread(TextFileOpen,[1,Inf],'char');
	%CharArrayOut=CharArrayIn;
	fclose(TextFileOpen);

	TheStringtoFind{1}=['%{%switchable' num2str(SwitchableNumber)];
	 TheReplacement{1}=['%[%switchable' num2str(SwitchableNumber)];

	TheStringtoFind{2}=['%}%switchable' num2str(SwitchableNumber)];
	 TheReplacement{2}=['%]%switchable' num2str(SwitchableNumber)];

	TheStringtoFind{3}=['%[%switchable' num2str(SwitchableNumber)];
	 TheReplacement{3}=['%{%switchable' num2str(SwitchableNumber)];

	TheStringtoFind{4}=['%]%switchable' num2str(SwitchableNumber)];
	 TheReplacement{4}=['%}%switchable' num2str(SwitchableNumber)];



	CharArrayOut=charswapper(CharArrayIn,TheStringtoFind,TheReplacement);

	TheData=fopen(FileNameSave,'w');
	for i=1:length(CharArrayOut)
		fprintf(TheData,'%s',char(CharArrayOut(i)));
	end
	fclose(TheData);
	%switchdirback;
	%dispevalthis=['switchdir;cd codegen\lib' '\' FileNameNom '\' FileNameNom ';winopen . ;open ' FileNameNom '.m;pause(0.01);' FileNameNom ';'];
	%dispevalthis=['switchdir;cd codegen\lib' '\' FileNameNom '\' FileNameNom ';winopen . ;pause(0.01);' FileNameNom ';'];
	%dispevalthis=['switchdir;cd codegen\lib' '\' FileNameNom '\' FileNameNom ';winopen . ;open ' FileNameNom '.m;pause;' FileNameNom ';'];
	%disp(dispevalthis);
	%disp('Press Enter Twice to Eval Run above!');
	%pause;
	%disp('Press Enter One More Time to Eval Run above!');
	%pause;
	%eval(dispevalthis);
	%soundplay;
	disp('Done!')
end


function charoutvalue=charswapper(charin,charlookup,charreplace)
	nlookupset=length(charlookup);
	ncharin=length(charin);
	ncharlookmax=zeros(1,1);
	for ilookupset=1:nlookupset
		if ilookupset==1
			ncharlookmax=length(charlookup{ilookupset});
		elseif ncharlookmax>length(charlookup{ilookupset})
			ncharlookmax=length(charlookup{ilookupset});
		end
	end
	charreptemp.value=zeros(1,2*ncharlookmax);
	charreptemp.size=zeros(1,1);
	breaksignal1=zeros(1,1);
	breaksignal2=zeros(1,1);
	charout.value=zeros(1,round(1.5*ncharin,0));
	charout.size=zeros(1,1);
	ncarriedover=zeros(1,1);
	ncarriedovermin=zeros(1,1);
	replaced=zeros(1,1);
	icharout=1;
	icharin=1;

	for ichar=1:2*ncharin
		breaksignal2=0;
		for ilookupset=1:nlookupset
			replaced=0;
			ncharlook=length(charlookup{ilookupset});
			ncharrep=length(charreplace{ilookupset});
			ichargap=0; %counting ignored characters
			icharlook=1; %counting how deep it's looking from icharin
			for jchar=icharin:2*ncharin %inside the scan process
				if icharlook>ncharlook %after lookup is done without failure i.e. all matched and scan is done
					charout.value(icharout:icharout+charreptemp.size-1)=charreptemp.value(1:charreptemp.size); %this is from reading charreptemp, which, when charreplace is longer than charlookup, includes some of charreplace (preserving gaps) and the rest of charreplace.
					charout.size=charout.size+charreptemp.size;
					if ncharrep>ncharlook
						charout.value(icharout+charreptemp.size:icharout+charreptemp.size+(ncharrep-(icharlook)))=charreplace{ilookupset}((icharlook):ncharrep);
						charout.size=charout.size+(ncharrep-(icharlook-1));
					end
					icharin=icharin+max([ncharlook+ichargap charreptemp.size]); %for better readibility
					icharout=charout.size+1;
					charreptemp.value(1:charreptemp.size)=0;
					charreptemp.size=0;
					breaksignal2=1;
					replaced=1;
					break;
				elseif icharin+ichargap+icharlook-1>ncharin %if the lookup scan exceeds the available text in charin, move the remaining characters and abort
					%charout.value(icharout:icharout+ichargap+icharlook-2)=charin(icharin:icharin+ichargap+icharlook-2);
					%charout.size=charout.size+ichargap+icharlook-1;
					ncarriedover=ichargap+icharlook-1;
					if ilookupset==1
						ncarriedovermin=ncarriedover;
					elseif ncarriedovermin<ncarriedover
						ncarriedovermin=ncarriedover;
					end
					break;
				elseif charin(icharin+ichargap+icharlook-1)==charlookup{ilookupset}(icharlook) %move the scanning forward if current scan is still a match
					if icharlook>ncharrep
					else
						charreptemp.value(ichargap+icharlook)=charreplace{ilookupset}(icharlook);
						charreptemp.size=charreptemp.size+1;
					end
					icharlook=icharlook+1;
				elseif charin(icharin+ichargap+icharlook-1)==9 || charin(icharin+ichargap+icharlook-1)==10 || charin(icharin+ichargap+icharlook-1)==13 || charin(icharin+ichargap+icharlook-1)==32 %this is to handle skip characters
					charreptemp.value(ichargap+icharlook)=charin(icharin+ichargap+icharlook-1);
					charreptemp.size=charreptemp.size+1;
					ichargap=ichargap+1;
				else %if everything failed, it means the scan has failed. just carry over the charin's to charout's with an appropriate amount 
					charreptemp.value(1:charreptemp.size)=0;
					charreptemp.size=0;
					ncarriedover=ichargap+max(1,icharlook-1);
					if ilookupset==1
						ncarriedovermin=ncarriedover;
					elseif ncarriedovermin<ncarriedover
						ncarriedovermin=ncarriedover;
					end
					break;
				end
			end
			if breaksignal2
				break;
			end
		end
		if breaksignal1
			break;
		end
		if replaced==0
			charout.value(icharout:icharout+ncarriedover-1)=charin(icharin:icharin+ncarriedover-1);
			charout.size=charout.size+ncarriedover;
			icharin=(icharin+ncarriedover-1)+1; %for better readibility
			icharout=charout.size+1;
		end
	end
	charoutvalue=charout.value(1:charout.size);
end
