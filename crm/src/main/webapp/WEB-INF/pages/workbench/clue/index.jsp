<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<html>
<head>
	<base href="<%=basePath%>">
	<meta charset="UTF-8">

	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
	<link rel="stylesheet" type="text/css" href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css">
	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">

	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
	<script type="text/javascript">
		$(function () {
			// 给标签加上日历
			$(".myDateClass").datetimepicker({
				language: 'zh-CN',
				format: 'yyyy-mm-dd',
				minView: 'month', // 可以选择的最小视图
				initialDate: new Date(),
				autoclose: true,  // 选择完是否自动关闭
				todayBtn: true, // 设置是否显示今天的
				clearBtn: true
			});
			// 初始化后做一个初步的查询
			queryClueByConditionForPage(1, 10);
			// 给创建按钮添加事件
			$("#createClueBtn").click(function () {
				// 内容清空
				$("#createClueForm").get(0).reset();
				// 弹出窗口
				$("#createClueModal").modal("show");
			});
			// 绑定保存新建线索的单击事件
			$("#saveCreateClueBtn").click(function () {
				let owner = $("#create-owner").val();
				let company = $("#create-company").val();
				let appellation = $("#create-appellation").val();
				let fullname = $("#create-fullname").val();
				let job = $("#create-job").val();
				let email = $("#create-email").val();
				let phone = $("#create-phone").val();
				let website = $.trim($("#create-website").val());
				let mphone = $("#create-mphone").val();
				let state = $("#create-status").val();
				let source = $("#create-source").val();
				let description = $.trim($("#create-description").val());
				let contactSummary = $.trim($("#create-contactSummary").val());
				let next_contact_time = $.trim($("#create-nextContactTime").val());
				let address = $.trim($("#create-address").val());
				if (owner == "" || company == "" || fullname == "") {
					alert("必填字段不能为空！");
					$("#createClueModal").modal("show");
					return;
				}
				let reg1=/^1\d{10}$/;
				if(!reg1.test(mphone)){
					alert("手机号码不合法,11位手机号");
					return;
				}
				let reg2=/^0\d{2}-\d{8}$/;
				if(!reg2.test(phone)){
					alert("座机号不合法,12位座机号");
					return;
				}
				let reg3 = /^([a-zA-Z\d][\w-]{2,})@(\w{2,})\.([a-z]{2,})(\.[a-z]{2,})?$/;
				if(!reg3.test(email)){
					alert("邮箱不合法");
					return;
				}
				$.ajax({
					url: 'workbench/clue/saveCreateClue.do',
					data: {
						owner: owner,
						company: company,
						appellation: appellation,
						fullname: fullname,
						job: job,
						email: email,
						phone: phone,
						website: website,
						mphone: mphone,
						state: state,
						source: source,
						description: description,
						contactSummary: contactSummary,
						nextContactTime: next_contact_time,
						address: address
					},
					type: 'post',
					datatype: 'json',
					success: function (data) {
						if (data.code == "1") {
							// 关闭模态窗口
							$("#createClueModal").modal("hide");
							// 执行刷新
							queryClueByConditionForPage(1, $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
						} else {
							alert(data.message);
							// 模态窗口不关闭
							$("#createClueModal").modal("show");
						}
					}
				});
			});
			// 全选活动按钮绑定事件
			$("#myCheckAll").click(function () {
				// 如果选中按钮，则所有按钮全选中
				if (this.checked) {
					// 父子选择器
					$("#tBody input[type='checkbox']").prop("checked", true);
				} else {
					$("#tBody input[type='checkbox']").prop("checked", false);
				}
			});
			// 选择活动
			$("#tBody").on("click", "input[type='checkbox']", function () {
				// 如果列表中的全部checkbox都选中
				if ($("#tBody input[type='checkbox']:checked").size() == $("#tBody input[type='checkbox']").size()) {
					$("#myCheckAll").prop("checked", true);
				} else {
					$("#myCheckAll").prop("checked", false);
				}
			});
			// 查询功能
			$("#queryClueBtn").click(function () {
				queryClueByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
			});
			//修改功能
			$("#updateClueBtn").click(function () {
				let ids=$("#tBody input[type='checkbox']:checked");
				if(ids.size()==0){
					alert("请选择要修改的线索");
					return;
				}
				if(ids.size()>1){
					alert("只能修改一个线索");
					return;
				}
				let id=ids.val();
				$.ajax({
					url:"workbench/clue/queryClueById.do",
					data:{
						id:id
					},
					type:"post",
					datatype:"json",
					success:function (data) {
						$("#edit-id").val(data.id);
						$("#edit-owner").val(data.owner);
						alert(data.owner);
						$("#edit-company").val(data.company);
						$("#edit-appellation").val(data.appellation);
						$("#edit-fullname").val(data.fullname);
						$("#edit-job").val(data.job);
						$("#edit-email").val(data.email);
						$("#edit-phone").val(data.phone);
						$("#edit-website").val(data.website);
						$("#edit-mphone").val(data.mphone);
						$("#edit-state").val(data.state);
						$("#edit-source").val(data.source);
						$("#edit-description").val(data.description);
						$("#edit-contactSummary").val(data.contactSummary);
						$("#edit-nextContactTime").val(data.nextContactTime);
						$("#edit-address").val(data.address);
						$("#editClueModal").modal("show");
					}
				})
			});
			$("#saveUpdateClueBtn").click(function () {
				let id=$("#edit-id").val();
				let owner=$("#edit-owner").val();
				let company=$("#edit-company").val();
				let appellation=$("#edit-appellation").val();
				let fullname=$("#edit-fullname").val();
				let job=$("#edit-job").val();
				let email=$("#edit-email").val();
				let phone=$("#edit-phone").val();
				let website=$("#edit-website").val();
				let mphone=$("#edit-mphone").val();
				let state=$("#edit-state").val();
				let source=$("#edit-source").val();
				let description=$("#edit-description").val();
				let contactSummary=$("#edit-contactSummary").val();
				let nextContactTime=$("#edit-nextContactTime").val();
				let address=$("#edit-address").val();
				if (owner == "" || company == "" || fullname == "") {
					alert("必填字段不能为空！");
					$("#createClueModal").modal("show");
					return;
				}
				let reg1=/^1\d{10}$/;
				if(!reg1.test(mphone)){
					alert("手机号码不合法,11位手机号");
					return;
				}
				let reg2=/^0\d{2}-\d{8}$/;
				if(!reg2.test(phone)){
					alert("座机号不合法,12位座机号");
					return;
				}
				let reg3 = /^([a-zA-Z\d][\w-]{2,})@(\w{2,})\.([a-z]{2,})(\.[a-z]{2,})?$/;
				if(!reg3.test(email)){
					alert("邮箱不合法");
					return;
				}
				$.ajax({
					url:"workbench/clue/saveUpdateClue.do",
					data:{
						id:id,
						owner:owner,
						company:company,
						appellation:appellation,
						fullname:fullname,
						job:job,
						email:email,
						phone:phone,
						website:website,
						mphone:mphone,
						state:state,
						source:source,
						description:description,
						contactSummary:contactSummary,
						nextContactTime:nextContactTime,
						address:address
					},
					type:"post",
					dataType:"json",
					success:function (data) {
						if(data.code=="1"){
							$("#editClueModal").modal("hide");
							queryClueByConditionForPage($("#demo_pag1").bs_pagination('getOption', 'currentPage'),$("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'))
						}else {
							alert(data.message);
							$("#editClueModal").modal("show");
						}
					}
				})
			});
			// 删除功能
			$("#deleteClueBtn").click(function () {
				let checkedIds = $("#tBody input[type='checkbox']:checked");
				if (checkedIds.size() == 0) {
					alert("删除操作至少选择一条记录！");
					return;
				}
				if (window.confirm("确定删除吗？")) {
					var ids = "";
					$.each(checkedIds, function () {
						ids += "id=" + this.value + "&";
					});
					ids = ids.substr(0, ids.length - 1);
					// 向后台发请求
					$.ajax({
						url: 'workbench/clue/deleteClueByIds.do',
						data: ids,
						type: 'post',
						datatype: 'json',
						success: function (data) {
							if (data.code == "1") {
								queryClueByConditionForPage(1, $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
							} else {
								alert(data.message);
							}
						}
					});
				}
			});
		});
		// 查询的功能
		function queryClueByConditionForPage(pageNo, pageSize) {
			//收集参数
			let fullname = $("#query-fullname").val();
			let company = $("#query-company").val();
			let phone = $("#query-phone").val();
			let source = $("#query-source").val();
			let owner = $("#query-owner").val();
			let mphone = $("#query-mphone").val();
			let state = $("#query-state").val();
			//发送请求
			$.ajax({
				url: 'workbench/clue/queryClueByConditionForPage.do',
				data: {
					fullname: fullname,
					company: company,
					phone: phone,
					source: source,
					owner: owner,
					mphone: mphone,
					state: state,
					pageNo: pageNo,
					pageSize: pageSize
				},
				type: 'post',
				dataType: 'json',
				success: function (data) {
					//遍历activityList，拼接所有行数据
					let htmlStr = "";
					$.each(data.clueList, function (index, obj) {
						htmlStr += "<tr class='active'>";
						htmlStr += "<td><input type='checkbox' value='" + obj.id + "'/></td>";
						htmlStr += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/clue/DetailClue.do?id=" + obj.id + "'\">" + obj.fullname + obj.appellation + "</a></td>";
						htmlStr += "<td>" + obj.company + "</td>";
						htmlStr += "<td>" + obj.phone + "</td>";
						htmlStr += "<td>" + obj.mphone + "</td>";
						htmlStr += "<td>" + obj.source + "</td>";
						htmlStr += "<td>" + obj.owner + "</td>";
						htmlStr += "<td>" + obj.state + "</td>";
						htmlStr += "</tr>";
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
							queryClueByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
						}
					});
				}
			});
		}
	</script>
</head>
<body>

<!-- 创建线索的模态窗口 -->
<div class="modal fade" id="createClueModal" role="dialog">
	<div class="modal-dialog" role="document" style="width: 90%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">
					<span aria-hidden="true">×</span>
				</button>
				<h4 class="modal-title" id="myModalLabel">创建线索</h4>
			</div>
			<div class="modal-body">
				<form class="form-horizontal" role="form" id="createClueForm">

					<div class="form-group">
						<label for="create-owner" class="col-sm-2 control-label">所有者<span
								style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="create-owner">
								<c:forEach items="${userList}" var="user">
									<option value="${user.id}">${user.name}</option>
								</c:forEach>
							</select>
						</div>
						<label for="create-company" class="col-sm-2 control-label">公司<span
								style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="create-company">
						</div>
					</div>

					<div class="form-group">
						<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="create-appellation">
								<option></option>
								<c:forEach items="${appellationList}" var="appellation">
									<option value="${appellation.id}">${appellation.value}</option>
								</c:forEach>
							</select>
						</div>
						<label for="create-fullname" class="col-sm-2 control-label">姓名<span
								style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="create-fullname">
						</div>
					</div>

					<div class="form-group">
						<label for="create-job" class="col-sm-2 control-label">职位</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="create-job">
						</div>
						<label for="create-email" class="col-sm-2 control-label">邮箱</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="create-email">
						</div>
					</div>

					<div class="form-group">
						<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="create-phone">
						</div>
						<label for="create-website" class="col-sm-2 control-label">公司网站</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="create-website">
						</div>
					</div>

					<div class="form-group">
						<label for="create-mphone" class="col-sm-2 control-label">手机</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="create-mphone">
						</div>
						<label for="create-status" class="col-sm-2 control-label">线索状态</label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="create-status">
								<option></option>
								<c:forEach items="${clueStateList}" var="clueState">
									<option value="${clueState.id}">${clueState.value}</option>
								</c:forEach>
							</select>
						</div>
					</div>

					<div class="form-group">
						<label for="create-source" class="col-sm-2 control-label">线索来源</label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="create-source">
								<option></option>
								<c:forEach items="${sourceList}" var="source">
									<option value="${source.id}">${source.value}</option>
								</c:forEach>
							</select>
						</div>
					</div>


					<div class="form-group">
						<label for="create-description" class="col-sm-2 control-label">线索描述</label>
						<div class="col-sm-10" style="width: 81%;">
							<textarea class="form-control" rows="3" id="create-description"></textarea>
						</div>
					</div>

					<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

					<div style="position: relative;top: 15px;">
						<div class="form-group">
							<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
							</div>
						</div>
						<div class="form-group">
							<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control myDateClass" id="create-nextContactTime" readonly>
							</div>
						</div>
					</div>

					<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

					<div style="position: relative;top: 20px;">
						<div class="form-group">
							<label for="create-address" class="col-sm-2 control-label">详细地址</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="1" id="create-address"></textarea>
							</div>
						</div>
					</div>
				</form>

			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				<button type="button" class="btn btn-primary" id="saveCreateClueBtn">保存</button>
			</div>
		</div>
	</div>
</div>

<!-- 修改线索的模态窗口 -->
<div class="modal fade" id="editClueModal" role="dialog">
	<div class="modal-dialog" role="document" style="width: 90%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">
					<span aria-hidden="true">×</span>
				</button>
				<h4 class="modal-title">修改线索</h4>
			</div>
			<div class="modal-body">
				<form class="form-horizontal" role="form">
					<input type="hidden" id="edit-id">
					<div class="form-group">
						<label for="edit-owner" class="col-sm-2 control-label">所有者<span
								style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="edit-owner">

								<c:forEach items="${userList}" var="user">
									<option value="${user.id}">${user.name}</option>
								</c:forEach>

							</select>
						</div>
						<label for="edit-company" class="col-sm-2 control-label">公司<span
								style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-company" value="动力节点">
						</div>
					</div>

					<div class="form-group">
						<label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="edit-appellation">
								<option></option>
								<c:forEach items="${appellationList}" var="appellation">
									<option value="${appellation.id}">${appellation.value}</option>
								</c:forEach>
							</select>
						</div>
						<label for="edit-fullname" class="col-sm-2 control-label">姓名<span
								style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-fullname">
						</div>
					</div>

					<div class="form-group">
						<label for="edit-job" class="col-sm-2 control-label">职位</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-job" value="CTO">
						</div>
						<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-email">
						</div>
					</div>

					<div class="form-group">
						<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-phone">
						</div>
						<label for="edit-website" class="col-sm-2 control-label">公司网站</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-website"
								   value="http://www.bjpowernode.com">
						</div>
					</div>

					<div class="form-group">
						<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-mphone">
						</div>
						<label for="edit-state" class="col-sm-2 control-label">线索状态</label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="edit-state">
								<option></option>
								<c:forEach items="${clueStateList}" var="clueState">
									<option value="${clueState.id}">${clueState.value}</option>
								</c:forEach>
							</select>
						</div>
					</div>

					<div class="form-group">
						<label for="edit-source" class="col-sm-2 control-label">线索来源</label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="edit-source">
								<option></option>
								<c:forEach items="${sourceList}" var="source">
									<option value="${source.id}">${source.value}</option>
								</c:forEach>
							</select>
						</div>
					</div>

					<div class="form-group">
						<label for="edit-description" class="col-sm-2 control-label">描述</label>
						<div class="col-sm-10" style="width: 81%;">
							<textarea class="form-control" rows="3" id="edit-description"></textarea>
						</div>
					</div>

					<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

					<div style="position: relative;top: 15px;">
						<div class="form-group">
							<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
							</div>
						</div>
						<div class="form-group">
							<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control myDateClass" id="edit-nextContactTime" value="2017-05-01" readonly>
							</div>
						</div>
					</div>

					<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

					<div style="position: relative;top: 20px;">
						<div class="form-group">
							<label for="edit-address" class="col-sm-2 control-label">详细地址</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="1" id="edit-address"></textarea>
							</div>
						</div>
					</div>
				</form>

			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				<button type="button" class="btn btn-primary" id="saveUpdateClueBtn">更新</button>
			</div>
		</div>
	</div>
</div>


<div>
	<div style="position: relative; left: 10px; top: -10px;">
		<div class="page-header">
			<h3>线索列表</h3>
		</div>
	</div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

	<div style="width: 100%; position: absolute;top: 5px; left: 10px;">

		<div class="btn-toolbar" role="toolbar" style="height: 80px;">
			<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

				<div class="form-group">
					<div class="input-group">
						<div class="input-group-addon">名称</div>
						<input class="form-control" type="text" id="query-fullname">
					</div>
				</div>

				<div class="form-group">
					<div class="input-group">
						<div class="input-group-addon">公司</div>
						<input class="form-control" type="text" id="query-company">
					</div>
				</div>

				<div class="form-group">
					<div class="input-group">
						<div class="input-group-addon">公司座机</div>
						<input class="form-control" type="text" id="query-phone">
					</div>
				</div>

				<div class="form-group">
					<div class="input-group">
						<div class="input-group-addon">线索来源</div>
						<select class="form-control" id="query-source">
							<option></option>
							<c:forEach items="${sourceList}" var="source">
								<option value="${source.id}">${source.value}</option>
							</c:forEach>
						</select>
					</div>
				</div>

				<br>

				<div class="form-group">
					<div class="input-group">
						<div class="input-group-addon">所有者</div>
						<input class="form-control" type="text" id="query-owner">
					</div>
				</div>


				<div class="form-group">
					<div class="input-group">
						<div class="input-group-addon">手机</div>
						<input class="form-control" type="text" id="query-mphone">
					</div>
				</div>

				<div class="form-group">
					<div class="input-group">
						<div class="input-group-addon">线索状态</div>
						<select class="form-control" id="query-state">
							<option></option>
							<c:forEach items="${clueStateList}" var="clueState">
								<option value="${clueState.id}">${clueState.value}</option>
							</c:forEach>
						</select>
					</div>
				</div>

				<button type="button" class="btn btn-default" id="queryClueBtn">查询</button>

			</form>
		</div>
		<div class="btn-toolbar" role="toolbar"
			 style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
			<div class="btn-group" style="position: relative; top: 18%;">
				<button type="button" class="btn btn-primary" id="createClueBtn"><span class="glyphicon glyphicon-plus"></span> 创建
				</button>
				<button type="button" class="btn btn-default" id="updateClueBtn"><span class="glyphicon glyphicon-pencil"></span> 修改
				</button>
				<button type="button" class="btn btn-danger" id="deleteClueBtn"><span class="glyphicon glyphicon-minus"></span> 删除
				</button>
			</div>


		</div>
		<div style="position: relative;top: 50px;">
			<table class="table table-hover">
				<thead>
				<tr style="color: #B3B3B3;">
					<td><input type="checkbox" id="myCheckAll"/></td>
					<td>名称</td>
					<td>公司</td>
					<td>公司座机</td>
					<td>手机</td>
					<td>线索来源</td>
					<td>所有者</td>
					<td>线索状态</td>
				</tr>
				</thead>
				<tbody id="tBody">
				</tbody>
			</table>
			<div id="demo_pag1"></div>
		</div>
	</div>

</div>
</body>
</html>