function result = MajorityWithKnowledge( model, knowledgeMatrix )
%MAJORITYWITHKNOLEDGE Summary of this function goes here
%   Detailed explanation goes here
maxIter = 100;
TOL =1e-6;
Ntask = model.Ntask; 
Nwork = model.Nwork;
Ndom = model.Ndom;
NeibTask = model.NeibTask; 
NeibWork = model.NeibWork;
LabelTask = model.LabelTask;
LabelWork = model.LabelWork;
LabelDomain =model.LabelDomain;
ans_labels=zeros(1,Ntask);
soft_labels=zeros(1,Ntask);
soft_labels_count=zeros(1,Ntask);
no_ans_labels=[];
ans_multiRangeIndex=[];

Ability = ones(1,Nwork);

LabelTaskScore=cell(1,Ntask);
err = Inf;
for iter = 1:maxIter
    Ability_new = ones(1,Nwork);
    if err < TOL
        break;
    end
    for task_j=1:Ntask
            Lj=LabelTask{task_j};
        dom_j=unique(Lj);
        Ndom_j=length(dom_j);
        Workj = NeibTask{task_j};
        Nworkj = length(Workj);
        count = [dom_j',zeros(Ndom_j,1)];
        for i = 1:Nworkj
            count(dom_j==Lj(i),2)= count(dom_j==Lj(i),2)+1*Ability(Workj(i));
        end
        count(:,2)=count(:,2)/sum(count(:,2));
        for j = 1:Ndom_j
            tem = 0;
            for k = 1:Ndom_j
                tem = tem+knowledgeMatrix(count(k,1),count(j,1))*count(k,2);
            end
            count(j,2)=tem;
        end
        count(:,2)=count(:,2)/sum(count(:,2));
        count=sortrows(count,-2);
        soft_labels(1:Ndom_j,task_j)=count(1:Ndom_j,1);
        soft_labels_count(1:Ndom_j,task_j)=count(1:Ndom_j,2);
        max=0;
        maxIndex=[];
        for i=1:size(count,1)
            if count(i,2)>max
                maxIndex=count(i,1);
                max=count(i,2);
            elseif count(i,2)==max
                maxIndex=[maxIndex count(i,1)];
            end
        end
        ans_num=length(maxIndex);
        if ans_num>1
            ans_labels(task_j)=maxIndex(1);%countһ�£�ѡ��һ����Ϊ��
            %ans_labels(task_j)=maxIndex(unidrnd(ans_num));%���ѡ��һ����
            ans_multiRangeIndex=[ans_multiRangeIndex task_j];
        elseif ans_num==1
            ans_labels(task_j)=maxIndex(1);
        else
            ans_labels(task_j)=LabelDomain(unidrnd(Ndom));
            no_ans_labels=[no_ans_labels tasks_j];%û������task_j��
        end
        LabelTaskScore{task_j}.labelList = count(:,1);
        LabelTaskScore{task_j}.score = count(:,2);
    end
    for work_i = 1:Nwork
        Li = LabelWork{work_i};
        Taski = NeibWork{work_i};
        tem = 0;
        for j = 1:length(Taski)
            tem = tem +LabelTaskScore{Taski(j)}.score(LabelTaskScore{Taski(j)}.labelList==Li(j));
        end
        Ability_new(work_i) = tem/length(Taski);
    end
    err = norm(Ability_new-Ability)
    Ability  = Ability_new;
end
result.Ability=Ability
result.ans_labels=ans_labels;
result.no_ans_labels=no_ans_labels;
result.ans_multiRangeIndex=ans_multiRangeIndex;
result.soft_labels=soft_labels;
result.soft_labels_count=soft_labels_count;
result.accuracy=[];
if ~isempty(model.true_labels)
    result.accuracy=sum(~(ans_labels-model.true_labels))/Ntask;
end

end

