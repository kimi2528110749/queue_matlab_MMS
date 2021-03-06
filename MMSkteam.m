function [Ls,Wq,P,e_count] = MMSkteam(s,k,lamda,mu,T)
	%多服务台
	%s??服务台个数
	%k??最大顾客等待数
	%T??时间终止点
	%lamda??到达时间间隔服从泊松分布
	%mu??服务时间服从负指数分布
	%事件表：
	%arrive_time??顾客到达事件
	%leave_time??顾客离开事件
	%mintime??事件表中的最近事件
	%current_time??当前时间
	%L??队长
    %LMax??最大队长
	%tt??时间序列
	%LL??队长序列
	%c??顾客到达时间序列
	%b??服务开始时间序列
	%e??顾客离开时间序列
	%a_count??到达顾客数
	%b_count??服务顾客数
	%e_count??损失顾客数
    %P??顾客不能马上得到服务的概率

	%初始化
	%exprnd生成服从指数lamda分布的随机数
	arrive_time=exprnd(lamda);
	leave_time=[];
	current_time=0;
	L=0;
    LMax=0;
	LL=[L];
	tt=[current_time];
	c=[];
	b=[];
	e=[];
	a_count=0;
	b_count=0;
	e_count=0;
    lamda=1/lamda;
    mu=1/mu;

	%循环
	while min([arrive_time,leave_time])<T
		current_time=min([arrive_time,leave_time]);
		tt=[tt,current_time];	%记录时间序列
		if current_time==arrive_time 	%顾客到达子过程
			arrive_time=arrive_time+exprnd(lamda);	%刷新顾客到达事件
			a_count=a_count+1;	%累加到达顾客数
			if L<s 	%有空闲服务台
				L=L+1;	%更新队长
                if L>LMax
                    LMax=L;
                end
				b_count=b_count+1;	%累加服务顾客数
				c=[c,current_time];	%记录顾客到达时间序列
				b=[b,current_time];	%记录服务开始时间序列
				leave_time=[leave_time,current_time+exprnd(mu)];	%产生新的顾客离开事件
				leave_time=sort(leave_time);	%离开事件表排序
			elseif L<s+k 	%有空闲等待位
				L=L+1;	%更新队长
                if L>LMax
                    LMax=L;
                end
				b_count=b_count+1;	%累加服务顾客数
				c=[c,current_time];	%记录顾客到达时间序列
			else
				e_count=e_count+1;	%累加损失顾客数
			end
		else 	%顾客离开子过程
			leave_time(1)=[];	%从事件表中抹去顾客离开事件
			e=[e,current_time];	%记录顾客离开事件序列
			if L>s 	%有顾客等待
				L=L-1;	%更新队长
                if L>LMax
                    LMax=L;
                end
				b=[b,current_time];	%记录服务开始时间序列
				leave_time=[leave_time,current_time+exprnd(mu)];
				leave_time=sort(leave_time);	%离开事件表排序
			else 	%无顾客等待
				L=L-1;	%更新队长
			end
		end
		LL=[LL,L];	%记录队长序列
	end
	Ws=sum(e-c(1:length(e)))/length(e);
	Wq=sum(b-c(1:length(b)))/length(b);
	Wb=sum(e-b(1:length(e)))/length(e);
	Ls=sum(diff([tt,T]).*LL)/T;
	Lq=sum(diff([tt,T]).*max(LL-s,0))/T;
	fprintf('到达顾客数：%d\n',a_count);	%到达顾客数
	fprintf('服务顾客数：%d\n',b_count);	%服务顾客数
	fprintf('损失顾客数：%d\n',e_count);	%损失顾客数
    fprintf('平均服务时间：%f\n',Wb);	%平均服务时间
% 	fprintf('平均逗留时间：%f\n',Ws);	%平均逗留时间
    fprintf('平均队长：%f\n',Ls);	%平均队长
    fprintf('平均等待时长：%f\n',Wq);	%平均等待时间
% 	fprintf('平均等待队长：%f\n',Lq);	%平均等待队长
	if k~=inf
		for i=0:LMax
			p(i+1)=sum((LL==i).*diff([tt,T]))/T;	%队长为i的概率
% 			fprintf('队长为%d的概率：%f\n',i,p(i+1));
        end
    end
    P=1-sum(p(1:LMax));
    fprintf('顾客不能马上得到服务的概率:%f\n',P);	%顾客不能马上得到服务的概率
	out=[Ls,Wq,P,e_count];