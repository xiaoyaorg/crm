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
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
<script type="text/javascript">

	$(function(){
		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
			e.stopPropagation();
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

		queryContactsByConditionForPage(1,10);
		//给创建按钮添加点击事件
		$("#createContactsBtn").click(function () {
			$("#createContactForm").get(0).reset();
			$("#createContactsModal").modal("show");
		});

		$("#create-customerName").typeahead({
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

		$("#edit-customerName").typeahead({
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

		$("#myCheckAll").click(function () {
			$("#tBody input[type='checkbox']").prop("checked",this.checked)
		});

		$("#tBody").on("click","input[type='checkbox']",function () {
			if($("#tBody input[type='checkbox']").size()==$("#tBody input[type='checkbox']:checked").size()){
				$("#myCheckAll").prop("checked",true);
			}else{
				$("#myCheckAll").prop("checked",false);
			}
		})

		$("#saveCreateContactsBtn").click(function () {
			let owner=$("#contacts-create-owner").val();
			let source=$("#contacts-create-source").val();
			let fullname=$("#contacts-create-fullname").val();
			let appellation=$("#contacts-create-appellation").val();
			let job=$("#contacts-create-job").val();
			let mphone=$("#contacts-create-mphone").val();
			let email=$("#contacts-create-email").val();
			let customerName=$("#create-customerName").val();
			let description=$("#contacts-create-description").val();
			let contactSummary=$("#contacts-create-contactSummary").val();
			let nextContactTime=$("#contact-create-nextContactTime").val();
			let address=$("#contacts-create-address").val();
			if(fullname==""){
				alert("姓名不能为空");
				return;
			}
			if(customerName==""){
				alert("客户名称不能为空");
				return;
			}
			let reg1=/^1\d{10}$/;
			if(!reg1.test(mphone)){
				alert("手机号码不合法,11位手机号");
				return;
			}
			let reg3 = /^([a-zA-Z\d][\w-]{2,})@(\w{2,})\.([a-z]{2,})(\.[a-z]{2,})?$/;
			if(!reg3.test(email)){
				alert("邮箱不合法");
				return;
			}
			$.ajax({
				url:"workbench/contacts/insertContacts.do",
				data:{
					owner:owner,
					source:source,
					fullname:fullname,
					appellation:appellation,
					job:job,
					mphone:mphone,
					email:email,
					customerName:customerName,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime,
					address:address
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code=="1"){
						$("#createContactsModal").modal("hide");
						queryContactsByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'))
					}else{
						alert(data.message);
					}
				}
			});
		});

		$("#editContactsBtn").click(function () {
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
			$.ajax({
				url:"workbench/contacts/queryContactsForEdit.do",
				data:{
					id:id
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					$("#edit-id").val(data.id);
					$("#edit-contactsOwner").find("option[text='"+data.owner+"']").attr("selected",true);
					// $("#edit-clueSource1").find("option[text='"+data.source+"']").attr("selected",true);
					let count=$("#edit-clueSource1").get(0).options.length;
					for(let i=0;i<count;i++){
						if($("#edit-clueSource1").get(0).options[i].text==data.source){
							$("#edit-clueSource1").get(0).options[i].selected=true;
							break;
						}
					}
					//$("#edit-clueSource1").val(data.source);
					$("#edit-surname").val(data.fullname);
					//$("#edit-call").find("option[text='"+data.appellation+"']").attr("selected",true);
					/*let count1=$("#edit-call").get(0).options.length;
					for(let i=0;i<count1;i++){
						if($("#edit-call").get(0).options[i].text==data.source){
							$("#edit-call").get(0).options[i].selected=true;
							break;
						}
					}*/
					$("#edit-call").val(data.appellation);
					$("#edit-job").val(data.job);
					$("#edit-mphone").val(data.mphone);
					$("#edit-email").val(data.email);
					$("#edit-customerName").val(data.customerId);
					$("#edit-describe").val(data.description);
					$("#edit-contactSummary").val(data.contactSummary);
					$("#edit-nextContactTime").val(data.nextContactTime);
					$("#edit-address2").val(data.address);
					$("#editContactsModal").modal("show");
				}
			});
		});

		$("#saveContactsEditBtn").click(function () {
			let id=$("#edit-id").val();
			let owner=$("#edit-contactsOwner").val();
			let source=$("#edit-clueSource1").val();
			let fullname=$("#edit-surname").val();
			let appellation=$("#edit-call").val();
			let job=$("#edit-job").val();
			let mphone=$("#edit-mphone").val();
			let email=$("#edit-email").val();
			let customerId=$("#edit-customerName").val();
			let description=$("#edit-describe").val();
			let contactSummary=$("#edit-contactSummary").val();
			let nextContactTime=$("#edit-nextContactTime").val();
			let address=$("#edit-address").val();
			if(fullname==""){
				alert("姓名不能为空");
				return;
			}
			if(customerId==""){
				alert("客户名称不能为空");
				return;
			}
			let reg1=/^1\d{10}$/;
			if(!reg1.test(mphone)){
				alert("手机号码不合法,11位手机号");
				return;
			}
			let reg3 = /^([a-zA-Z\d][\w-]{2,})@(\w{2,})\.([a-z]{2,})(\.[a-z]{2,})?$/;
			if(!reg3.test(email)){
				alert("邮箱不合法");
				return;
			}
			$.ajax({
				url:"workbench/contacts/saveEditContacts.do",
				data:{
					id:id,
					owner:owner,
					source:source,
					fullname:fullname,
					appellation:appellation,
					job:job,
					mphone:mphone,
					email:email,
					customerId:customerId,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime,
					address:address
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code=="1"){
						$("#editContactsModal").modal("hide");
						queryContactsByConditionForPage($("#demo_pag1").bs_pagination('getOption', 'currentPage'),$("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
					}else{
						alert(data.message);
						$("#editContactsModal").modal("show");
					}
				}
			});
		});

		$("#queryContactsBtn").click(function () {
			queryContactsByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'))
		});

        $("#deleteContactsBtn").click(function () {
            let checkedIds = $("#tBody input[type='checkbox']:checked");
            if (checkedIds.size() == 0) {
                alert("删除操作至少选择一条记录！");
                return;
            }
            if(window.confirm("确定要删除吗？")){
                let ids="";
                $.each(checkedIds, function () {
                    ids += "id=" + this.value + "&";
                });
                ids = ids.substr(0, ids.length - 1);
                $.ajax({
                    url:"workbench/contacts/saveDeleteContacts.do",
                    data:ids,
                    type:"post",
                    dataType:"json",
                    success:function (data) {
                        if(data.code=="1"){
                            queryContactsByConditionForPage(1, $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
                        }else{
                            alert(data.message);
                        }
                    }
                });
            }
        });
	});

	function queryContactsByConditionForPage(pageNo,pageSize){
		let owner=$("#queryContactsOwner").val();
		let fullname=$("#queryContactsFullName").val();
		let customerId=$("#queryContactsCustomerId").val();
		let source=$("#edit-clueSource").val();
		$.ajax({
			url:"workbench/contacts/queryContactsByConditionForPage.do",
			data:{
				owner:owner,
				fullname:fullname,
				customerId:customerId,
				source:source,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:"post",
			dataType:"json",
			success:function (data) {
				let htmlStr="";
				$.each(data.contactsList,function (index, obj) {
					htmlStr+="<tr>"
					htmlStr+="<td><input type=\"checkbox\" value=\""+obj.id+"\" /></td>"
					htmlStr+="<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/contacts/DetailContacts.do?id="+obj.id+"';\">"+obj.fullname+"</a></td>"
					htmlStr+="<td>"+obj.customerId+"</td>"
					htmlStr+="<td>"+obj.owner+"</td>"
					htmlStr+="<td>"+obj.source+"</td>"
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
						queryContactsByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
					}
				});
			}
		});
	}
</script>
</head>
<body>

	
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabelX">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="createContactForm">
					
						<div class="form-group">
							<label for="contacts-create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="contacts-create-owner">
								  <c:forEach items="${userList}" var="user">
									  <option value="${user.id}">${user.name}</option>
								  </c:forEach>
								</select>
							</div>
							<label for="contacts-create-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="contacts-create-source">
								    <option></option>
									<c:forEach items="${sourceList}" var="source">
										<option value="${source.id}">${source.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="contacts-create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="contacts-create-fullname">
							</div>
							<label for="contacts-create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="contacts-create-appellation">
								  <option></option>
								  <c:forEach items="${appellationList}" var="appellation">
									  <option value="${appellation.id}">${appellation.value}</option>
								  </c:forEach>
								</select>
							</div>
							
						</div>
						
						<div class="form-group">
							<label for="contacts-create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="contacts-create-job">
							</div>
							<label for="contacts-create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="contacts-create-mphone">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="contacts-create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="contacts-create-email">
							</div>
							<%--<label for="contacts-create-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="contacts-create-birth">
							</div>--%>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="contacts-create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="contacts-create-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="contacts-create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="contacts-create-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="contact-create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control myDate" id="contact-create-nextContactTime" readonly>
								</div>
							</div>
						</div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="contacts-create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="contacts-create-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveCreateContactsBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改联系人的模态窗口 -->
	<div class="modal fade" id="editContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">修改联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-contactsOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-contactsOwner">
									<c:forEach items="${userList}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
							<label for="edit-clueSource1" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-clueSource1">
								  <option></option>
									<c:forEach items="${sourceList}" var="source">
										<option value="${source.id}">${source.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-surname" value="李四">
							</div>
							<label for="edit-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-call">
								  <option></option>
									<c:forEach items="${appellationList}" var="appellation">
										<option value="${appellation.id}">${appellation.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" value="CTO">
							</div>
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" value="12345678901">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" value="lisi@bjpowernode.com">
							</div>
							<%--<label for="edit-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-birth">
							</div>--%>
						</div>
						
						<div class="form-group">
							<label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-customerName" placeholder="支持自动补全，输入客户不存在则新建" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe">这是一条线索的描述信息</textarea>
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
									<input type="text" class="form-control myDate" id="edit-nextContactTime" readonly>
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address2" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address2">北京大兴区大族企业湾</textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveContactsEditBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	

	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>联系人列表</h3>
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
				      <input class="form-control" type="text" id="queryContactsOwner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">姓名</div>
				      <input class="form-control" type="text" id="queryContactsFullName">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="queryContactsCustomerId">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="edit-clueSource">
						  <option></option>
						  <c:forEach items="${sourceList}" var="source">
							  <option value="${source.id}">${source.value}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>
				  
				  <%--<div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">生日</div>
				      <input class="form-control" type="text">
				    </div>
				  </div>--%>
				  
				  <button type="button" class="btn btn-default" id="queryContactsBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createContactsBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editContactsBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteContactsBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 20px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="myCheckAll"/></td>
							<td>姓名</td>
							<td>客户名称</td>
							<td>所有者</td>
							<td>来源</td>
							<%--<td>生日</td>--%>
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