% abs_crc_lambda.m
% ����ֵ�Ż�CRC���Զ�Ѱ������ںϲ���

%clear all;

%addpath 'src_solution';

% ��������       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lambda=0.2;    % �ںϲ��� ��
% ���ںϣ�CRC�������ABSʱʹ�ã�ǿ��CRC������
positives = [0.001, 0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]; 
% ���ںϣ�CRC�������ABSʱʹ�ã�ǿ��ABS������
negatives = [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 5, 10, 100];
lambdas = [positives, negatives];
[one, numOfCases] = size(lambdas);
%minTrains = 4; % ��Сѵ��������
%maxTrains = 4; % ���ѵ��������
%inputData      % ������������

% �ܲ�ͬ��ѵ������
if maxTrains == 0
    maxTrains = floor(numOfSamples*0.8);
elseif maxTrains > 12
    maxTrains = 12;
end
%maxTrains = 1;
for numOfTrain=minTrains:maxTrains
    % ����������
    numOfTest = numOfSamples-numOfTrain;
    fprintf('ѵ������=%d��\t��������=%d��\t�� %d �����\n', numOfTrain, numOfTest, numOfClasses);
    
    % ȡ����Ӧԭʼѵ�����Ͳ��Լ�
    for cc=1:numOfClasses
        %clear Ai;
        for tt=1:numOfTrain
            Ai(1,:)=inputData(cc,tt,:); % A(i)
            trainData((cc-1)*numOfTrain+tt,:)=Ai/norm(Ai);
        end
    end
    for cc=1:numOfClasses
        %clear Xi;
        for tt=1:numOfTest
            Xi(1,:)=inputData(cc,tt+numOfTrain,:); % X(i)
            testData((cc-1)*numOfTest+tt,:)=Xi/norm(Xi);
        end
    end
    
    % ʵ�ָ��ֱ�ʾ����
    numOfAllTrains=numOfClasses*numOfTrain; % ѵ������
    numOfAllTests=numOfClasses*numOfTest;   % ��������
    %clear usefulTrain;
    usefulTrain=trainData;
    %clear preserved;
    % (T*T'+aU)-1 * T
    preserved=inv(usefulTrain*usefulTrain'+0.01*eye(numOfAllTrains))*usefulTrain;
    % �����ֲ��������ı�ʾϵ��
    %clear testSample;
    %clear solutionSRC;
    %clear solutionCRC;
    for kk=1:numOfAllTests
        testSample=testData(kk,:);
        % CRC �⣺(T*T'+aU)^-1 * T * D(i)'
        solutionCRC=preserved*testSample';
        % ��ӡ����
        fprintf('%d ', kk);
        if mod(kk,20)==0
            fprintf('\n');
        end
        % SRC ��
        %[solutionSRC, total_iter] =    SolveFISTA(usefulTrain',testSample');
        
        % ���㹱��ֵ
        %clear contributionCRC;
        %clear contributionSRC;
        for cc=1:numOfClasses
            contributionCRC(:,cc)=zeros(row*col,1);
            contributionSRC(:,cc)=zeros(row*col,1);
            crcABS1(cc)=0; % abs of the contribution for crc
            srcABS1(cc)=0; % abs of the contribution for src
            
            for tt=1:numOfTrain
                % C(i) = sum(S(i)*T)
                contributionCRC(:,cc)=contributionCRC(:,cc)+solutionCRC((cc-1)*numOfTrain+tt)*usefulTrain((cc-1)*numOfTrain+tt,:)';
                %contributionSRC(:,cc)=contributionSRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)*usefulTrain((cc-1)*numOfTrain+tt,:)';
                crcABS1(cc)=crcABS1(cc)+abs(solutionCRC((cc-1)*numOfTrain+tt));
                %srcABS1(cc)=srcABS1(cc)+abs(solutionSRC((cc-1)*numOfTrain+tt));
            end
        end
        % �������|�в�|����
        %clear deviationSRC;
        %clear deviationCRC;
        for cc=1:numOfClasses
            % r(i) = |D(i)-C(i)|
            deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc));
            %deviationSRC(cc)=norm(testSample'-contributionSRC(:,cc));
        end
        % �Ż���� CRC
        if redoDeviation==1
            minDeviationCRC=min(deviationCRC);
            maxDeviationCRC=max(deviationCRC);
            minCRCABS1=min(crcABS1);
            maxCRCABS1=max(crcABS1);
            deviationCRC2=(deviationCRC-minDeviationCRC)/(maxDeviationCRC-minDeviationCRC);
            crcABS2=(crcABS1-minCRCABS1)/(maxCRCABS1-minCRCABS1);
        else % ���ֲ���
            deviationCRC2 = deviationCRC;
            crcABS2 = crcABS1;
        end
        % �Ż���� SRC
%         minDeviationSRC=min(deviationSRC);
%         maxDeviationSRC=max(deviationSRC);
%         minSRCABS1=min(srcABS1);
%         maxSRCABS1=max(srcABS1);
%         deviationSRC2=(deviationSRC-minDeviationSRC)/(maxDeviationSRC-minDeviationSRC);
%         srcABS2=(srcABS1-minSRCABS1)/(maxSRCABS1-minSRCABS1);
        % ʶ���� CRC
        [min_value1 xxCRC]=min(deviationCRC2);
        labelCRC(kk)=xxCRC;
        [min_value2 yyCRC]=max(crcABS2);
        labelCRCABS(kk)=yyCRC;
        % - �ò�ͬ�����ںϵĽ��        
        for cii=1:numOfCases % �ܲ�ͬ�Ĳ���
            lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
            % �ں�����
            fusionCRC=deviationCRC2-lambda*crcABS2;
            [min_value3 zzCRC]=min(fusionCRC);
            % ��¼�����ںϵĽ��
            labelCRCFusions(cii,kk)=zzCRC; % �ںϽ��
        end
        % ʶ���� SRC
%         [min_value1 xxSRC]=min(deviationSRC2);
%         labelSRC(kk)=xxSRC;
%         [min_value2 yySRC]=max(srcABS2);
%         labelSRCABS(kk)=yySRC;
%         % result=wucha2-0.5*abs2;
%         fusionSRC=deviationSRC2-lambda*srcABS2;
%         % result=wucha2./abs2;
%         [min_value3 zzSRC]=min(fusionSRC);
%         labelSRCFusion(kk)=zzSRC; % �ںϽ��
    end
    
    % ��ͳ��CRC��ABS��ʶ�������
    errorsCRC=0; errorsSRC=0;
    errorsABS1=0;errorsABS2=0;
    errorsSRCFusion=0;
    
    for kk=1:numOfAllTests
        inte=floor((kk-1)/numOfTest+1);
        dataLabel(kk)=inte; % ��ȷλ��
        
        % CRC
        if labelCRC(kk)~=dataLabel(kk)
            errorsCRC=errorsCRC+1;
        end
        if labelCRCABS(kk)~=dataLabel(kk)
            errorsABS1=errorsABS1+1;
        end
        
        % SRC
%         if labelSRC(kk)~=dataLabel(kk)
%             errorsSRC=errorsSRC+1;
%         end
%         if labelSRCABS(kk)~=dataLabel(kk)
%             errorsABS2=errorsABS2+1;
%         end
%         if labelSRCFusion(kk)~=dataLabel(kk)
%             errorsSRCFusion=errorsSRCFusion+1;
%         end
    end
    
    % �ҳ�������Ͻ��
    lowestLambda = 0;
    lowestErrors = numOfAllTests; % ��С������
    for cii=1:numOfCases % ��鲻ͬ�����µĽ��
        lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
        errorsCRCFusion=0; % ����������
        for kk=1:numOfAllTests % ͳ�ƴ�����
            if labelCRCFusions(cii,kk)~=dataLabel(kk)
                errorsCRCFusion=errorsCRCFusion+1;
            end
        end
        %fprintf('%f��%d\n', lambda, errorsCRCFusion);
        % ��¼��ѽ��
        if errorsCRCFusion<lowestErrors
            lowestLambda = lambda;
            lowestErrors=errorsCRCFusion;
        end
        %fprintf('%f��%d\n', lowestLambda, lowestErrors);
    end
    
    % ȡ����ѽ��
    lambda = lowestLambda;
    errorsCRCFusion = lowestErrors;
    
    % ͳ�ƴ�����
    errorsRatioCRC=errorsCRC/numOfClasses/numOfTest;
    errorsRatioABS1=errorsABS1/numOfClasses/numOfTest;
    errorsRatioCRCFusion=errorsCRCFusion/numOfClasses/numOfTest;
    errorsRatioSRC=errorsSRC/numOfClasses/numOfTest;
    errorsRatioABS2=errorsABS2/numOfClasses/numOfTest;
    errorsRatioSRCFusion=errorsSRCFusion/numOfClasses/numOfTest;
    
    % ������
    result(numOfTrain, 1)=lambda;
    result(numOfTrain, 2)=errorsRatioCRC;
    result(numOfTrain, 3)=errorsRatioABS1;
    result(numOfTrain, 4)=errorsRatioCRCFusion;
    result(numOfTrain, 5)=(errorsRatioCRC-errorsRatioCRCFusion)/errorsRatioCRC;
    result(numOfTrain, 6)=(errorsRatioABS1-errorsRatioCRCFusion)/errorsRatioABS1;
    %result(numOfTrain, 4)=errorsRatioSRC;
    %result(numOfTrain, 5)=errorsRatioABS2;
    %result(numOfTrain, 6)=errorsRatioSRCFusion;
    result % print
    
    % ������������浽�ļ�
    jsonFile = [dbName '_' num2str(numOfTrain) '_' num2str(lambda) '.json'];
    minimal = min([errorsRatioCRC, errorsRatioABS1]);
    if errorsRatioCRCFusion < minimal 
        jsonFile = ['+' jsonFile]; % ������
    elseif errorsRatioCRCFusion == minimal 
        jsonFile = ['=' jsonFile]; % ��ƽ
    else
        jsonFile = ['-' jsonFile]; % ������
    end
    dbJson = savejson('', result(numOfTrain,:), jsonFile);
end

% ���һ����Ĳ��ԣ�����������ѽ��
jsonFile = ['~' dbName '_' num2str(minTrains) '~' num2str(maxTrains) '.json'];
dbJson = savejson('', result, jsonFile);
%data=loadjson(jsonFile);
%result_json = data[db_name];



