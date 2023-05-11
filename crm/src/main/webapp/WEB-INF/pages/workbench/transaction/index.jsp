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
<link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

<script type="text/javascript">

	$(function(){
		queryTranByConditionForPage(1,10);
		
		$("#createTranBtn").click(function () {
			window.location.href="workbench/transaction/createPage.do";
		});

		$("#myCheckAll").click(function () {
			// 如果选中按钮，则所有按钮全选中
			if (this.checked) {
				// 父子选择器
				$("#tBody input[type='checkbox']").prop("checked", true);
			} else {
				$("#tBody input[type='checkbox']").prop("checked", false);
			}
		});

		$("#tBody").on("click","input[type='checkbox']",function () {
			if($("#tBody input[type='checkbox']").size()==$("#tBody input[type='checkbox']:checked").size()){
				$("#myCheckAll").prop("checked",true);
			}else{
				$("#myCheckAll").prop("checked",false);
			}
		})
		$("#queryTranBtn").click(function () {
			queryTranByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
		});

		$("#editTranBtn").click(function () {
			let checkedId=$("#tBody input[type='checkbox']:checked");
			if(checkedId.size()==0){
				alert("请选择要修改的交易");
				return;
			}
			if (checkedId.size()>1){
				alert("一次只能修改一个交易")
				return;
			}
			let id=checkedId.val();
			window.location.href="workbench/transaction/toEdit.do?id="+id;
		});

		$("#deleteTranBtn").click(function () {
			let checkedIds=$("#tBody input[type='checkbox']:checked");
			if(checkedIds.size()==0){
				alert("请选择要删除的交易");
				return;
			}
			if(window.confirm("确定要删除吗？")){
				let ids="";
				$.each(checkedIds,function () {
					ids+="id="+this.value+"&"
				});
				ids=ids.substr(0,ids.length-1);
				$.ajax({
					url:"workbench/transaction/saveDeleteTran.do",
					data:ids,
					type:"post",
					dataType:"json",
					success:function (data) {
						if(data.code=="1"){
							queryTranByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
						}else{
							alert(data.message);
						}
					}
				});
			}
		});
	});

	function queryTranByConditionForPage(pageNo,pageSize){
		let owner=$("#queryTranOwner").val();
		let name=$("#queryTranName").val();
		let customerId=$("#queryTranCustomerId").val();
		let stage=$("#queryTranStage").val();
		let type=$("#queryTranType").val();
		let source=$("#queryTranSource").val();
		let contactsId=$("#queryTranContactsId").val();
		$.ajax({
			url:"workbench/transaction/queryTranByConditionForPage.do",
			data:{
				owner:owner,
				name:name,
				customerId:customerId,
				stage:stage,
				type:type,
				source:source,
				contactsId:contactsId,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:"post",
			dataType:"json",
			success:function (data) {
				let htmlStr="";
				$.each(data.tranList,function (index, obj) {
					htmlStr+="<tr>"
					htmlStr+="<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>"
					htmlStr+="<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/transaction/queryTranRemarkHistoryById.do?id="+obj.id+"';\">"+obj.name+"</a></td>"
					htmlStr+="<td>"+obj.customerId+"</td>"
					htmlStr+="<td>"+obj.stage+"</td>"
					htmlStr+="<td>"+obj.type+"</td>"
					htmlStr+="<td>"+obj.owner+"</td>"
					htmlStr+="<td>"+obj.source+"</td>"
					htmlStr+="<td>"+obj.contactsId+"</td>"
					htmlStr+="</tr>"
				});
				$("#tBody").html(htmlStr);
				// 取消全选按钮的选择
				$("#myCheckAll").prop("checked", false);
				//计算总页数
				let totalPages = 1;
				if (data.totalRows % pageSize == 0) {
					totalPages = data.totalRows / pageSize;
				} else {
					totalPages = parseInt(data.totalRows / pageSize) + 1;
				}
				//对容器调用bs_pagination工具函数，显示翻页信息
				$("#demo_pag1").bs_pagination({
					currentPage: pageNo,//当前页号,相当于pageNo
					rowsPerPage: pageSize,//每页显示条数,相当于pageSize
					totalRows: data.totalRows,//总条数
					totalPages: totalPages,  //总页数,必填参数.
					visiblePageLinks: 5,//最多可以显示的卡片数
					showGoToPage: true,//是否显示"跳转到"部分,默认true--显示
					showRowsPerPage: true,//是否显示"每页显示条数"部分。默认true--显示
					showRowsInfo: true,//是否显示记录的信息，默认true--显示
					//用户每次切换页号，都自动触发本函数;
					//每次返回切换页号之后的pageNo和pageSize
					onChangePage: function (event, pageObj) {
						queryTranByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
					}
				});
			}
		});
	}
	
</script>
</head>
<body>

	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>交易列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="queryTranOwner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="queryTranName">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="queryTranCustomerId">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">阶段</div>
					  <select class="form-control" id="queryTranStage">
					  	<option></option>
					  	<c:forEach items="${stageList}" var="stage">
							<option value="${stage.id}">${stage.value}</option>
						</c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">类型</div>
					  <select class="form-control" id="queryTranType">
					  	<option></option>
					  	<c:forEach items="${transactionTypeList}" var="transactionType">
							<option value="${transactionType.id}">${transactionType.value}</option>
						</c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="queryTranSource">
						  <option></option>
						  <c:forEach items="${sourceList}" var="source">
							  <option value="${source.id}">${source.value}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">联系人名称</div>
				      <input class="form-control" type="text" id="queryTranContactsId">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="queryTranBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createTranBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editTranBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteTranBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="myCheckAll"/></td>
							<td>名称</td>
							<td>客户名称</td>
							<td>阶段</td>
							<td>类型</td>
							<td>所有者</td>
							<td>来源</td>
							<td>联系人名称</td>
						</tr>
					</thead>
					<tbody id="tBody">
					</tbody>
				</table>
			</div>

			<div id="demo_pag1"></div>
			
		</div>
		
	</div>
</body>
</html>