<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
%>

<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
<script type="text/javascript">
	$(function () {
		$("#tranSearchActivityBtn").click(function () {
			$("#tranSearchActivityTxt").val("");
			tranSearchActivityByActivityName();
			$("#findMarketActivity").modal("show");
		});

		$("#tranSearchActivityTxt").keyup(function () {
			tranSearchActivityByActivityName();
		});

		$("#tranSearchContactsBtn").click(function () {
			$("#tarnSearchContactsTxt").val("");
			tranSearchCustomerByContactsFullName();
			$("#findContacts").modal("show");
		});

		$("#tarnSearchContactsTxt").keyup(function () {
			tranSearchCustomerByContactsFullName();
		});

		$("#create-transactionStage").change(function () {
			let stageValue=$("#create-transactionStage option:selected").text();
			if(stageValue=="") {
				$("#create-possibility").val("");
				return;
			}
			$.ajax({
				url:"workbench/transaction/getPossibilityByStage.do",
				data:{
					stageValue:stageValue
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					$("#create-possibility").val(data);
				}
			});
		});

		$("#create-accountName").typeahead({
			source:function (jquery, process) {
				$.ajax({
					url:"workbench/transaction/queryCustomerNameByName.do",
					data:{
						name:jquery
					},
					type:"post",
					dataType:"json",
					success:function (data) {
						process(data);
					}
				});
			}
		});

		$(".myDate").datetimepicker({
			language:'zh-CN', //语言
			format:'yyyy-mm-dd',//日期的格式
			minView:'month', //可以选择的最小视图
			initialDate:new Date(),//初始化显示的日期
			autoClose:true,//设置选择完日期或者时间之后，
			todayBtn:true,
			clearBtn:true
		})

		$("#tranTBody").on("click","input[type='radio']",function () {
			let activityId=this.value;
			let activityName=$(this).attr("activityName");
			$("#tranActivityId").val(activityId);
			$("#create-activitySrc").val(activityName);
			$("#findMarketActivity").modal("hide");
		})

		$("#tranContactsTBody").on("click","input[type='radio']",function () {
			let contactsId=this.value;
			let fname=$(this).attr("fullName");
			$("#tranContactsId").val(contactsId);
			$("#create-customerName").val(fname);
			$("#findContacts").modal("hide");
		})

		$("#saveCreateTranBtn").click(function () {
			let owner=$("#create-transactionOwner").val();
			let money=$.trim($("#create-amountOfMoney").val());
			let name=$.trim($("#create-transactionName").val());
			let expectedDate=$("#create-expectedClosingDate").val();
			let customerName=$.trim($("#create-accountName").val());
			let stage=$("#create-transactionStage").val();
			let type=$("#create-transactionType").val();
			let source=$("#create-clueSource").val();
			let activityId=$("#tranActivityId").val();
			let contactsId=$("#tranContactsId").val();
			let description=$.trim($("#create-description").val());
			let contactSummary=$.trim($("#create-contactSummary").val());
			let nextContactTime=$("#create-nextContactTime").val();

			if(name==""){
				alert("名称不能为空");
				return;
			}
			if(expectedDate==""){
				alert("预计成交日期不能为空");
				return;
			}
			if(customerName==""){
				alert("客户名称不能为空");
				return;
			}
			if(stage==""){
				alert("阶段不能为空");
				return;
			}
			if(activityId==""){
				alert("市场活动不能为空");
				return;
			}
			if(contactsId==""){
				alert("联系人不能为空");
				return;
			}
			let regExp1=/^(([1-9]\d*)|0)$/;
			if(!regExp1.test(money)){
				alert("金额只能为非负正数");
				return;
			}

			$.ajax({
				url:"workbench/transaction/saveCreateTran.do",
				data:{
					owner:owner,
					name:name,
					money:money,
					expectedDate:expectedDate,
					customerName:customerName,
					stage:stage,
					type:type,
					source:source,
					activityId:activityId,
					contactsId:contactsId,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code=="1"){
						window.location.href="workbench/transaction/index.do";
					}else{
						alert(data.message);
					}
				}
			});
		});


		$("#cancel").click(function () {
			window.location.href="workbench/transaction/index.do";
		});
	});
	function tranSearchActivityByActivityName(){
		let activityName=$("#tranSearchActivityTxt").val();
		$.ajax({
			url:"workbench/transaction/queryActivityByName.do",
			data:{
				activityName:activityName
			},
			type:"post",
			dataType:"json",
			success:function (data) {
				let htmlStr="";
				$.each(data,function (index, obj) {
					htmlStr+="<tr>"
					htmlStr+="<td><input type=\"radio\" value=\""+obj.id+"\" activityName=\""+obj.name+"\" name=\"activity\"/></td>"
					htmlStr+="<td>"+obj.name+"</td>"
					htmlStr+="<td>"+obj.startDate+"</td>"
					htmlStr+="<td>"+obj.endDate+"</td>"
					htmlStr+="<td>"+obj.owner+"</td>"
					htmlStr+="</tr>"
				});
				$("#tranTBody").html(htmlStr);
			}
		});
	};

	function tranSearchCustomerByContactsFullName(){
		let fullname=$("#tarnSearchContactsTxt").val();
		$.ajax({
			url:"workbench/transaction/queryContactsByFullName.do",
			data:{
				fullname:fullname
			},
			type:"post",
			datatype:"json",
			success:function (data) {
				let htmlStr1="";
				$.each(data,function (index, obj) {
					htmlStr1+="<tr>"
					htmlStr1+="<td><input type=\"radio\" value=\""+obj.id+"\" fullName=\""+obj.fullname+"\" name=\"activity\"/></td>"
					htmlStr1+="<td>"+obj.fullname+"</td>"
					htmlStr1+="<td>"+obj.email+"</td>"
					htmlStr1+="<td>"+obj.mphone+"</td>"
					htmlStr1+="</tr>"
				});
				$("#tranContactsTBody").html(htmlStr1);
			}
		});
	};
</script>
</head>
<body>

	<!-- 查找市场活动 -->	
	<div class="modal fade" id="findMarketActivity" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input id="tranSearchActivityTxt" type="text" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
							</tr>
						</thead>
						<tbody id="tranTBody">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人 -->	
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input id="tarnSearchContactsTxt" type="text" class="form-control" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="tranContactsTBody">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>李四</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>李四</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
	
	<div style="position:  relative; left: 30px;">
		<h3>创建交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="saveCreateTranBtn">保存</button>
			<button type="button" class="btn btn-default" id="cancel">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" role="form" style="position: relative; top: -30px;">
		<div class="form-group">
			<label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionOwner">
				  <c:forEach items="${userList}" var="user">
					  <option value="${user.id}">${user.name}</option>
				  </c:forEach>
				</select>
			</div>
			<label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-amountOfMoney">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-transactionName">
			</div>
			<label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control myDate" id="create-expectedClosingDate" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-accountName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-accountName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>
			<label for="create-transactionStage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="create-transactionStage">
			  	<option></option>
				  <c:forEach items="${stageList}" var="stage">
					  <option value="${stage.id}">${stage.value}</option>
				  </c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionType" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionType">
					<option></option>
					<c:forEach items="${transactionTypeList}" var="transactionType">
						<option value="${transactionType.id}">${transactionType.value}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-possibility" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-clueSource">
					<option></option>
					<c:forEach items="${sourceList}" var="source">
						<option value="${source.id}">${source.value}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="tranSearchActivityBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="hidden" id="tranActivityId">
				<input type="text" class="form-control" id="create-activitySrc" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-customerName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" id="tranSearchContactsBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="hidden" id="tranContactsId">
				<input type="text" class="form-control" id="create-customerName" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-description" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-description"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control myDate" id="create-nextContactTime" readonly>
			</div>
		</div>
		
	</form>
</body>
</html>